import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kena_emotional_journey/app/components/capsule_tabbar.dart';
import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';
import 'package:kena_emotional_journey/view/analytics/alltime_overall.dart';
import 'package:kena_emotional_journey/view/analytics/monthly_overall.dart';
import 'package:kena_emotional_journey/view/analytics/weekly_overall.dart';

class OverallScreen extends StatefulWidget {
  const OverallScreen({super.key, required this.data});
  final dynamic data;
  @override
  State<OverallScreen> createState() => _OverallScreenState();
}

class _OverallScreenState extends State<OverallScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = ['Weekly', 'Monthly', 'All Time'];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CapsuleTabBar(
          controller: _tabController,
          tabs: _tabs,
          activeColor: context.colors.primary,
          inactiveTextColor: context.colors.textSecondary,
        ),
        SizedBox(height: 20.h),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: AnimatedBuilder(
            animation: _tabController,
            builder: (context, _) {
              return IndexedStack(
                index: _tabController.index,
                children: [
                  // --- TAB 1: WEEKLY ---
                  WeeklyOverall(),

                  // --- TAB 2: MONTHLY ---
                  MonthlyOverall(),

                  // --- TAB 3: ALL TIME ---
                  AlltimeOverall(),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

/// A single "emotion name — forecast count — actual count" row.
class EmotionRow extends StatelessWidget {
  const EmotionRow({
    super.key,
    required this.emotion,
    required this.color,
    required this.forecast,
    required this.actual,
  });

  final String emotion;
  final Color color;
  final int forecast;
  final int actual;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(radius: 6.r, backgroundColor: color),
        SizedBox(width: 10.w),
        Text(
          emotion,
          style: _TextStyles.headline(
            context,
            size: 15,
            color: context.colors.textPrimary,
          ),
        ),
        const Spacer(),
        _EmotionCount(label: "Forecast", value: forecast),
        SizedBox(width: 20.w),
        _EmotionCount(label: "Actual", value: actual),
      ],
    );
  }
}

/// A small "number over label" pair, e.g. the Forecast/Actual counters in
///
class _EmotionCount extends StatelessWidget {
  const _EmotionCount({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: _TextStyles.headline(
            context,
            size: 18,
            weight: FontWeight.w600,
            color: context.colors.textPrimary,
          ),
        ),
        Text(
          label,
          style: _TextStyles.headline(
            context,
            size: 11,
            color: context.colors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _TextStyles {
  const _TextStyles._();

  static TextStyle headline(
    BuildContext context, {
    required double size,
    required Color color,
    FontWeight weight = FontWeight.w400,
    String fontFamily = 'Inter',
  }) {
    return context.typography.headline.copyWith(
      fontSize: size.sp,
      fontWeight: weight,
      color: color,
      fontFamily: fontFamily,
    );
  }
}
