import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';
import 'package:path_provider/path_provider.dart';

/// Full-screen image crop screen with a draggable circular selection.
///
/// ```dart
/// final cropped = await ImageCropPreviewScreen.show(context, imageFile: file);
/// if (cropped != null) { /* upload */ }
/// ```
class ImageCropPreviewScreen extends StatefulWidget {
  const ImageCropPreviewScreen({required this.imageFile, super.key});

  final File imageFile;

  static Future<File?> show(BuildContext context, {required File imageFile}) {
    return Navigator.of(context).push<File?>(
      PageRouteBuilder<File?>(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) =>
            ImageCropPreviewScreen(imageFile: imageFile),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
            child: child,
          );
        },
      ),
    );
  }

  @override
  State<ImageCropPreviewScreen> createState() => _ImageCropPreviewScreenState();
}

class _ImageCropPreviewScreenState extends State<ImageCropPreviewScreen> {
  final GlobalKey _repaintKey = GlobalKey();
  bool _isCropping = false;
  Offset _circleOffset = Offset.zero;
  double _cropDiameter = 0;
  Size? _imageSize;

  @override
  void initState() {
    super.initState();
    _resolveImageSize();
  }

  Future<void> _resolveImageSize() async {
    final bytes = await widget.imageFile.readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    if (mounted) {
      setState(() {
        _imageSize = Size(
          frame.image.width.toDouble(),
          frame.image.height.toDouble(),
        );
      });
    }
    codec.dispose();
  }

  /// Clamps [offset] so the crop circle stays within the rendered image bounds.
  Offset _clampOffset(
    Offset offset, {
    required double containerW,
    required double containerH,
    required double cropDiameter,
  }) {
    final imgSize = _imageSize;
    if (imgSize == null) return offset;

    final scaleX = containerW / imgSize.width;
    final scaleY = containerH / imgSize.height;
    final scale = scaleX < scaleY ? scaleX : scaleY;
    final renderedW = imgSize.width * scale;
    final renderedH = imgSize.height * scale;

    final cropRadius = cropDiameter / 2;
    final maxDx = renderedW / 2 - cropRadius;
    final maxDy = renderedH / 2 - cropRadius;

    return Offset(
      offset.dx.clamp(maxDx > 0 ? -maxDx : 0, maxDx > 0 ? maxDx : 0),
      offset.dy.clamp(maxDy > 0 ? -maxDy : 0, maxDy > 0 ? maxDy : 0),
    );
  }

  /// Captures the pixels inside the crop circle and saves as a square PNG.
  Future<void> _onDone() async {
    if (_isCropping) return;
    setState(() => _isCropping = true);

    try {
      final boundary =
          _repaintKey.currentContext!.findRenderObject()!
              as RenderRepaintBoundary;

      const pixelRatio = 3.0;
      final fullImage = await boundary.toImage(pixelRatio: pixelRatio);

      final boundarySize = boundary.size;
      final cropDiameter = _cropDiameter;
      final cropRadius = cropDiameter / 2;
      final circleCenterX = boundarySize.width / 2 + _circleOffset.dx;
      final circleCenterY = boundarySize.height / 2 + _circleOffset.dy;

      final cropRect = Rect.fromCircle(
        center: Offset(circleCenterX * pixelRatio, circleCenterY * pixelRatio),
        radius: cropRadius * pixelRatio,
      );

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final outputSize = (cropDiameter * pixelRatio).toInt();
      final outputRect = Rect.fromLTWH(
        0,
        0,
        outputSize.toDouble(),
        outputSize.toDouble(),
      );

      canvas.clipRRect(
        RRect.fromRectAndRadius(outputRect, Radius.circular(outputSize / 2)),
      );
      canvas.drawImageRect(
        fullImage,
        cropRect,
        outputRect,
        Paint()..filterQuality = FilterQuality.high,
      );

      final picture = recorder.endRecording();
      final croppedImage = await picture.toImage(outputSize, outputSize);
      final byteData = await croppedImage.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (byteData == null) {
        if (mounted) setState(() => _isCropping = false);
        return;
      }

      final tempDir = await getTemporaryDirectory();
      final fileName = 'cropped_${DateTime.now().millisecondsSinceEpoch}.png';
      final croppedFile = File('${tempDir.path}/$fileName');
      await croppedFile.writeAsBytes(byteData.buffer.asUint8List());

      if (mounted) Navigator.of(context).pop(croppedFile);
    } catch (_) {
      if (mounted) setState(() => _isCropping = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(onClose: () => Navigator.of(context).pop()),

            // Crop Area
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final maxByWidth = constraints.maxWidth - 16.w * 2;
                  final maxByHeight = constraints.maxHeight * 0.78;
                  final cropDiameter = maxByWidth < maxByHeight
                      ? maxByWidth
                      : maxByHeight;
                  _cropDiameter = cropDiameter;

                  return RepaintBoundary(
                    key: _repaintKey,
                    child: ClipRect(
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Static Image
                          Image.file(
                            widget.imageFile,
                            fit: BoxFit.contain,
                            width: double.infinity,
                            height: double.infinity,
                          ),

                          // Dark Overlay
                          Positioned.fill(
                            child: IgnorePointer(
                              child: CustomPaint(
                                painter: _CropOverlayPainter(
                                  cropDiameter: cropDiameter,
                                  offset: _circleOffset,
                                ),
                              ),
                            ),
                          ),

                          // Draggable Crop Circle
                          Positioned.fill(
                            child: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onPanUpdate: (details) {
                                setState(() {
                                  _circleOffset = _clampOffset(
                                    _circleOffset + details.delta,
                                    containerW: constraints.maxWidth,
                                    containerH: constraints.maxHeight,
                                    cropDiameter: cropDiameter,
                                  );
                                });
                              },
                              child: Center(
                                child: Transform.translate(
                                  offset: _circleOffset,
                                  child: Container(
                                    width: cropDiameter,
                                    height: cropDiameter,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white.withValues(
                                          alpha: 0.7,
                                        ),
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            _BottomBar(
              isCropping: _isCropping,
              onRetake: () => Navigator.of(context).pop(),
              onDone: _onDone,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Top Bar ──────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: onClose,
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close, color: Colors.white, size: 22.sp),
            ),
          ),
          const Spacer(),
          Text(
            'Adjust Photo',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.3,
            ),
          ),
          const Spacer(),
          SizedBox(width: 38.w),
        ],
      ),
    );
  }
}

// ── Bottom Bar ───────────────────────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.isCropping,
    required this.onRetake,
    required this.onDone,
  });

  final bool isCropping;
  final VoidCallback onRetake;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 16.h),
      child: Row(
        children: [
          // Cancel
          Expanded(
            child: GestureDetector(
              onTap: onRetake,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 13.h),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
                child: Center(
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),

          SizedBox(width: 12.w),

          // Done
          Expanded(
            child: GestureDetector(
              onTap: isCropping ? null : onDone,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 13.h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      context.colors.primary,
                      context.colors.primary.withValues(alpha: 0.85),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14.r),
                  boxShadow: [
                    BoxShadow(
                      color: context.colors.primary.withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: isCropping
                      ? SizedBox(
                          width: 20.w,
                          height: 20.w,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 18.sp,
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              'Done',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Crop Overlay Painter ─────────────────────────────────────────────────────

class _CropOverlayPainter extends CustomPainter {
  _CropOverlayPainter({required this.cropDiameter, this.offset = Offset.zero});

  final double cropDiameter;
  final Offset offset;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2) + offset;
    final radius = cropDiameter / 2;
    final overlayPaint = Paint()..color = Colors.black.withValues(alpha: 0.55);

    final overlayPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final holePath = Path()
      ..addOval(Rect.fromCircle(center: center, radius: radius));

    canvas.drawPath(
      Path.combine(PathOperation.difference, overlayPath, holePath),
      overlayPaint,
    );
  }

  @override
  bool shouldRepaint(_CropOverlayPainter oldDelegate) =>
      cropDiameter != oldDelegate.cropDiameter || offset != oldDelegate.offset;
}
