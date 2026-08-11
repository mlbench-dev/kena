import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';
import 'package:kena_emotional_journey/generated/assets/assets.gen.dart';

class ActivitiesCard extends StatelessWidget {
  final String title;
  final Widget child;
  final bool showEdit;
  final VoidCallback? onEditTap;
  final VoidCallback? onAdd;
  final VoidCallback? onEdit;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Color? borderColor;
  final Widget? editIcon;
  final bool isEditMode;
  final ValueChanged<bool>? onToggleEdit;
  final bool showEditToggle;
  const ActivitiesCard({
    super.key,
    required this.title,
    required this.child,
    required this.isEditMode,
    required this.onAdd,
    required this.onEditTap,
    this.onToggleEdit,
    this.showEditToggle = true,
    this.showEdit = false,
    this.onEdit,
    this.padding,
    this.backgroundColor,
    this.borderColor,
    this.editIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty)
          Row(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: context.colors.textPrimary,
                ),
              ),
              Spacer(),
              if (onToggleEdit != null) ...[
                if (showEditToggle) ...[
                  GestureDetector(
                    onTap: () {
                      onToggleEdit!(!isEditMode);
                    },
                    behavior: HitTestBehavior.opaque,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
                          },
                      child: isEditMode
                          ? Text(
                              'Done',
                              key: const ValueKey('done_text'),
                              style: context.typography.body.copyWith(
                                fontFamily: 'sfpro',
                                color: context.colors.primary,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            )
                          : GestureDetector(
                              onTap: onEditTap,
                              child: Assets.icons.penOutline.svg(),
                            ),
                    ),
                  ),
                  SizedBox(width: 6.w),
                ],
                GestureDetector(
                  onTap: onAdd,
                  child: Icon(Icons.add, color: context.colors.primary),
                ),
              ],
            ],
          ),
        SizedBox(height: 8.h),
        Container(
          width: double.infinity,
          padding: padding ?? EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            color: backgroundColor ?? context.colors.background,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isEditMode
                  ? context.colors.primary
                  : borderColor ??
                        context.colors.textSecondary.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (title.isNotEmpty) SizedBox(height: 10.h),

                    child,
                  ],
                ),
              ),

              if (showEdit)
                GestureDetector(
                  onTap: onEdit,
                  child: editIcon ?? const Icon(Icons.edit),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
