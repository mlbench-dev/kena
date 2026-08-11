import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';

class AllTimeProgressCard extends StatelessWidget {
  final double currentProgress; // e.g., 500
  final double goalValue; // e.g., 1000
  final String lable;
  final bool hidebottomLabel;
  const AllTimeProgressCard({
    super.key,
    required this.currentProgress,
    required this.goalValue,
    required this.lable,
    this.hidebottomLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    // Safely calculate percentage percentage out of 100
    final double percentage = goalValue > 0
        ? (currentProgress / goalValue)
        : 0.0;
    final int displayPercentage = (percentage * 100).clamp(0, 100).toInt();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: const Color(
          0xFFEFF3F1,
        ), // Matches the soft grey-green backfill container color
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- HEADER TYPOGRAPHY ROW ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                lable,
                style: context.typography.body.copyWith(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: context.colors.textPrimary,
                  fontFamily: "sfpro",
                ),
              ),
              Text(
                "$displayPercentage%",
                style: context.typography.body.copyWith(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(
                    0xFF1B4D3E,
                  ), // Deep green accent indicator matching your theme
                  fontFamily: "sfpro",
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // --- SMOOTH PROGRESS INDICATOR TRACK ---
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: SizedBox(
              height: 8.h, // Clean line thickness matching your design layout
              child: LinearProgressIndicator(
                value: percentage.clamp(0.0, 1.0),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFF1B4D3E), // Solid deep green fill
                ),
                backgroundColor:
                    Colors.white, // Pure white empty track background
              ),
            ),
          ),
          SizedBox(height: 8.h),

          // --- TRACK METRICS LABELS ROW ---
          if (hidebottomLabel) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${currentProgress.toInt()}",
                  style: context.typography.body.copyWith(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: context.colors.textSecondary,
                    fontStyle: FontStyle.italic,
                    fontFamily: "sfpro",
                  ),
                ),
                Text(
                  "${goalValue.toInt()} Goal",
                  style: context.typography.body.copyWith(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: context.colors.textSecondary,
                    fontStyle: FontStyle.italic,
                    fontFamily: "sfpro",
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
