import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kena_emotional_journey/app/components/my_button.dart';
import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';
import 'package:kena_emotional_journey/services/common/auth_service.dart';

class DeleteAccountDialog extends StatelessWidget {
  const DeleteAccountDialog({super.key, required AuthService authService})
    : _authService = authService;

  final AuthService _authService;

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
            "Delete Account",
            style: context.typography.title.copyWith(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: context.colors.textPrimary,
              fontFamily: "Raleway",
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            "Are you sure you want to delete your account? All the account details will be deleted permanently.",
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
                        "Cancel",
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
                  label: "Yes Delete",
                  onPressed: () => _authService.deleteAccount(context),
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
