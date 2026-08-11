import 'package:kena_emotional_journey/app/components/global_unfocus_keyboard.dart';
import 'package:kena_emotional_journey/app/components/my_bottom_sheet.dart';
import 'package:kena_emotional_journey/app/components/my_button.dart';
import 'package:kena_emotional_journey/app/styles/app_dimensions.dart';
import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';
import 'package:kena_emotional_journey/l10n/l10n.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MyDatePickerButton extends StatelessWidget {
  const MyDatePickerButton({
    required this.hintText,
    required this.selectedDate,
    required this.onChanged,
    this.validator,
    super.key,
    this.isExpanded = false,
    this.suffixIcon,
  });

  final String hintText;
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onChanged;
  final String? Function(DateTime?)? validator;
  final bool isExpanded;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return FormField<DateTime>(
      initialValue: selectedDate,
      validator: validator,
      builder: (FormFieldState<DateTime> state) {
        final border = OutlineInputBorder(
          borderRadius: BorderRadius.circular(120.r),
          borderSide: BorderSide(
            color: state.hasError
                ? Colors.red
                : (selectedDate == null
                      ? context.colors.inputBorder.withValues(alpha: 0.10)
                      : context.colors.inputBorder.withValues()),
          ),
        );

        final textStyle = context.typography.subtitle.copyWith(
          color: context.colors.textOnDark,
          fontWeight: FontWeight.w500,
          fontSize: 14.sp,
        );

        final child = InkWell(
          onTap: () => _showDatePicker(context, state),
          borderRadius: BorderRadius.circular(120.r),
          child: InputDecorator(
            isEmpty: selectedDate == null,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                horizontal: 20.w,
                vertical: 14.h,
              ),
              hintText: hintText,
              hintStyle: textStyle.copyWith(
                color: context.colors.textSecondary,
              ),
              border: border,
              enabledBorder: border,
              focusedBorder: border,
              errorText: state.errorText, // <- shows validation error
              suffixIcon: Padding(
                padding: EdgeInsets.only(right: 16.w),
                child: suffixIcon,
              ),
            ),
            child: selectedDate != null
                ? Text(_formatDate(selectedDate!), style: textStyle)
                : null,
          ),
        );

        return isExpanded ? Expanded(child: child) : child;
      },
    );
  }

  void _showDatePicker(BuildContext context, FormFieldState<DateTime> state) {
    DateTime tempPicked = selectedDate ?? DateTime.now();
    MyBottomSheet.show<void>(
      context,
      enableDrag: true,
      isDismissible: true,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppDimensions.medium),
        child: SizedBox(
          height: 300,
          child: Column(
            children: [
              Expanded(
                child: CupertinoDatePicker(
                  initialDateTime: tempPicked,
                  mode: CupertinoDatePickerMode.date,
                  maximumDate: DateTime(2100),
                  minimumDate: DateTime(1900),
                  onDateTimeChanged: (value) {
                    tempPicked = value;
                  },
                ),
              ),
              MyButton(
                label: context.l10n.done,
                onPressed: () {
                  GlobalUnfocusKeyboard.hideKeyboard(context);
                  Navigator.pop(context);
                  onChanged(tempPicked);
                  state.didChange(tempPicked); // Update form state
                },
              ),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
