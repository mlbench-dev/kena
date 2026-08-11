import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kena_emotional_journey/app/components/my_button.dart';
import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';

/// A styled dialog content widget used for pro tip milestones.
///
/// Shows an icon, title, description, and an action button.
/// Designed to be used inside [MyDialogBox.show()].
class ProTipsDialogBox extends StatelessWidget {
  final String title;
  final String description;
  final String buttonLabel;
  final Widget icon;
  final VoidCallback onButtonPressed;

  const ProTipsDialogBox({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.onButtonPressed,
    required this.buttonLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 268.h,
      width: 343.w,
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          icon,
          SizedBox(height: 10.h),
          Text(
            title,
            style: context.typography.body.copyWith(
              color: context.colors.primary,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              fontFamily: 'sfpro',
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            description,
            textAlign: TextAlign.center,
            style: context.typography.body.copyWith(
              color: context.colors.textPrimary,
              fontSize: 16.sp,
              fontWeight: FontWeight.w400,
              fontFamily: 'sfpro',
            ),
          ),
          SizedBox(height: 10.h),
          MyButton(label: buttonLabel, onPressed: onButtonPressed),
        ],
      ),
    );
  }
}
