import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';

class YearPickerDropdown extends StatelessWidget {
  final String currentMonthName;
  final DateTime currentViewMonth;
  final ValueChanged<int> onYearChanged;
  final int startYear;
  final int yearRange;

  const YearPickerDropdown({
    super.key,
    required this.currentMonthName,
    required this.currentViewMonth,
    required this.onYearChanged,
    this.startYear = 2026, // Configurable start year
    this.yearRange = 7, // Generates 7 years by default (2024 to 2030)
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      tooltip: 'Select Year',
      color: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      offset: Offset(0, 40.h),
      onSelected: onYearChanged,
      itemBuilder: (BuildContext context) {
        return List.generate(yearRange, (index) {
          final int year = startYear + index;
          final bool isCurrentYear = year == currentViewMonth.year;

          return PopupMenuItem<int>(
            value: year,
            height: 38.h,
            child: Container(
              width: 100.w,
              alignment: Alignment.center,
              child: Text(
                "$year",
                style: context.typography.body.copyWith(
                  fontSize: 15.sp,
                  fontFamily: 'sfpro',
                  fontWeight: isCurrentYear ? FontWeight.bold : FontWeight.w400,
                  color: isCurrentYear
                      ? context.colors.primary
                      : context.colors.textPrimary,
                ),
              ),
            ),
          );
        });
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "$currentMonthName ${currentViewMonth.year}",
            style: context.typography.headline.copyWith(
              fontSize: 22.sp,
              fontWeight: FontWeight.w600,
              fontFamily: 'sfpro',
              color: context.colors.textPrimary,
            ),
          ),
          SizedBox(width: 4.w),
          Icon(
            Icons.keyboard_arrow_down,
            color: context.colors.textPrimary,
            size: 20.sp,
          ),
        ],
      ),
    );
  }
}
