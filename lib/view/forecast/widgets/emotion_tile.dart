import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';
import 'package:kena_emotional_journey/generated/assets/assets.gen.dart';
import 'package:kena_emotional_journey/model/emotions/emotions_list.dart';
import 'package:kena_emotional_journey/model/forecast/forecast_model.dart';
import 'package:kena_emotional_journey/view/emotions/widgets/image_zoom_viewer.dart'
    show ImageZoomViewer;
import 'package:loading_animation_widget/loading_animation_widget.dart';

class EmotionTile extends StatelessWidget {
  final bool isEditMode;
  final Emotion emotion;
  final bool showImage;
  final VoidCallback? onEditImageTap;
  final VoidCallback? onDeleteTap;
  final bool
  isDisabled; // optional: blocks edit/delete taps, e.g. while another tile's image uploads
  final bool showDenominator;
  final bool showForecastActualRange;
  const EmotionTile({
    super.key,
    required this.emotion,
    required this.isEditMode,
    this.showImage = true,
    this.onEditImageTap,
    this.onDeleteTap,
    this.isDisabled = false,
    this.showDenominator = true,
    this.showForecastActualRange = false,
  });
  @override
  Widget build(BuildContext context) {
    final emotionName = EmotionsList.getTitleByKey(emotion.key ?? '');
    final intensity = _formatIntensity(emotion.intensity);

    return SizedBox(
      width: 99.w,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            emotionName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.typography.body.copyWith(
              color: context.colors.textPrimary,
              fontWeight: FontWeight.w500,
              fontSize: 12.sp,
              fontFamily: "sfpro",
            ),
          ),
          SizedBox(height: 5.h),
          _buildImageContainer(context),
          SizedBox(height: 5.h),
          Text(
            showForecastActualRange
                ? "$intensity-5"
                : (showDenominator ? "$intensity/5" : intensity),
            style: context.typography.body.copyWith(
              color: context.colors.primary,
              fontWeight: FontWeight.w500,
              fontSize: 12.sp,
              fontFamily: "sfpro",
            ),
          ),
        ],
      ),
    );
  }

  String _formatIntensity(num? intensity) {
    final value = intensity ?? 0;
    if (!showDenominator || showForecastActualRange) {
      return value.round().toString();
    }
    return value % 1 == 0 ? value.toInt().toString() : value.toStringAsFixed(1);
  }

  Widget _buildImageContainer(BuildContext context) {
    if (showImage && emotion.imageUrl != null && emotion.imageUrl!.isNotEmpty) {
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: GestureDetector(
              onTap: () {
                ImageZoomViewer.show(context, emotion.imageUrl!);
              },
              child: CachedNetworkImage(
                imageUrl: emotion.imageUrl!,
                width: 99.w,
                height: 77.h,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: 99.w,
                  height: 77.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFAF0),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Center(
                    child: LoadingAnimationWidget.staggeredDotsWave(
                      color: context.colors.primary,
                      size: 25,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => _buildFallback(context),
              ),
            ),
          ),

          // Pencil icon (top-right)
          if (isEditMode)
            Positioned(
              top: 4.h,
              right: 4.w,
              child: GestureDetector(
                onTap: isDisabled ? null : onEditImageTap,
                child: Opacity(
                  opacity: isDisabled ? 0.4 : 1,
                  child: Center(
                    child: Assets.icons.circleEdits.svg(
                      height: 23.h,
                      width: 23.w,
                      allowDrawingOutsideViewBox: true,
                    ),
                  ),
                ),
              ),
            ),
          if (isEditMode)
            Positioned(
              bottom: 4.h,
              left: 4.w,
              child: GestureDetector(
                onTap: isDisabled ? null : onDeleteTap,
                child: Opacity(
                  opacity: isDisabled ? 0.4 : 1,
                  child: Center(
                    child: Assets.icons.bin.svg(
                      height: 23.h,
                      width: 23.w,
                      allowDrawingOutsideViewBox: true,
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
    }

    return _buildFallback(context);
  }

  Widget _buildFallback(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 99.w,
          height: 77.h,
          decoration: BoxDecoration(
            color: const Color(0xFFFFFAF0),
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(
              color: context.colors.textSecondary.withValues(alpha: 0.3),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(10.w),
            child: Center(
              child: FittedBox(
                fit: BoxFit.contain,
                child: EmotionsList.getEmojiByKey(
                  emotion.key ?? '',
                  w: 42,
                  h: 42,
                ),
              ),
            ),
          ),
        ),

        if (isEditMode)
          Positioned(
            top: 4.h,
            right: 4.w,
            child: GestureDetector(
              onTap: isDisabled ? null : onEditImageTap,
              child: Opacity(
                opacity: isDisabled ? 0.4 : 1,
                child: Center(
                  child: Assets.icons.circleEdits.svg(
                    height: 23.h,
                    width: 23.w,
                    allowDrawingOutsideViewBox: true,
                  ),
                ),
              ),
            ),
          ),
        if (isEditMode)
          Positioned(
            bottom: 4.h,
            left: 4.w,
            child: GestureDetector(
              onTap: isDisabled ? null : onDeleteTap,
              child: Opacity(
                opacity: isDisabled ? 0.4 : 1,
                child: Center(
                  child: Assets.icons.bin.svg(
                    height: 23.h,
                    width: 23.w,
                    allowDrawingOutsideViewBox: true,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
