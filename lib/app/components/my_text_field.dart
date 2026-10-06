import 'package:flutter/services.dart';
import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MyTextField extends StatelessWidget {
  const MyTextField({
    super.key,
    this.controller,
    this.hint,
    this.label = false,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.obscureText = false,
    this.readOnly = false, // ← NEW: Defaults to false
    this.enabled = true,
    this.errorText,
    this.textCapitalization = TextCapitalization.none,
    this.validator,
    this.textInputAction = TextInputAction.done,
    this.textAlign = TextAlign.start,
    this.maxLength,
    this.borderRadius = 16,
    this.onChanged,
    this.maxLines,
    this.onSubmitted,
    this.inputFormatters,
    this.counterText,
    this.counterStyle,
    this.textColor,
    this.hintColor,
    this.fillColor,
    this.borderColor,
    this.focusedBorderColor,
  });

  final TextEditingController? controller;
  final String? hint;
  final bool label;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool readOnly; // ← NEW: Final variable
  final bool enabled;
  final String? errorText;
  final TextCapitalization textCapitalization;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;
  final TextAlign textAlign;
  final int? maxLength;
  final double borderRadius;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLines;

  final String? counterText;
  final TextStyle? counterStyle;

  final Color? textColor;
  final Color? hintColor;
  final Color? fillColor;
  final Color? borderColor;
  final Color? focusedBorderColor;

  @override
  Widget build(BuildContext context) {
    final defaultBorderColor =
        borderColor ?? context.colors.inputBorder.withOpacity(0.10);

    final defaultFocusedBorderColor =
        focusedBorderColor ?? context.colors.inputBorder;

    return TextFormField(
      onFieldSubmitted: onSubmitted,
      validator: validator,
      enabled: enabled,
      inputFormatters: inputFormatters,
      controller: controller,
      readOnly: readOnly, // ← NEW: Applied to the TextField
      cursorColor: context.colors.inputIcon,
      cursorErrorColor: context.colors.error,
      textCapitalization: textCapitalization,
      textInputAction: textInputAction,
      textAlign: textAlign,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLength: maxLength,
      maxLengthEnforcement: MaxLengthEnforcement.enforced,
      onChanged: onChanged,
      maxLines: maxLines ?? 1,
      style: TextStyle(color: textColor ?? context.colors.textPrimary),

      // ... rest of your buildCounter and decoration code remains the same
      buildCounter:
          (context, {required currentLength, required isFocused, maxLength}) {
            if (counterText != null) {
              return Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  counterText!,
                  style:
                      counterStyle ??
                      TextStyle(
                        fontSize: 12.sp,
                        color: isFocused
                            ? context.colors.primary
                            : context.colors.textSecondary.withOpacity(0.7),
                      ),
                ),
              );
            }
            if (maxLength != null && maxLength > 0) {
              return Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  '$currentLength/$maxLength',
                  style:
                      counterStyle ??
                      TextStyle(
                        fontSize: 12.sp,
                        color: isFocused
                            ? context.colors.primary
                            : context.colors.textSecondary.withOpacity(0.7),
                      ),
                ),
              );
            }
            return const SizedBox.shrink();
          },

      decoration: InputDecoration(
        hintText: !label ? hint : null,
        labelText: label ? hint : null,
        errorText: errorText,
        hintStyle: TextStyle(color: hintColor ?? context.colors.textSecondary),
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon != null
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: suffixIcon,
              )
            : null,
        filled: true,
        fillColor: fillColor ?? context.colors.background,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: defaultBorderColor),
          borderRadius: BorderRadius.circular(borderRadius.sp),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: defaultBorderColor),
          borderRadius: BorderRadius.circular(borderRadius.sp),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: defaultFocusedBorderColor),
          borderRadius: BorderRadius.circular(borderRadius.sp),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: context.colors.error),
          borderRadius: BorderRadius.circular(borderRadius.sp),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: context.colors.error),
          borderRadius: BorderRadius.circular(borderRadius.sp),
        ),
        counterStyle: const TextStyle(height: 0, fontSize: 0),
      ),
    );
  }
}
