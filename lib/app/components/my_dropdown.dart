import 'package:kena_emotional_journey/app/styles/app_dimensions.dart';
import 'package:kena_emotional_journey/app/styles/app_radiuses.dart';
import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';
import 'package:kena_emotional_journey/app/utils/extensions/general_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MyDropdown<T> extends StatelessWidget {
  const MyDropdown({
    required this.items,
    required this.onChanged,
    super.key,
    this.value,
    this.hint,
    this.label, // This is what's causing the floating label
    this.validator,
    this.decoration,
    this.autovalidateMode,
    this.displayString,
    this.isEnabled = true,
    this.isExpanded = true,
    this.noBackground = false,
    this.backgroundColor,
    this.selectedItemColor,
    this.height,
    this.itemColor,
  });

  // ... (Your existing variables)
  final List<T> items;
  final T? value;
  final String? hint;
  final String? label;
  final void Function(T?) onChanged;
  final String? Function(T?)? validator;
  final AutovalidateMode? autovalidateMode;
  final InputDecoration? decoration;
  final String Function(T)? displayString;
  final bool isEnabled;
  final bool isExpanded;
  final bool noBackground;
  final Color? backgroundColor;
  final Color? selectedItemColor;
  final double? height;
  final Color? itemColor;

  @override
  Widget build(BuildContext context) {
    final textStyle = context.typography.body.copyWith(
      fontWeight: FontWeight.w500,
      fontSize: 14.sp,
      color: itemColor ?? context.colors.textPrimary,
    );

    final InputDecoration inputDecoration =
        decoration ??
        InputDecoration(
          hintText: hint,
          // 1. OPTION A: Set behavior to never so it stays in the center or disappears
          floatingLabelBehavior: FloatingLabelBehavior.never,
          // 2. OPTION B: If you don't want any text there at all,
          // you can pass null to labelText when using the widget.
          labelText: label,

          filled: !noBackground,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 12.w,
            vertical: height != null ? 0 : 12.h,
          ),
          fillColor:
              backgroundColor ??
              (noBackground
                  ? Colors.transparent
                  : context.colors.inputBackground),
          enabledBorder: noBackground
              ? InputBorder.none
              : OutlineInputBorder(
                  borderSide: BorderSide(
                    color: context.colors.textSecondary.withOpacity(0.3),
                  ),
                  borderRadius: BorderRadius.circular(AppRadiuses.mediumRadius),
                ),
          focusedBorder: noBackground
              ? InputBorder.none
              : OutlineInputBorder(
                  borderSide: BorderSide(
                    color: context.colors.textSecondary.withOpacity(0.3),
                  ),
                  borderRadius: BorderRadius.circular(AppRadiuses.mediumRadius),
                ),
        );

    return SizedBox(
      height: height?.h,
      child: DropdownButtonFormField<T>(
        isExpanded: isExpanded,
        isDense: height != null,
        value: value,
        validator: validator,
        autovalidateMode: autovalidateMode,
        onChanged: isEnabled ? onChanged : null,
        icon: Icon(
          Icons.keyboard_arrow_down_rounded,
          color: itemColor ?? context.colors.textPrimary,
        ),
        style: textStyle,
        decoration: inputDecoration,
        dropdownColor: backgroundColor ?? context.colors.inputBackground,
        menuMaxHeight: context.mediaQueryHeight * 0.5,
        elevation: 2,
        borderRadius: BorderRadius.circular(AppDimensions.medium),
        items: items.map((e) {
          final isSelected = e == value;
          return DropdownMenuItem<T>(
            value: e,
            child: Text(
              displayString?.call(e) ?? e.toString(),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: textStyle.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? (selectedItemColor ??
                          itemColor ??
                          context.colors.inputText)
                    : (itemColor ?? context.colors.textPrimary),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
