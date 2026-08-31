import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kena_emotional_journey/app/components/my_button.dart';
import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';

class NoInternetDialog extends StatelessWidget {
  const NoInternetDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20.r)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.wifi_off_rounded,
            size: 40.sp,
            color: context.colors.error,
          ),
          SizedBox(height: 12.h),
          Text(
            "No Internet Connection",
            style: context.typography.title.copyWith(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: context.colors.textPrimary,
              fontFamily: "Raleway",
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            "Please enable your internet to access this.",
            textAlign: TextAlign.center,
            style: context.typography.title.copyWith(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: context.colors.textSecondary,
              fontFamily: "Raleway",
            ),
          ),
          SizedBox(height: 20.h),
          MyButton(
            fontWeight: FontWeight.w600,
            label: "OK",
            onPressed: () => Navigator.pop(context),
            backgroundColor: context.colors.primary,
          ),
        ],
      ),
    );
  }
}
