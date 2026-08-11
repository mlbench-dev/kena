import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MyFormTextField extends StatelessWidget {
  const MyFormTextField({
    super.key,
    this.controller,
    this.hint,
    this.label = false,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.obscureText = false,
    // this.textCapitalization = TextCapitalization.none,
    this.textInputAction = TextInputAction.done,
    this.textAlign = TextAlign.start,
    this.maxLength,
    this.maxLines,
    this.validator,
    this.autovalidateMode,
    this.onSaved,
    this.initialValue,
    this.readOnly = false,
    this.borderRadius = 16.0,
    this.onChanged,
    this.errorText,
    this.isDark = true,
    this.focusNode,
    this.backgroundColor,
    this.onFieldSubmitted,
    this.hintColor,
    this.fillColor,
    this.textColor,
    this.cursorColor,
    this.minLines,
    this.contentPadding,
  });

  final TextEditingController? controller;
  final String? hint;
  final bool label;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final bool obscureText;
  // final TextCapitalization textCapitalization;
  final TextInputAction? textInputAction;
  final TextAlign textAlign;
  final int? maxLength;
  final int? maxLines;
  final int? minLines;
  final String? Function(String?)? validator;
  final AutovalidateMode? autovalidateMode;
  final void Function(String?)? onSaved;
  final String? initialValue;
  final bool readOnly;
  final double borderRadius;
  final void Function(String)? onChanged;
  final void Function(String)? onFieldSubmitted;
  final String? errorText;
  final bool isDark;
  final FocusNode? focusNode;
  final Color? backgroundColor;
  final Color? hintColor;
  final Color? textColor;
  final Color? cursorColor;
  final Color? fillColor;
  final EdgeInsetsGeometry? contentPadding;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onFieldSubmitted: onFieldSubmitted,
      style: TextStyle(
        color:
            textColor ??
            (isDark ? context.colors.textOnDark : context.colors.textOnLight),
      ),

      focusNode: focusNode,
      onChanged: onChanged,
      controller: controller,
      initialValue: initialValue,
      enabled: !readOnly,
      cursorColor:
          cursorColor ??
          (isDark ? context.colors.inputIcon : context.colors.inputIconLight),
      textCapitalization: TextCapitalization.none,
      textInputAction: textInputAction,

      textAlign: textAlign,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLength: maxLength,
      minLines: minLines ?? 1,
      maxLines: maxLines ?? 1,
      validator: validator,
      onSaved: onSaved,
      autovalidateMode: autovalidateMode,
      decoration: InputDecoration(
        errorText: errorText,
        errorMaxLines: 3,
        hintText: !label ? hint : null,
        labelText: label ? hint : null,
        prefixIcon: prefixIcon,
        hintStyle: context.typography.body.copyWith(
          fontSize: 13.sp,
          fontWeight: FontWeight.w300,
          fontFamily: "sfpro",
          color:
              hintColor ??
              (isDark
                  ? context.colors.inputBorder
                  : context.colors.textOnLight),
        ),
        suffixIcon: suffixIcon != null
            ? Padding(
                padding: EdgeInsets.only(right: 16.w),
                child: suffixIcon,
              )
            : null,
        fillColor: fillColor ?? Colors.transparent,
        // backgroundColor ??
        // (isDark
        //     ? context.colors.inputBackground
        //     : context.colors.inputBackgroundLight.withValues(alpha: .2)),
        filled: true,
        contentPadding:
            contentPadding ??
            EdgeInsets.symmetric(horizontal: 16.w, vertical: 15.h),
        border: OutlineInputBorder(
          borderSide: BorderSide(
            color: isDark
                ? context.colors.inputBorder.withValues(alpha: 0.10)
                : context.colors.inputBorderLight.withValues(alpha: 0.10),
          ),
          borderRadius: BorderRadius.circular(borderRadius.sp),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: isDark
                ? context.colors.textSecondary.withValues(alpha: 0.3)
                : context.colors.textSecondary.withValues(alpha: 0.3),
          ),
          borderRadius: BorderRadius.circular(borderRadius.sp),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: isDark
              ? BorderSide(color: context.colors.error)
              : BorderSide(color: context.colors.error),
          borderRadius: BorderRadius.circular(borderRadius.sp),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: isDark
              ? BorderSide(color: context.colors.error)
              : BorderSide(color: context.colors.error),
          borderRadius: BorderRadius.circular(borderRadius.sp),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: isDark
                ? context.colors.textSecondary.withValues(alpha: 0.8)
                : context.colors.textSecondary.withValues(alpha: 0.8),
          ),
          borderRadius: BorderRadius.circular(borderRadius.sp),
        ),
      ),
    );
  }
}
