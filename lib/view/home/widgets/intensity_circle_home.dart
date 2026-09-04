import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';

class IntensityCircleHome extends StatelessWidget {
  final int intensity;
  final Widget centerWidget;
  final String label;
  final String? imageUrl;
  final double? customSize; // Added optional size parameter

  const IntensityCircleHome({
    super.key,
    required this.intensity,
    required this.centerWidget,
    required this.label,
    this.imageUrl,
    this.customSize, // Initialize here
  });

  @override
  Widget build(BuildContext context) {
    final double progress =
        intensity.clamp(0, 5) / 5; // Assuming 5% based on your text label

    // Use customSize if provided, otherwise default to 55.r
    final double size = customSize ?? 55.r;

    // Scale stroke and inner circle proportionally to the size
    final double strokeWidth = size * 0.12;
    final double innerSize = size * 0.9;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
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
              Container(
                width: innerSize,
                height: innerSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.colors.background,
                ),
                child: Center(
                  child: (imageUrl?.isNotEmpty ?? false)
                      ? ClipOval(
                          child: Image.network(
                            imageUrl!,
                            width: innerSize,
                            height: innerSize,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return centerWidget;
                            },
                          ),
                        )
                      : centerWidget,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 15.w),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 68.w,
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.typography.body.copyWith(
                  color: context.colors.textPrimary,
                  fontSize: 13.sp,
                  fontFamily: "sfpro",
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(height: 5.h),
            Text(
              '$intensity/5',
              style: context.typography.body.copyWith(
                color: const Color(0xFF399969),
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
