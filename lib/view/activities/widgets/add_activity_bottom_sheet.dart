import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kena_emotional_journey/app/components/my_button.dart';
import 'package:kena_emotional_journey/app/components/my_text_field.dart';
import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';

class AddActivityBottomSheet extends StatefulWidget {
  final TextEditingController controller;
  final String title;
  final String hint;
  final String saveButtonText;
  final VoidCallback onCancel;
  final Future<void> Function(String activityName) onSave;

  const AddActivityBottomSheet({
    super.key,
    required this.controller,
    required this.onSave,
    required this.onCancel,
    this.title = "Add your own activity",
    this.hint = "Enter activity name",
    this.saveButtonText = "Save",
  });

  @override
  State<AddActivityBottomSheet> createState() => _AddActivityBottomSheetState();
}

class _AddActivityBottomSheetState extends State<AddActivityBottomSheet> {
  /// Inline validation message shown under the field (instead of a flushbar).
  String? _errorText;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                height: 5.h,
                width: 54.w,
                decoration: BoxDecoration(
                  color: const Color(0xFF6b6e80),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 10.h),

            Center(
              child: Text(
                widget.title,
                style: context.typography.body.copyWith(
                  color: context.colors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 18.sp,
                ),
              ),
            ),

            SizedBox(height: 20.h),

            Text(
              "Activity Name",
              style: context.typography.body.copyWith(
                color: context.colors.textPrimary,
                fontSize: 15.sp,
                fontWeight: FontWeight.w500,
              ),
            ),

            SizedBox(height: 10.h),

            MyTextField(
              controller: widget.controller,
              maxLength: 20,
              hint: widget.hint,
              fillColor: Colors.transparent,
              borderColor: context.colors.textSecondary.withValues(alpha: 0.3),
              errorText: _errorText,
              onChanged: (_) {
                if (_errorText != null) setState(() => _errorText = null);
              },
            ),

            SizedBox(height: 20.h),

            MyButton(
              label: widget.saveButtonText,
              onPressed: () async {
                final name = widget.controller.text.trim();

                if (name.isEmpty) {
                  setState(() => _errorText = "Please enter an activity name.");
                  return;
                }

                await widget.onSave(name);
              },
            ),

            SizedBox(height: 10.h),

            MyButton(
              label: "Cancel",
              onPressed: widget.onCancel,
              backgroundColor: Colors.transparent,
              borderWidth: 1,
              borderColor: context.colors.primary,
              textColor: context.colors.primary,
            ),
          ],
        ),
      ),
    );
  }
}
