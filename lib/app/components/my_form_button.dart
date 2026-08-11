import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MyFormButton extends StatelessWidget {
  const MyFormButton({
    required this.text,
    required this.onPressed,
    super.key,
    this.borderRadius = 100.0,
    this.icon,
    this.height,
  });

  final String text;
  final VoidCallback? onPressed;
  final double borderRadius;
  final Widget? icon;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(borderRadius.sp),
      onTap: onPressed,
      child: Container(
        height: height ?? 48.h,
        padding: EdgeInsets.fromLTRB(16.w, 13.h, 4.w, 13.h),
        decoration: BoxDecoration(
          color: context.colors.inputBackground,
          borderRadius: BorderRadius.circular(borderRadius.sp),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                style: context.typography.body.copyWith(
                  color: context.colors.inputText,
                ),
              ),
            ),
            icon ??
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: context.colors.inputIcon,
                  size: 20.w,
                ),
            SizedBox(width: 12.w),
          ],
        ),
      ),
    );
  }
}
