import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';

class ChartDataModel {
  final String label;
  final double value;

  ChartDataModel({required this.label, required this.value});
}

class PerformanceDeviationChart extends StatefulWidget {
  final List<ChartDataModel> data; // 👈 Accepts any dynamic length array now

  const PerformanceDeviationChart({super.key, required this.data});

  @override
  State<PerformanceDeviationChart> createState() =>
      _PerformanceDeviationChartState();
}

class _PerformanceDeviationChartState extends State<PerformanceDeviationChart> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 💡 Dynamic width mapping to prevent compressing many items (e.g., 31 days)
    // Allocates 45 logical pixels per item, ensuring consistent bar thickness
    final double computedChartWidth = widget.data.length * 45.w;

    // Fallback constraints to match standard layout aspect ratios if data is short
    final double finalWidth = computedChartWidth < 320.w
        ? 320.w
        : computedChartWidth;

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: context.colors.background,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Worse ↔ Better',
                style: context.typography.body.copyWith(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'sfpro',
                  color: context.colors.textPrimary,
                ),
              ),
              Text(
                'vs Goal',
                style: context.typography.body.copyWith(
                  fontSize: 12.sp,
                  fontFamily: 'sfpro',
                  fontWeight: FontWeight.w500,
                  color: context.colors.textPrimary,
                ),
              ),
            ],
          ),

          SizedBox(height: 10.h),

          // Horizontal Scroll Container Framework wrapper
          Scrollbar(
            controller: _scrollController,
            thumbVisibility:
                widget.data.length >
                7, // Show scrollbar explicitly for month views
            child: SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: SizedBox(
                height: 115.h,
                width: finalWidth, // 👈 Applies calculated proportional width
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: 8,
                    minY: -8,
                    barTouchData: BarTouchData(enabled: false),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          getTitlesWidget: (value, meta) {
                            int index = value.toInt();
                            if (index < 0 || index >= widget.data.length) {
                              return const SizedBox.shrink();
                            }

                            return SideTitleWidget(
                              meta: meta,
                              space: 4.h,
                              child: Text(
                                widget
                                    .data[index]
                                    .label, // Dynamic Label string resolution
                                style: TextStyle(
                                  fontSize: 12
                                      .sp, // Slightly downsized for multi-digit month dates
                                  fontWeight: FontWeight.w500,
                                  color: context.colors.textPrimary,
                                  fontFamily: 'sfpro',
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      checkToShowHorizontalLine: (value) => value == 0,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: Colors.green.withOpacity(0.3),
                          strokeWidth: 1.5,
                        );
                      },
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: List.generate(widget.data.length, (index) {
                      final item = widget.data[index];
                      final isPositive = item.value >= 0;

                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: item.value,
                            color: isPositive
                                ? context.colors.primary
                                : const Color(0xFFE83820),
                            width: 22.w,
                            borderRadius: isPositive
                                ? const BorderRadius.vertical(
                                    top: Radius.circular(6),
                                  )
                                : const BorderRadius.vertical(
                                    bottom: Radius.circular(6),
                                  ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
