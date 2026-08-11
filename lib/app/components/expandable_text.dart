import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';

class ExpandableText extends StatelessWidget {
  final String text;
  final bool expanded;
  final VoidCallback onToggle;
  final int maxLines;
  final int charThreshold;
  final double? fontSize;
  final Color? textColor;

  const ExpandableText({
    super.key,
    required this.text,
    required this.expanded,
    required this.onToggle,
    this.maxLines = 3,
    this.charThreshold = 100,
    this.fontSize,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          softWrap: true,
          maxLines: expanded ? null : maxLines,
          overflow: expanded ? TextOverflow.visible : TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: fontSize ?? 14.sp,
            color: textColor ?? context.colors.textPrimary,
          ),
        ),
        SizedBox(height: 5.h),
        if (text.length > charThreshold)
          GestureDetector(
            onTap: onToggle,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  expanded ? 'Show Less' : 'Show More',
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
      ],
    );
  }
}
