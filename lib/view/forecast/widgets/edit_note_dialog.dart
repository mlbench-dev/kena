import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kena_emotional_journey/app/components/my_button.dart';
import 'package:kena_emotional_journey/app/components/my_text_field.dart';
import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';

class EditNotesDialog extends StatelessWidget {
  final TextEditingController controller;
  final TextCapitalization textCapitalization;
  final VoidCallback onSave;

  const EditNotesDialog({
    super.key,
    required this.controller,
    required this.onSave,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: context.colors.background,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Edit Notes',
            style: context.typography.headline.copyWith(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 20.h),
          MyTextField(
            // textCapitalization: textCapitalization,
            controller: controller,
            maxLines: 5,
            hint: 'Enter your notes...',
            fillColor: context.colors.background,
            borderColor: const Color(0xFFd0d0d0),
          ),
          SizedBox(height: 20.h),
          MyButton(label: 'Save', onPressed: onSave),
        ],
      ),
    );
  }
}
