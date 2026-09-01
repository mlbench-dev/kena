import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';

class MonthCalendar extends StatefulWidget {
  final DateTime targetMonth;
  final List<int> selectedDays;
  final ValueChanged<int> onDayToggled;

  const MonthCalendar({
    super.key,
    required this.targetMonth,
    required this.selectedDays,
    required this.onDayToggled,
  });

  @override
  State<MonthCalendar> createState() => _MonthCalendarState();
}

class _MonthCalendarState extends State<MonthCalendar> {
  // Weekday header labels matching your design text properties
  final List<String> _weekdays = [
    "Sun",
    "Mon",
    "Tue",
    "Wed",
    "Thu",
    "Fri",
    "Sat",
  ];

  @override
  Widget build(BuildContext context) {
    // 1. Calculate structural metrics for the targeted month matrix
    final int totalDaysInMonth = DateUtils.getDaysInMonth(
      widget.targetMonth.year,
      widget.targetMonth.month,
    );

    // Find the day of the week the 1st falls on (1 = Monday, 7 = Sunday)
    final DateTime firstDayOfMonth = DateTime(
      widget.targetMonth.year,
      widget.targetMonth.month,
      1,
    );

    // Convert native weekday index (where Mon=1, Sun=7) to match design grid orientation (where Sun=0, Mon=1)
    final int emptyLeadingSpaces = firstDayOfMonth.weekday == 7
        ? 0
        : firstDayOfMonth.weekday;

    final int totalGridItems = emptyLeadingSpaces + totalDaysInMonth;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── WEEKDAY TEXT HEADER LABELS ROW ──
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _weekdays.map((day) {
              return SizedBox(
                width: 40.w,
                child: Text(
                  day,
                  textAlign: TextAlign.center,
                  style: context.typography.body.copyWith(
                    fontSize: 14.sp,
                    fontFamily: 'sfpro',
                    fontWeight: FontWeight.w500,
                    color: context.colors.textPrimary,
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        // ── CALENDAR DATE GRID CELL CANVAS ──
        GridView.builder(
          shrinkWrap: true,
          physics:
              const NeverScrollableScrollPhysics(), // Delegates scroll controls to container body
          itemCount: totalGridItems,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7, // 7 Days in a structural calendar week matrix
            mainAxisSpacing: 12.h,
            crossAxisSpacing: 8.w,
          ),
          itemBuilder: (context, index) {
            // Check if index points to a leading blank padding block
            if (index < emptyLeadingSpaces) {
              return const SizedBox.shrink();
            }

            // Calculate the actual calendar day integer
            final int dayNumber = index - emptyLeadingSpaces + 1;
            final bool isSelected = widget.selectedDays.contains(dayNumber);

            return Center(
              child: _buildDateCircleToken(
                dayNumber: dayNumber,
                isSelected: isSelected,
                onTap: () => widget.onDayToggled(dayNumber),
              ),
            );
          },
        ),
      ],
    );
  }

  // Visual template rendering the circular buttons matching your image exactly
  Widget _buildDateCircleToken({
    required int dayNumber,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final Color activeGreen = context.colors.tertiary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 38.w,
        height: 38.w,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          // Select toggle turns green if configured, or keeps a premium light off-grey circle look
          color: isSelected ? activeGreen : const Color(0xFFF1F3F4),
          border: isSelected ? Border.all(color: activeGreen, width: 1) : null,
        ),
        child: Text(
          '$dayNumber',
          style: context.typography.body.copyWith(
            fontSize: 14.sp,
            fontFamily: 'sfpro',
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w400,
            color: isSelected ? Colors.white : context.colors.textPrimary,
          ),
        ),
      ),
    );
  }
}
