import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';
// Assuming these are your custom extension paths
// import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';

class SmallProgressBar extends StatelessWidget {
  final String label;
  final String day;
  final String num;
  final double value;
  final Color color;

  const SmallProgressBar({
    super.key,
    required this.label,
    required this.num,
    required this.day,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 1. The Leading Number Circle
        CircleAvatar(
          radius: 18.r,
          backgroundColor: context.colors.primary,
          child: Text(
            num,
            style: context.typography.body.copyWith(
              color: context.colors.background,
              fontSize: 14.sp,
            ),
          ),
        ),
        SizedBox(width: 15.w), // Horizontal gap between circle and content
        // 2. Wrap the rest in Expanded so it fills the remaining Row space
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center, // Align text to left
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: context.typography.body.copyWith(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: context.colors.textPrimary,
                      fontFamily: "Inter",
                    ),
                  ),
                  Text(
                    day,
                    style: context.typography.body.copyWith(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: context.colors.primary,
                      fontFamily: "Inter",
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // 3. The Progress Bar
              ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(12)),
                child: LinearProgressIndicator(
                  value: value,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  backgroundColor: Colors.grey[200],
                  minHeight: 12.h,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
