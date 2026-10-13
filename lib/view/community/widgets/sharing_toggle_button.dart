import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kena_emotional_journey/app/components/loading_widget.dart';
import 'package:kena_emotional_journey/app/components/my_dialog.dart';
import 'package:kena_emotional_journey/app/components/premium_lock.dart';
import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';
import 'package:kena_emotional_journey/generated/assets/assets.gen.dart';
import 'package:kena_emotional_journey/provider/subscription_provider.dart';

/// The "Start Sharing" / "Stop Sharing" control shared by the daily and
/// weekly feed screens, so both look and behave identically instead of
/// keeping two hand-copied versions in sync.
class SharingToggleButton extends StatelessWidget {
  const SharingToggleButton({
    super.key,
    required this.isShared,
    required this.isBusy,
    required this.onStart,
    required this.onStop,
  });

  final bool isShared;
  final bool isBusy;
  final VoidCallback? onStart;
  final VoidCallback? onStop;

  @override
  Widget build(BuildContext context) {
    if (isBusy) {
      return SizedBox(
        width: 18.w,
        height: 18.h,
        child: LoadingWidget(color: context.colors.error, size: 2),
      );
    }

    if (isShared) {
      return GestureDetector(
        onTap: onStop,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Assets.icons.notshare.svg(height: 18.h, width: 18.w),
            SizedBox(width: 8.w),
            Text(
              "Stop Sharing",
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: Colors.red,
                fontFamily: "sfpro",
              ),
            ),
          ],
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 98.w,
          height: 27.h,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: context.colors.tertiary,
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            onPressed: onStart,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                context.isFreemium
                    ? const PremiumBadgeIcon(size: 14)
                    : Assets.icons.sharing.svg(height: 14.h, width: 14.w),
                SizedBox(width: 4.w),
                Flexible(
                  child: Text(
                    "Start Sharing",
                    overflow: TextOverflow.ellipsis,
                    style: context.typography.body.copyWith(
                      color: context.colors.background,
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 5.w),
        GestureDetector(
          onTap: () => _showInfoDialog(context),
          child: Icon(Icons.info_outline, color: context.colors.tertiary),
        ),
      ],
    );
  }

  void _showInfoDialog(BuildContext context) {
    MyDialogBox.show(
      context,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Sharing Forecast",
              style: context.typography.title.copyWith(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              "When you share your forecast, you decide who in your community circle can see your daily emotional updates and journal entries.",
              textAlign: TextAlign.center,
              style: context.typography.body.copyWith(
                fontSize: 13.sp,
                color: context.colors.textSecondary,
              ),
            ),
            SizedBox(height: 16.h),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Got it",
                style: TextStyle(color: context.colors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
