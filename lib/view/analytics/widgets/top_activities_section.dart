import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';

class ActivityDataModel {
  final String name;
  final double currentDays;
  final double maxDays;
  final Color? barColor; // Optional active bar color
  final Color?
  trackingBarColor; // 👈 Added optional background track color parameter
  final String? title;
  final String? displayValue; // Overrides the "X days" label when set
  ActivityDataModel({
    required this.name,
    required this.currentDays,
    this.maxDays = 7.0,
    this.barColor,
    this.title,
    this.trackingBarColor, // 👈 Initialized in constructor
    this.displayValue,
  });
}

class TopActivitiesFlSection extends StatefulWidget {
  final List<ActivityDataModel> activities;

  const TopActivitiesFlSection({super.key, required this.activities});

  @override
  State<TopActivitiesFlSection> createState() => _TopActivitiesFlSectionState();
}

class _TopActivitiesFlSectionState extends State<TopActivitiesFlSection> {
  // Keeps track of which activity index is currently tapped to show its value
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Section Card Header
          Text(
            widget.activities.isNotEmpty
                ? (widget.activities.first.title ?? "Top 5 Activities")
                : "Top 5 Activities",
            style: context.typography.title.copyWith(
              fontWeight: FontWeight.w600,
              color: context.colors.textPrimary,
              fontSize: 18.sp,
              fontFamily: "Inter",
            ),
          ),
          SizedBox(height: 4.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CircleAvatar(
                radius: 4.r,
                backgroundColor: context.colors.secondary.withValues(
                  alpha: 0.3,
                ),
              ),
              SizedBox(width: 6.w),
              Text(
                "Goal",
                style: context.typography.body.copyWith(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                  color: context.colors.textPrimary,
                  fontFamily: "Inter",
                ),
              ),
              SizedBox(width: 12.w),
              CircleAvatar(
                radius: 4.r,
                backgroundColor: context.colors.secondary,
              ),
              SizedBox(width: 6.w),
              Text(
                "Achieved",
                style: context.typography.body.copyWith(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                  color: context.colors.textPrimary,
                  fontFamily: "Inter",
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          // Activity List Builder
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.activities.length,
            separatorBuilder: (context, index) => SizedBox(height: 12.h),
            itemBuilder: (context, index) {
              final item = widget.activities[index];
              final isSelected = _selectedIndex == index;

              // Dynamic color resolution for the filled bar
              final Color baseBarColor =
                  item.barColor ??
                  context
                      .colors
                      .secondary; // Default to secondary color if not provided
              final Color activeBarColor = item.barColor != null
                  ? Color.alphaBlend(
                      Colors.white.withValues(alpha: 0.2),
                      item.barColor!,
                    )
                  : context.colors.secondary;

              // 💡 Dynamic color resolution for the background track bar
              final Color baseTrackColor =
                  item.trackingBarColor ??
                  context.colors.secondary.withValues(alpha: 0.3);

              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (_) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                onTapCancel: () {
                  setState(() {
                    _selectedIndex = null;
                  });
                },
                onTapUp: (_) {
                  Future.delayed(const Duration(milliseconds: 700), () {
                    if (mounted && _selectedIndex == index) {
                      setState(() {
                        _selectedIndex = null;
                      });
                    }
                  });
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- TEXT LABEL ROW (Activity Name & Day Count) ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item.name,
                          style: context.typography.body.copyWith(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w500,
                            color: context.colors.textPrimary,
                            fontFamily: "Inter",
                          ),
                        ),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: isSelected
                              ? Container(
                                  key: ValueKey('val_$index'),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 6.w,
                                    vertical: 2.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: context.colors.secondary,
                                    borderRadius: BorderRadius.circular(4.r),
                                  ),
                                  child: Text(
                                    item.displayValue ?? "${item.currentDays}%",
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      fontFamily: "Inter",
                                    ),
                                  ),
                                )
                              : Text(
                                  item.displayValue ??
                                      "${item.currentDays.toInt()}%",
                                  key: ValueKey('max_$index'),
                                  style: context.typography.body.copyWith(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                    color: context.colors.textPrimary,
                                    fontFamily: "Inter",
                                  ),
                                ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    // --- HORIZONTAL BAR CHART ROW ---
                    SizedBox(
                      height: 10.h,
                      child: IgnorePointer(
                        child: BarChart(
                          BarChartData(
                            rotationQuarterTurns: 1,
                            maxY: item.maxDays,
                            minY: 0,
                            gridData: const FlGridData(show: false),
                            borderData: FlBorderData(show: false),
                            titlesData: FlTitlesData(
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              bottomTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              leftTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                            ),
                            barGroups: [
                              BarChartGroupData(
                                x: 0,
                                barRods: [
                                  BarChartRodData(
                                    fromY: 0,
                                    toY: item.currentDays,
                                    color: isSelected
                                        ? activeBarColor
                                        : baseBarColor,
                                    width: 10.h,
                                    borderRadius: BorderRadius.circular(8.r),
                                    backDrawRodData: BackgroundBarChartRodData(
                                      show: true,
                                      toY: item.maxDays,
                                      // 💡 Uses the custom track variable calculated above
                                      color: baseTrackColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
