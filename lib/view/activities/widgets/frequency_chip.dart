import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';

class FrequencyChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback? onTap;
  const FrequencyChip({
    super.key,
    required this.label,
    required this.isActive,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
        decoration: BoxDecoration(
          color: isActive ? context.colors.background : Color(0xFFE9EEEB),
          borderRadius: BorderRadius.circular(3.r),
          border: Border.all(
            color: isActive ? context.colors.primary : Colors.transparent,
            width:
                1.5, // Fixed width keeps the chip size stable on click transitions
          ),
        ),
        child: Text(
          label,
          style: context.typography.body.copyWith(
            fontSize: 10.sp,
            fontFamily: 'sfpro',
            fontWeight: isActive ? FontWeight.bold : FontWeight.w400,
            color: context.colors.primary,
          ),
        ),
      ),
    );
  }
}
