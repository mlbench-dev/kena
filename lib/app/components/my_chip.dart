import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kena_emotional_journey/app/styles/app_radiuses.dart';
import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';

class MyChip extends StatelessWidget {
  const MyChip({required this.label, required this.onDelete, super.key});
  final String label;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Container(
      padding: EdgeInsets.only(left: 12.w, right: 2.w),
      decoration: BoxDecoration(
        color: colors.inputBackground,
        borderRadius: BorderRadius.circular(AppRadiuses.hundredRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              label,
              style: typography.body.copyWith(
                color: colors.inputText,
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          SizedBox(
            width: 28.w,
            height: 28.h,
            child: IconButton(
              onPressed: onDelete,
              visualDensity: VisualDensity.compact,
              // icon: Assets.icons.close.svg(),
              icon: Icon(Icons.close),
            ),
          ),
        ],
      ),
    );
  }
}
