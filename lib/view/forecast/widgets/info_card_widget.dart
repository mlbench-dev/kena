import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';
import 'package:kena_emotional_journey/generated/assets/assets.gen.dart';

class InfoCardWidget extends StatelessWidget {
  final String title;
  final String text;
  final bool showEditIcon;
  final bool expanded;
  final VoidCallback onToggle;
  final VoidCallback? onEditTap;

  const InfoCardWidget({
    super.key,
    required this.title,
    required this.text,
    required this.showEditIcon,
    required this.expanded,
    required this.onToggle,
    this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.w),
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.colors.textSecondary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title.isNotEmpty) ...[
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: context.colors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 10.h),
                ],
                Text(
                  text,
                  softWrap: true,
                  maxLines: expanded ? null : 3,
                  overflow: expanded
                      ? TextOverflow.visible
                      : TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: context.colors.textPrimary,
                  ),
                ),
                SizedBox(height: 5.h),

                // Triggers "Show More" expansion if string character length exceeds bound
                if (text.length > 100)
                  GestureDetector(
                    onTap: onToggle,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 4.h),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            expanded ? "Show Less" : "Show More",
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Icon(
                            expanded
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            size: 18.sp,
                            color: Colors.blue,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (showEditIcon)
            GestureDetector(
              onTap: onEditTap,
              child: Padding(
                padding: EdgeInsets.only(left: 8.w),
                child: Assets.icons.pen2.svg(),
              ),
            ),
        ],
      ),
    );
  }
}
