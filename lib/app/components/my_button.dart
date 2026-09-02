import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kena_emotional_journey/app/components/loading_widget.dart';
import 'package:kena_emotional_journey/app/styles/app_radiuses.dart';
import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';

class MyButton extends StatelessWidget {
  const MyButton({
    required this.label,
    super.key,
    this.onPressed,
    this.isDark = true,
    this.icon,
    this.isLoading = false,
    this.fontSize = 18,
    this.backgroundColor,
    this.fontWeight = FontWeight.w400,
    this.textColor,
    this.borderColor,
    this.borderWidth,
    this.isEnabled, // <-- New optional parameter
  });

  final String label;
  final FontWeight fontWeight;
  final VoidCallback? onPressed;
  final bool isDark;
  final Widget? icon;
  final bool isLoading;
  final double fontSize;

  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final double? borderWidth;

  final bool? isEnabled; // <-- New optional parameter

  @override
  Widget build(BuildContext context) {
    // Determine enabled state
    final bool enabled = isEnabled ?? (onPressed != null && !isLoading);

    // Determine Background Color
    final resolvedBgColor =
        backgroundColor ??
        (isDark
            ? (enabled
                  ? context.colors.buttonPrimary
                  : context.colors.buttonDisabled)
            : (enabled
                  ? context.colors.buttonSecondary
                  : context.colors.buttonDisabled));

    // Determine Text Color
    final resolvedTextColor =
        textColor ??
        (enabled
            ? (isDark
                  ? context.colors.buttonPrimaryText
                  : context.colors.buttonSecondaryText)
            : context.colors.buttonDisabledText);

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: enabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          fixedSize: Size(double.infinity, 56.h),
          backgroundColor: resolvedBgColor,
          foregroundColor: resolvedTextColor,
          disabledBackgroundColor: resolvedBgColor,
          disabledForegroundColor: resolvedTextColor,
          elevation: backgroundColor == Colors.transparent ? 0 : null,
          side: (borderColor != null || borderWidth != null)
              ? BorderSide(
                  color: borderColor ?? Colors.transparent,
                  width: borderWidth ?? 1.0,
                )
              : null,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadiuses.largeRadius),
          ),
        ),
        icon: isLoading
            ? const SizedBox.shrink()
            : (icon ?? const SizedBox.shrink()),
        label: isLoading
            ? LoadingWidget(
                size: 24.sp,
                color: const Color.fromARGB(96, 168, 168, 168),
              )
            : Text(
                label,
                style: context.typography.button.copyWith(
                  color: resolvedTextColor,
                  fontSize: fontSize.sp,
                  fontWeight: fontWeight,
                  fontFamily: "sfpro",
                ),
              ),
      ),
    );
  }
}
