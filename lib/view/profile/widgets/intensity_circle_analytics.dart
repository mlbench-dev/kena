import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';

class IntensityCircleAnalytics extends StatelessWidget {
  final int intensity;
  final Widget centerWidget;
  final String label;
  final String? imageUrl;
  final double? customSize;

  const IntensityCircleAnalytics({
    super.key,
    required this.intensity,
    required this.centerWidget,
    required this.label,
    this.imageUrl,
    this.customSize,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    final double progress = intensity.clamp(0, 5) / 5;

    final double size = customSize ?? 55.r;

    // Improved sizing
    final double strokeWidth = size * 0.12;
    final double innerSize = size * 0.65; // Increased from 0.4 → FIXED

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              /// Progress Circle
              SizedBox(
                width: size,
                height: size,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: strokeWidth,
                  backgroundColor: const Color(0xFFf1e2c5),
                  valueColor: const AlwaysStoppedAnimation(Color(0xFF32683b)),
                ),
              ),

              /// Inner Circle
              Container(
                width: innerSize,
                height: innerSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.background,
                ),

                /// Content (Image + Text Overlay)
                child: Center(
                  child: FittedBox(
                    child: (imageUrl?.isNotEmpty ?? false)
                        ? Stack(
                            alignment: Alignment.center,
                            children: [
                              ClipOval(
                                child: Image.network(
                                  imageUrl!,
                                  width: innerSize,
                                  height: innerSize,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return centerWidget;
                                  },
                                ),
                              ),

                              /// Text on top of image
                              centerWidget,
                            ],
                          )
                        : centerWidget,
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 10.h),

        /// Label
        SizedBox(
          width: 80.w,
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: typography.body.copyWith(
              color: colors.textPrimary,
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              fontFamily: "sfpro",
            ),
          ),
        ),
      ],
    );
  }
}
