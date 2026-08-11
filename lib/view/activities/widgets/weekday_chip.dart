import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';

class WeekdayChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const WeekdayChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        constraints: BoxConstraints(minWidth: 32.w),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          // Background turns white if selected, otherwise stays light grey tint
          color: isSelected ? Colors.white : const Color(0xFFE9EEEB),
          borderRadius: BorderRadius.circular(6.r),
          border: Border.all(
            color: isSelected ? context.colors.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: context.typography.body.copyWith(
            fontSize: 12.sp,
            fontFamily: 'sfpro',
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w400,
            color: context.colors.primary,
          ),
        ),
      ),
    );
  }
}
