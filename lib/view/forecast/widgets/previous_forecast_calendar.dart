import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';
import 'package:kena_emotional_journey/model/analytics/month_data_model.dart';

class CalendarDay {
  DateTime date;
  bool hasData;

  CalendarDay({required this.date, required this.hasData});
}

class PreviousForecastCalendar extends StatefulWidget {
  final Function(DateTime)? onDateSelected;
  final Function(DateTime)? onMonthChanged;
  final List<DateTime> datesWithData;
  final Map<String, MonthDay> monthDaysData;
  final DateTime initialDate;
  final bool isAnalytics;

  const PreviousForecastCalendar({
    super.key,
    this.onDateSelected,
    this.onMonthChanged,
    this.datesWithData = const [],
    this.monthDaysData = const {},
    this.isAnalytics = false,
    required this.initialDate,
  });

  @override
  State<PreviousForecastCalendar> createState() =>
      _PreviousForecastCalendarState();
}

class _PreviousForecastCalendarState extends State<PreviousForecastCalendar> {
  late DateTime selectedDate;

  /// First day of the month currently shown in the day strip.
  late DateTime currentMonth;

  final List<CalendarDay> visibleDays = [];
  final ScrollController _scrollController = ScrollController();

  // Fixed width per day cell so the horizontal list can scroll to an exact
  // offset (see `_scrollToSelectedDate`). Keep this in sync with the
  // padding/width used inside `_buildDayItem`.
  static const double _dayItemWidth = 52;

  // Consistent color palette matching Screenshot 2026-07-03 at 1.06.01 PM.png
  final List<Color> analyticalDots = [
    const Color(0xFF1E5631), // Dark Green (Core)
    const Color(0xFF0000FF), // Blue (Activity)
    const Color(0xFFFF0000), // Red (Forecast)
    const Color(0xFFFFD700), // Yellow (Reflection)
  ];

  @override
  void initState() {
    super.initState();
    selectedDate = widget.initialDate;
    currentMonth = DateTime(widget.initialDate.year, widget.initialDate.month);
    generateVisibleDays(currentMonth);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedDate(animate: false);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  bool _areListsEqual(List<DateTime> a, List<DateTime> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (!isSameDay(a[i], b[i])) return false;
    }
    return true;
  }

  void _updateVisibleDaysDataFlags() {
    for (var day in visibleDays) {
      final formattedDay = DateFormat('yyyy-MM-dd').format(day.date);
      final monthDay = widget.monthDaysData[formattedDay];
      final bool hasMonthData =
          monthDay != null &&
          (monthDay.forecast == true ||
              monthDay.core == true ||
              monthDay.activity == true ||
              monthDay.reflection == true ||
              monthDay.aspirational == true);

      day.hasData =
          hasMonthData ||
          widget.datesWithData.any(
            (d) =>
                d.year == day.date.year &&
                d.month == day.date.month &&
                d.day == day.date.day,
          );
    }
    setState(() {});
  }

  @override
  void didUpdateWidget(covariant PreviousForecastCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);

    final bool dateChanged = !isSameDay(widget.initialDate, selectedDate);
    final bool sameMonthAsCurrent =
        widget.initialDate.year == currentMonth.year &&
        widget.initialDate.month == currentMonth.month;

    if (dateChanged && !sameMonthAsCurrent) {
      selectedDate = widget.initialDate;
      currentMonth = DateTime(
        widget.initialDate.year,
        widget.initialDate.month,
      );
      generateVisibleDays(currentMonth);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToSelectedDate(animate: false);
      });
    } else if (dateChanged) {
      setState(() {
        selectedDate = widget.initialDate;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToSelectedDate();
      });
    } else if (!_areListsEqual(oldWidget.datesWithData, widget.datesWithData) ||
        oldWidget.monthDaysData != widget.monthDaysData) {
      _updateVisibleDaysDataFlags();
    }
  }

  /// Builds every day of [month] (1st through the last day) into
  /// [visibleDays], so the strip can scroll across the whole month.
  void generateVisibleDays(DateTime month) {
    visibleDays.clear();
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(month.year, month.month, day);
      final formattedDay = DateFormat('yyyy-MM-dd').format(date);
      final monthDay = widget.monthDaysData[formattedDay];

      final bool hasMonthData =
          monthDay != null &&
          (monthDay.forecast == true ||
              monthDay.core == true ||
              monthDay.activity == true ||
              monthDay.reflection == true ||
              monthDay.aspirational == true);

      final hasData =
          hasMonthData ||
          widget.datesWithData.any(
            (d) =>
                d.year == date.year &&
                d.month == date.month &&
                d.day == date.day,
          );
      visibleDays.add(CalendarDay(date: date, hasData: hasData));
    }
    setState(() {});
  }

  String get currentMonthTitle => DateFormat('MMMM yyyy').format(currentMonth);

  void selectDate(DateTime date) {
    if (isDisabled(date)) return;
    setState(() {
      selectedDate = date;
    });
    widget.onDateSelected?.call(date);
  }

  /// Moves the day strip to the previous month. Selection is left
  /// untouched — this only changes what's being browsed.
  void previousMonth() {
    currentMonth = DateTime(currentMonth.year, currentMonth.month - 1);
    generateVisibleDays(currentMonth);
    widget.onMonthChanged?.call(currentMonth);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(0);
    });
  }

  /// Moves the day strip to the next month, if allowed (see [_canGoNext]).
  void nextMonth() {
    if (!_canGoNext) return;
    currentMonth = DateTime(currentMonth.year, currentMonth.month + 1);
    generateVisibleDays(currentMonth);
    widget.onMonthChanged?.call(currentMonth);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(0);
    });
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  DateTime get _today {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  bool isDisabled(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    if (widget.isAnalytics) {
      return normalized.isAfter(_today);
    }
    return normalized.isAfter(_today) || isSameDay(normalized, _today);
  }

  /// You can't browse into a future month — the current calendar month is
  /// as far forward as the strip goes.
  bool get _canGoNext {
    return !(currentMonth.year == _today.year &&
        currentMonth.month == _today.month);
  }

  /// Centers the day strip on [selectedDate], if it's part of the
  /// currently displayed month.
  void _scrollToSelectedDate({bool animate = true}) {
    if (!_scrollController.hasClients) return;

    final index = visibleDays.indexWhere(
      (d) => isSameDay(d.date, selectedDate),
    );
    if (index == -1) return;

    final viewportWidth = _scrollController.position.viewportDimension;
    final targetOffset =
        (_dayItemWidth * index) - (viewportWidth / 2) + (_dayItemWidth / 2);
    final clampedOffset = targetOffset.clamp(
      0.0,
      _scrollController.position.maxScrollExtent,
    );

    if (animate) {
      _scrollController.animateTo(
        clampedOffset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _scrollController.jumpTo(clampedOffset);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // --- CALENDAR HEADER CONTROLS ---
        Row(
          children: [
            IconButton(
              onPressed: previousMonth,
              icon: Icon(
                Icons.keyboard_double_arrow_left,
                color: context.colors.primary,
                size: 26.sp,
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  currentMonthTitle,
                  style: context.typography.body.copyWith(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w600,
                    color: context.colors.textPrimary,
                    fontFamily: 'sfpro',
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: _canGoNext ? nextMonth : null,
              icon: Icon(
                Icons.keyboard_double_arrow_right,
                color: _canGoNext
                    ? context.colors.primary
                    : context.colors.textSecondary.withValues(alpha: 0.3),
                size: 26.sp,
              ),
            ),
          ],
        ),

        // --- ANALYTICS LEGEND BLOCK ---
        if (widget.isAnalytics) ...[
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SectionColorCard(
                  color: const Color(0xFF0000FF),
                  label: "Activity",
                ),
                SectionColorCard(color: const Color(0xFF1E5631), label: "Core"),
                SectionColorCard(
                  color: const Color(0xFF00BFFF),
                  label: "Aspirational",
                ),
                SectionColorCard(
                  color: const Color(0xFFFF0000),
                  label: "Forecast",
                ),
                SectionColorCard(
                  color: const Color(0xFFFFD700),
                  label: "Reflection",
                ),
              ],
            ),
          ),
          SizedBox(height: 14.h),
        ] else ...[
          SizedBox(height: 5.h),
        ],

        // --- SCROLLABLE DAY STRIP ---
        SizedBox(
          height: 100.h,
          child: ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            itemExtent: _dayItemWidth.w,
            itemCount: visibleDays.length,
            itemBuilder: (context, index) => _buildDayItem(visibleDays[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildDayItem(CalendarDay day) {
    final isSelected = isSameDay(day.date, selectedDate);
    final disabled = isDisabled(day.date);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: disabled ? null : () => selectDate(day.date),
      child: Opacity(
        opacity: disabled ? 0.4 : 1.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // E.g., Sun, Mon, Tue
            Text(
              DateFormat('E').format(day.date),
              style: context.typography.body.copyWith(
                color: context.colors.textPrimary,
                fontSize: 14.sp,
                fontFamily: 'sfpro',
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8.h),

            // Day Number Circle Container
            Container(
              width: 36.sp,
              height: 36.sp,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFF2F2F2),
                border: Border.all(
                  color: isSelected && !disabled
                      ? context.colors.primary
                      : Colors.transparent,
                  width: 1.5.w,
                ),
              ),
              child: Text(
                day.date.day.toString(),
                style: TextStyle(
                  color: context.colors.textPrimary,
                  fontWeight: FontWeight.w500,
                  fontSize: 14.sp,
                  fontFamily: 'sfpro',
                ),
              ),
            ),
            SizedBox(height: 8.h),

            // --- DOT INDICATOR ---
            if (widget.isAnalytics)
              Builder(
                builder: (context) {
                  final formattedDay = DateFormat(
                    'yyyy-MM-dd',
                  ).format(day.date);
                  final monthDay = widget.monthDaysData[formattedDay];

                  final dots = [
                    _AnalyticsDot(
                      const Color(0xFF0000FF),
                      monthDay?.activity == true,
                    ),
                    _AnalyticsDot(
                      const Color(0xFF1E5631),
                      monthDay?.core == true,
                    ),
                    _AnalyticsDot(
                      const Color(0xFF00BFFF),
                      monthDay?.aspirational == true,
                    ),
                    _AnalyticsDot(
                      const Color(0xFFFF0000),
                      monthDay?.forecast == true,
                    ),
                    _AnalyticsDot(
                      const Color(0xFFFFD700),
                      monthDay?.reflection == true,
                    ),
                  ];

                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: dots.map((dot) {
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 1.w),
                        child: Container(
                          width: 5.w,
                          height: 5.w,
                          decoration: BoxDecoration(
                            color: (!disabled && dot.active)
                                ? dot.color
                                : Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              )
            else
              Container(
                width: 6.w,
                height: 6.w,
                decoration: BoxDecoration(
                  color: (isSelected || day.hasData) && !disabled
                      ? context.colors.primary
                      : Colors.transparent,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class SectionColorCard extends StatelessWidget {
  final Color color;
  final String label;
  const SectionColorCard({super.key, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10.w,
          height: 10.w,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 4.w),
        Text(
          label,
          style: context.typography.body.copyWith(
            color: context.colors.textPrimary,
            fontFamily: 'sfpro',
            fontSize: 10.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _AnalyticsDot {
  final Color color;
  final bool active;
  const _AnalyticsDot(this.color, this.active);
}
