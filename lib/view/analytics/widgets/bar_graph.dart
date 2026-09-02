import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';

class ChartDataModel {
  final String label; // e.g., "M", "T", "1", "14", "J", "F"
  final double achievedValue; // Foreground filled value
  final double goalValue; // Background track value

  ChartDataModel({
    required this.label,
    required this.achievedValue,
    required this.goalValue,
  });
}

class CustomBarChart extends StatelessWidget {
  final List<ChartDataModel> dataList;

  // Customizable design arguments

  final double?
  customBarWidth; // Pass a manual width if you don't want dynamic sizing
  final List<String>
  highlightedLabels; // Pass labels you want colored in pink/special color
  final Color highlightColor;

  const CustomBarChart({
    super.key,
    required this.dataList,
    this.customBarWidth,
    this.highlightedLabels = const [], // Default empty list (no highlights)
    this.highlightColor = const Color(0xFFE91E63), // Default Pink accent
  });

  @override
  Widget build(BuildContext context) {
    // Multi-tier breakdown evaluating layout sizing per data scope bounds
    final double finalBarWidth =
        customBarWidth ??
        (dataList.length <= 7
            ? 22.0
            : dataList.length <= 12
            ? 14.0 // Sweet-spot thickness for the 12-month graph view
            : 5.0); // Slightly thinner bar to free up room for the label below it

    // FIX #1: For large datasets (e.g. 30 days), the previous value of 1.0
    // left almost no horizontal room per group, so adjacent number labels
    // visually ran into each other. Give it enough breathing room instead.
    final double groupSpacing = dataList.length <= 7
        ? 12.0
        : dataList.length <= 12
        ? 8.0
        : 4.0; // was 1.0 — this was the main cause of the collapsed labels

    // FIX #2: Even with more spacing, 30 two-digit labels at a small font
    // can still be tight on a narrow phone screen. Rather than shrinking
    // text further (which hurts readability), thin out which labels are
    // drawn once the dataset gets large — show every other one.
    final bool shouldThinLabels = dataList.length > 20;

    // Dynamically calculate the highest ceiling threshold for the Y-axis scale
    double maxCalculatedY = 5.0;
    for (var data in dataList) {
      if (data.goalValue > maxCalculatedY) {
        maxCalculatedY = data.goalValue;
      }
    }

    return BarChart(
      BarChartData(
        maxY: maxCalculatedY,
        minY: 0,
        groupsSpace: groupSpacing, // Applied dynamic spacing layout logic here
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),

        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: maxCalculatedY / 5,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                final percentage = ((value / maxCalculatedY) * 100).toInt();
                return SideTitleWidget(
                  meta: meta,
                  space: 8,
                  child: Text(
                    '$percentage%',
                    style: TextStyle(
                      color: context.colors.textPrimary,
                      fontSize: 7.sp,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'sfpro',
                    ),
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final int index = value.toInt();
                if (index >= 0 && index < dataList.length) {
                  // FIX #2 cont'd: skip every other label once the dataset
                  // is large, so the remaining ones have room to breathe.
                  if (shouldThinLabels && index % 2 != 0) {
                    return const SizedBox.shrink();
                  }

                  final String currentLabel = dataList[index].label;
                  final bool isHighlighted = highlightedLabels.contains(
                    currentLabel,
                  );

                  return SideTitleWidget(
                    meta: meta,
                    space: 6,
                    child: Text(
                      currentLabel,
                      style: TextStyle(
                        color: isHighlighted
                            ? highlightColor
                            : context.colors.textPrimary,
                        fontSize: dataList.length <= 7
                            ? 14
                            : dataList.length <= 12
                            ? 13
                            : 9,
                        // FIX #3: negative letterSpacing was actively
                        // squeezing the two digits of numbers like "27"/"28"
                        // together, making them read as one glyph. Neutral
                        // spacing reads much more clearly.
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ),

        barGroups: List.generate(dataList.length, (index) {
          final data = dataList[index];
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                fromY: 0,
                toY: data.achievedValue,
                color: context.colors.secondary, // Deep Dark Green
                width: finalBarWidth,
                borderRadius: BorderRadius.circular(20),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: data.goalValue,
                  color: context.colors.secondary.withValues(
                    alpha: 0.3,
                  ), // Light Sage Green
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
