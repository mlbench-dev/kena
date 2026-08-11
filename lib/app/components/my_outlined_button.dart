import 'package:kena_emotional_journey/app/styles/app_radiuses.dart';
import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MyOutlinedButton extends StatelessWidget {
  const MyOutlinedButton({
    required this.label,
    super.key,
    this.icon,
    this.onPressed,
    this.isDark = false,
  });

  final String label;
  final Widget? icon;
  final VoidCallback? onPressed;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null;

    final borderColor = isDark
        ? context.colors.buttonPrimary
        : context.colors.buttonSecondary;

    final textColor = borderColor;

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: textColor,
          // padding: EdgeInsets.symmetric(vertical: 12.h),
          padding: EdgeInsets.symmetric(vertical: 14.h),
          side: BorderSide(
            color: isEnabled ? borderColor : context.colors.buttonDisabled,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadiuses.largeRadius),
          ),
        ),
        child: icon != null
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) icon!,
                  SizedBox(width: 8.w),
                  Text(
                    label,
                    style: context.typography.button.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            : Text(
                label,
                style: context.typography.button.copyWith(color: textColor),
              ),
      ),
    );
  }
}
