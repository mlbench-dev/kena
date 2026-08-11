import 'package:kena_emotional_journey/app/styles/app_dimensions.dart';
import 'package:kena_emotional_journey/app/styles/app_radiuses.dart';
import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pinput/pinput.dart';

class MyPinput extends StatelessWidget {
  const MyPinput({
    required this.controller,
    super.key,
    this.focusNode,
    this.length = 4,
    this.validator,
    this.onCompleted,
    this.onChanged,
    this.enabled = true,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final int length;
  final bool enabled;
  final String? Function(String?)? validator;
  final void Function(String)? onCompleted;
  final void Function(String)? onChanged;

  @override
  Widget build(BuildContext context) {
    final basePinTheme = PinTheme(
      width: 60.w,
      height: 60.h,
      textStyle: TextStyle(
        fontSize: 20.sp,
        color: context.colors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        // shape: BoxShape.circle,
        color: context.colors.background,
        borderRadius: BorderRadius.circular(AppRadiuses.largeRadius),
        border: Border.all(
          color: context.colors.inputBorder.withValues(alpha: .9),
        ),
      ),
    );

    return Pinput(
      controller: controller,
      focusNode: focusNode,
      enabled: enabled,
      length: length,
      defaultPinTheme: basePinTheme,
      focusedPinTheme: basePinTheme.copyWith(
        decoration: basePinTheme.decoration!.copyWith(
          border: Border.all(color: context.colors.inputBorder),
        ),
      ),
      submittedPinTheme: basePinTheme.copyWith(),
      errorPinTheme: basePinTheme.copyWith(
        decoration: basePinTheme.decoration!.copyWith(
          border: Border.all(color: context.colors.error),
        ),
      ),
      separatorBuilder: (index) => SizedBox(width: AppDimensions.mediumSmall),
      validator: validator,
      onCompleted: onCompleted,
      onChanged: onChanged,
      hapticFeedbackType: HapticFeedbackType.lightImpact,
    );
  }
}
