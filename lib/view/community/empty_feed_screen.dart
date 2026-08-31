import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';

class EmptyFeedScreen extends StatelessWidget {
  final bool isStopSharing;
  const EmptyFeedScreen({super.key, required this.isStopSharing});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88.w,
              height: 88.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.colors.primary.withValues(alpha: 0.08),
              ),
              child: Icon(
                isStopSharing
                    ? Icons.visibility_off_rounded
                    : Icons.groups_outlined,
                size: 36.sp,
                color: context.colors.primary,
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              isStopSharing ? "Sharing Paused" : "Nothing Shared Yet",
              textAlign: TextAlign.center,
              style: context.typography.title.copyWith(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: context.colors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            SizedBox(
              width: 260.w,
              child: Text(
                isStopSharing
                    ? "You are no longer sharing your forecast with your circle."
                    : "Your friend hasn't shared their forecast yet.",
                textAlign: TextAlign.center,
                style: context.typography.body.copyWith(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: context.colors.textSecondary,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
