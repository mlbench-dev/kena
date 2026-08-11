import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';
import 'package:flutter/material.dart';

class MyTextButton extends StatelessWidget {
  const MyTextButton({
    required this.label,
    super.key,
    this.onPressed,
    this.showUnderline = true,
    this.isDark = false,
    this.icon,
    this.fontSize,
  });
  final String label;
  final VoidCallback? onPressed;
  final bool isDark;
  final bool showUnderline;
  final Widget? icon;
  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null;

    final textColor = isDark
        ? (isEnabled
              ? context.colors.textOnDark
              : context.colors.textOnDark.withValues(alpha: .70))
        : (isEnabled
              ? context.colors.textOnLight
              : context.colors.textOnLight.withValues(alpha: .70));

    return TextButton.icon(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: textColor,
        textStyle: showUnderline
            ? const TextStyle(decoration: TextDecoration.underline)
            : null,
        padding: EdgeInsets.zero, // no extra space
        minimumSize: Size.zero, // shrink to fit
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      label: Text(
        label,
        style: context.typography.subtitle.copyWith(
          color: textColor,
          fontWeight: FontWeight.w500,
          fontFamily: 'sfpro',
          letterSpacing: -0.2,
          height: 1.2,
          fontSize: fontSize,
        ),
      ),
      icon: icon,
    );
  }
}
