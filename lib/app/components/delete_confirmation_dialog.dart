import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kena_emotional_journey/app/components/my_button.dart';
import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';

/// Generic "are you sure?" confirmation dialog for destructive delete
/// actions. Pops itself before invoking [onConfirm], so callers don't need
/// to pop the dialog themselves inside the callback.
class DeleteConfirmationDialog extends StatelessWidget {
  const DeleteConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    required this.onConfirm,
    this.confirmLabel = "Yes Delete",
    this.cancelLabel = "Cancel",
  });

  final String title;
  final String message;
  final VoidCallback onConfirm;
  final String confirmLabel;
  final String cancelLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20.r)),
      child: Column(
        mainAxisSize: MainAxisSize.min, // allow height to wrap content
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: context.typography.title.copyWith(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: context.colors.textPrimary,
              fontFamily: "Raleway",
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            message,
            textAlign: TextAlign.center,
            style: context.typography.title.copyWith(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: context.colors.textSecondary,
              fontFamily: "Raleway",
            ),
          ),
          SizedBox(height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: context.colors.textSecondary.withValues(
                        alpha: 0.2,
                      ),
                      borderRadius: BorderRadius.circular(15.r),
                    ),
                    child: Center(
                      child: Text(
                        cancelLabel,
                        style: context.typography.title.copyWith(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: context.colors.textPrimary,
                          fontFamily: "Raleway",
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: MyButton(
                  fontWeight: FontWeight.w600,
                  label: confirmLabel,
                  onPressed: () {
                    Navigator.pop(context);
                    onConfirm();
                  },
                  backgroundColor: context.colors.tertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
