import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kena_emotional_journey/app/components/loading_widget.dart';
import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';
import 'package:kena_emotional_journey/generated/assets/assets.gen.dart';
import 'package:kena_emotional_journey/services/common/image_picker.dart';
import 'package:kena_emotional_journey/services/common/upload_service.dart';
import 'package:kena_emotional_journey/view/profile/widgets/image_crop_preview_screen.dart';

class ImagePickerAvatar extends StatefulWidget {
  const ImagePickerAvatar({
    super.key,
    this.onImageChanged,
    this.initialUrl,
    this.size = 100,
    this.readOnly = false,
  });

  final void Function(String? url)? onImageChanged;
  final String? initialUrl;
  final bool readOnly;
  final double size;

  @override
  State<ImagePickerAvatar> createState() => _ImagePickerAvatarState();
}

class _ImagePickerAvatarState extends State<ImagePickerAvatar> {
  File? _localImage;
  String? _uploadedUrl;
  bool _isBusy = false;

  final _pickerService = ImagePickerService();
  final _uploadService = ImageUploadService();

  @override
  void initState() {
    super.initState();
    _uploadedUrl = widget.initialUrl;
  }

  Future<void> _pickAndUploadImage(BuildContext context) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: context.colors.background,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.photo_library, color: context.colors.primary),
              title: Text("Gallery", style: context.typography.title),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: Icon(Icons.camera_alt, color: context.colors.primary),
              title: Text("Camera", style: context.typography.title),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    final file = await _pickerService.pickImage(source: source);
    if (file == null || !mounted) return;

    if (!context.mounted) return;
    final croppedFile = await ImageCropPreviewScreen.show(
      context,
      imageFile: file,
    );
    if (croppedFile == null || !mounted) return;

    setState(() => _isBusy = true);

    String? url;
    if (context.mounted) {
      url = await _uploadService.uploadImage(context, file: croppedFile);
    }

    if (!mounted) return;
    if (mounted) {
      setState(() {
        _isBusy = false;
        if (url != null) {
          _localImage = croppedFile;
          _uploadedUrl = url;
          widget.onImageChanged?.call(_uploadedUrl);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasImage =
        _localImage != null ||
        (_uploadedUrl != null && _uploadedUrl!.isNotEmpty);

    final imageProvider = _localImage != null
        ? FileImage(_localImage!)
        : _uploadedUrl != null
        ? NetworkImage(_uploadedUrl!) as ImageProvider
        : null;

    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: widget.size,
            width: widget.size,
            margin: EdgeInsets.symmetric(horizontal: 12.w),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.colors.inputBackground,
              border: Border.all(color: context.colors.onSurface, width: 2),
              image: hasImage
                  ? DecorationImage(image: imageProvider!, fit: BoxFit.cover)
                  : DecorationImage(
                      image: AssetImage(Assets.icons.userPlaceholder.path),
                      fit: BoxFit.contain,
                    ),
            ),
            child: _isBusy
                ? const Center(child: LoadingWidget(color: Colors.white))
                : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: IconButton.filled(
              onPressed: _isBusy || widget.readOnly
                  ? null
                  : () => _pickAndUploadImage(context),
              icon: Icon(Icons.edit, color: context.colors.background),
              style: IconButton.styleFrom(
                backgroundColor: context.colors.primary,
                foregroundColor: context.colors.surface,
                padding: EdgeInsets.all(8.w),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
