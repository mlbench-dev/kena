import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';

class ThoughtCategory {
  final String label;
  final double percentage;
  final Color color;
  final Widget icon;

  const ThoughtCategory({
    required this.label,
    required this.percentage,
    required this.color,
    required this.icon,
  });
}

// Dummy data — replace icon with Assets.icon.xxx.svg() from your project
const List<ThoughtCategory> dummyCategories = [
  ThoughtCategory(
    label: "Skipped",
    percentage: 10,
    color: Color(0xFFB2D338),
    icon: Icon(Icons.battery_1_bar, color: Color(0xFFB2D338), size: 24),
    // icon: Assets.icon.batterySkipped.svg(),
  ),
  ThoughtCategory(
    label: "Positive",
    percentage: 20,
    color: Color(0xFF1E5631),
    icon: Icon(Icons.battery_2_bar, color: Color(0xFF1E5631), size: 24),
    // icon: Assets.icon.batteryPositive.svg(),
  ),
  ThoughtCategory(
    label: "Negative",
    percentage: 30,
    color: Color(0xFFD90000),
    icon: Icon(Icons.battery_4_bar, color: Color(0xFFD90000), size: 24),
    // icon: Assets.icon.batteryNegative.svg(),
  ),
  ThoughtCategory(
    label: "Neutral",
    percentage: 40,
    color: Color(0xFFC8A200),
    icon: Icon(Icons.battery_full, color: Color(0xFFC8A200), size: 24),
    // icon: Assets.icon.batteryNeutral.svg(),
  ),
];

// Segmented progress bar
class SegmentedProgressBar extends StatelessWidget {
  final double height;
  final List<ThoughtCategory> categories;
  final Color backgroundColor;

  const SegmentedProgressBar({
    Key? key,
    this.height = 12.0,
    required this.categories,
    this.backgroundColor = const Color(0xFFD2E8DB),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final radius = BorderRadius.circular(height / 2);

        // Cumulative percentage at each index: [10,20,30,40] -> [10,30,60,100]
        double runningTotal = 0;
        final cumulative = categories
            .map((c) => runningTotal += c.percentage)
            .toList();

        return Stack(
          children: [
            Container(
              height: height,
              width: totalWidth,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: radius,
              ),
            ),
            for (int i = categories.length - 1; i >= 0; i--)
              Container(
                height: height,
                width: (cumulative[i].clamp(0, 100) / 100.0) * totalWidth,
                decoration: BoxDecoration(
                  color: categories[i].color,
                  borderRadius: radius,
                ),
              ),
          ],
        );
      },
    );
  }
}

// Main card widget
class ThoughtMonitoringWidget extends StatelessWidget {
  final List<ThoughtCategory> categories;
  final int goal;

  const ThoughtMonitoringWidget({
    Key? key,
    required this.categories,
    this.goal = 100,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.0),
        border: Border.all(color: Colors.grey.shade200, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Today's Thought Monitoring",
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: context.colors.textPrimary,
              fontFamily: 'sfpro',
            ),
          ),
          SizedBox(height: 14.h),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              "Goal: $goal%",
              style: context.typography.body.copyWith(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: context.colors.primary,
                fontFamily: 'sfpro',
              ),
            ),
          ),
          const SizedBox(height: 8),
          SegmentedProgressBar(categories: categories),
          const SizedBox(height: 24),
          for (int i = 0; i < categories.length; i++) ...[
            _LegendRow(category: categories[i]),
            if (i != categories.length - 1) const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }
}

// Legend row: icon (from category) + label + percentage
class _LegendRow extends StatelessWidget {
  final ThoughtCategory category;

  const _LegendRow({Key? key, required this.category}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        category.icon,
        const SizedBox(width: 12),
        Text(
          category.label,
          style: context.typography.body.copyWith(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: context.colors.textPrimary,
            fontFamily: 'Inter',
          ),
        ),
        const Spacer(),
        Text(
          "${category.percentage.toStringAsFixed(0)}%",
          style: context.typography.body.copyWith(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: context.colors.textPrimary,
            fontFamily: 'sfpro',
          ),
        ),
      ],
    );
  }
}
