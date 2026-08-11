import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';

class KenaDropdown extends StatelessWidget {
  final String? value;
  final List<String> options;
  final String hintText;
  final ValueChanged<String?> onChanged;

  const KenaDropdown({
    super.key,
    required this.value,
    required this.options,
    required this.onChanged,
    this.hintText = "Select Option",
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      hint: Text(
        hintText,
        style: context.typography.body.copyWith(
          fontSize: 15.sp,
          fontFamily: 'sfpro',
          color: context.colors.textSecondary,
        ),
      ),
      // Style the popup container layout background card
      dropdownColor: Colors.white,
      icon: Icon(
        Icons.keyboard_arrow_down,
        color: context.colors.textPrimary,
        size: 22.sp,
      ),
      // Clean custom input decoration layout to match input fields
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        filled: true,
        fillColor: const Color(0xFFF1F3F5), // Soft gray premium token look
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: Color(0xFFE5E5E5), width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: context.colors.primary, width: 1.5),
        ),
      ),
      items: options.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(
            item, // Formats output cleanly (e.g. "First Week")
            style: context.typography.body.copyWith(
              fontSize: 15.sp,
              fontFamily: 'sfpro',
              color: context.colors.textPrimary,
            ),
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}
