import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';

class BuildChartLegend extends StatelessWidget {
  const BuildChartLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.end, // Aligns indicators to the right edge
      children: [
        // Goal Marker
        Container(
          width: 10.r,
          height: 10.r,
          decoration: BoxDecoration(
            color: context.colors.secondary.withValues(
              alpha: 0.3,
            ), // Light Sage Green
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 6.w),
        Text(
          'Goal',
          style: TextStyle(
            color: context.colors.textPrimary,
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(width: 16.w), // Space between options
        // Achieved Marker
        Container(
          width: 10.r,
          height: 10.r,
          decoration: BoxDecoration(
            color: context.colors.secondary, // Deep Dark Green
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 6.w),
        Text(
          'Achieved',
          style: TextStyle(
            color: context.colors.textPrimary,
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
