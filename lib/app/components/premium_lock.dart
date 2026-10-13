import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kena_emotional_journey/app/components/my_button.dart';
import 'package:kena_emotional_journey/app/components/premium_dialog.dart';
import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';
import 'package:kena_emotional_journey/generated/assets/assets.gen.dart';

/// Small premium badge placed next to a Premium-only label or button.
class PremiumBadgeIcon extends StatelessWidget {
  const PremiumBadgeIcon({super.key, this.size = 14});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Assets.icons.premiumBadge.svg(width: size.w, height: size.w);
  }
}

/// Placeholder shown in place of Premium-only content for Freemium users.
class PremiumLockedView extends StatelessWidget {
  const PremiumLockedView({
    super.key,
    required this.title,
    this.message = 'Upgrade to Premium to unlock this feature.',
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 16.h),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 28.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F3F5),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Assets.icons.premiumBadge.svg(width: 44.w, height: 40.h),
          SizedBox(height: 12.h),
          Text(
            title,
            textAlign: TextAlign.center,
            style: context.typography.headline.copyWith(
              fontSize: 17.sp,
              fontWeight: FontWeight.w600,
              color: context.colors.tertiary,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            message,
            textAlign: TextAlign.center,
            style: context.typography.body.copyWith(
              fontSize: 13.sp,
              color: context.colors.textSecondary,
            ),
          ),
          SizedBox(height: 16.h),
          MyButton(
            label: 'Get Premium',
            backgroundColor: context.colors.primary,
            textColor: Colors.white,
            onPressed: () => PremiumDialog.show(context),
          ),
        ],
      ),
    );
  }
}
