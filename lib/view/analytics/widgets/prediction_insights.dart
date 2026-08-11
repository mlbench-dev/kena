import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';
import 'package:kena_emotional_journey/generated/assets/assets.gen.dart';

class PredictionInsightsCard extends StatelessWidget {
  const PredictionInsightsCard({super.key, required this.summary});

  final dynamic summary;

  @override
  Widget build(BuildContext context) {
    // Safely extract values from summary, handling Map or null cases
    final predictionAccuracy = summary is Map
        ? (summary['predictionAccuracyPercent'] as num?)?.toInt() ?? 0
        : 0;
    final daysForecasted = summary is Map
        ? (summary['daysForecasted'] as num?)?.toInt() ?? 0
        : 0;
    final daysReflected = summary is Map
        ? (summary['daysReflected'] as num?)?.toInt() ?? 0
        : 0;
    final daysActualRecorded = summary is Map
        ? (summary['daysActualRecorded'] as num?)?.toInt() ?? 0
        : 0;

    return _SectionCard(
      child: Column(
        children: [
          _CardHeader(title: "Prediction Insights"),
          SizedBox(height: 10.h),
          Text(
            "$predictionAccuracy%",
            style: _TextStyles.headline(
              context,
              size: 48,
              weight: FontWeight.w500,
              color: context.colors.primary,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            "Percentage of days where forecasted emotions matched actual reports",
            textAlign: TextAlign.center,
            style: _TextStyles.headline(
              context,
              size: 15,
              color: context.colors.textSecondary,
            ),
          ),
          SizedBox(height: 20.h),
          const _HorizontalDivider(),
          SizedBox(height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const _VerticalDivider(),
              SizedBox(width: 12.w),
              Expanded(
                child: _StatColumn(
                  label: "Days reflected",
                  value: "$daysReflected",
                ),
              ),
              SizedBox(width: 12.w),
              const _VerticalDivider(),
              SizedBox(width: 12.w),
              Expanded(
                child: _StatColumn(
                  label: "Actual recorded",
                  value: "$daysActualRecorded",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        border: Border.all(
          color: context.colors.textSecondary.withValues(alpha: 0.2),
        ),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: child,
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

/// Icon + title row shown at the top of a [_SectionCard].
class _CardHeader extends StatelessWidget {
  const _CardHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Assets.icons.graph.svg(width: 24.w, height: 24.h),
        SizedBox(width: 10.w),
        Text(
          title,
          style: _TextStyles.headline(
            context,
            size: 18,
            weight: FontWeight.w600,
            color: context.colors.textPrimary,
          ),
        ),
      ],
    );
  }
}

/// Thin full-width horizontal separator.
class _HorizontalDivider extends StatelessWidget {
  const _HorizontalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 1.h,
      decoration: BoxDecoration(
        color: context.colors.textSecondary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10.r),
      ),
    );
  }
}

/// Thin vertical separator, used between stat columns.
class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1.w,
      height: 40.h,
      decoration: BoxDecoration(
        color: context.colors.textSecondary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10.r),
      ),
    );
  }
}

/// "Label above value" column used in the Prediction Insights stats row.
class _StatColumn extends StatelessWidget {
  const _StatColumn({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          style: _TextStyles.headline(
            context,
            size: 11,
            color: context.colors.textSecondary,
          ),
        ),
        Text(
          value,
          style: _TextStyles.headline(
            context,
            size: 15,
            weight: FontWeight.w600,
            color: context.colors.textPrimary,
          ),
        ),
      ],
    );
  }
}
