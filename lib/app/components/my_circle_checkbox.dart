import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MyCircleCheckbox extends StatelessWidget {
  final bool isChecked;
  final ValueChanged<bool>
  onChanged; // Updated from VoidCallback to emit the new state cleanly
  final Color? activeColor;
  final Color? inactiveBorderColor;
  final Color checkIconColor;
  final double size;

  const MyCircleCheckbox({
    super.key,
    required this.isChecked,
    required this.onChanged,
    this.activeColor, // If null, fallback defaults to Theme primary
    this.inactiveBorderColor, // If null, fallback defaults to subtle grey
    this.checkIconColor = Colors.white,
    this.size = 20.0, // Default sizing configuration
  });

  @override
  Widget build(BuildContext context) {
    // Sensible fallback token mapping
    final ThemeTheme = Theme.of(context);
    final effectiveActiveColor = activeColor ?? ThemeTheme.primaryColor;
    final effectiveInactiveBorderColor =
        inactiveBorderColor ?? Colors.grey.withValues(alpha: 0.4);

    return GestureDetector(
      onTap: () => onChanged(!isChecked),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: size.w,
        height: size.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isChecked ? effectiveActiveColor : Colors.transparent,
          border: Border.all(
            color: isChecked
                ? effectiveActiveColor
                : effectiveInactiveBorderColor,
            width: isChecked ? 2.w : 1.5.w,
          ),
        ),
        child: isChecked
            ? Icon(
                Icons.check,
                size: (size * 0.7).sp, // Scaled matching icon size natively
                color: checkIconColor,
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}
