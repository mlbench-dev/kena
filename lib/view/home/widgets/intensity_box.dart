import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kena_emotional_journey/app/components/my_button.dart';
import 'package:kena_emotional_journey/app/components/my_dialog.dart';
import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';

class IntensityDialogBox extends StatefulWidget {
  final Widget leadingIcon;
  final String title;
  final String subtitle;
  final void Function() onCancel;
  final void Function(int selectedNumber) onConfirm;

  const IntensityDialogBox({
    super.key,
    required this.leadingIcon,
    required this.title,
    required this.subtitle,
    required this.onCancel,
    required this.onConfirm,
  });

  static Future<T?> show<T>(
    BuildContext context, {
    required Widget leadingIcon,
    required String title,
    required String subtitle,
    required void Function() onCancel,
    required void Function(int selectedNumber) onConfirm,
  }) {
    return MyDialogBox.show<T>(
      context,
      child: IntensityDialogBox(
        leadingIcon: leadingIcon,
        title: title,
        subtitle: subtitle,
        onCancel: onCancel,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  State<IntensityDialogBox> createState() => _IntensityDialogBoxState();
}

class _IntensityDialogBoxState extends State<IntensityDialogBox> {
  int selectedNumber = 0;
  bool _showIntensityError = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300.w,
      padding: EdgeInsets.all(15.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ────────────────────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              widget.leadingIcon,
              SizedBox(width: 15.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10.h),
                  Text(
                    widget.title,
                    style: context.typography.body.copyWith(
                      color: context.colors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    widget.subtitle,
                    style: context.typography.subtitle.copyWith(
                      fontSize: 14.sp,
                      color: context.colors.textSecondary.withValues(
                        alpha: 0.7,
                      ),
                      fontVariations: const [FontVariation('wght', 400.0)],
                    ),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: 30.h),

          // ── Number boxes ──────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(5, (index) {
              final number = index + 1;
              return GestureDetector(
                onTap: () => setState(() {
                  selectedNumber = number;
                  _showIntensityError = false;
                }),
                child: _NumberBox(
                  number: number,
                  isSelected: selectedNumber == number,
                ),
              );
            }),
          ),

          SizedBox(height: 10.h),

          // ── Low / Intense labels ──────────────────────────────────────────
          Row(
            children: [
              Text(
                'Low',
                style: context.typography.subtitle.copyWith(
                  fontSize: 12.sp,
                  color: context.colors.textSecondary.withValues(alpha: 0.7),
                ),
              ),
              const Spacer(),
              Text(
                'Intense',
                style: context.typography.subtitle.copyWith(
                  fontSize: 12.sp,
                  color: context.colors.textSecondary.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),

          if (_showIntensityError) ...[
            SizedBox(height: 8.h),
            Text(
              'Please select an intensity number',
              style: context.typography.subtitle.copyWith(
                fontSize: 12.sp,
                color: Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],

          SizedBox(height: 15.h),

          // ── Buttons ───────────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => widget.onCancel(),
                child: Container(
                  width: 130.w,
                  height: 48.h,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  decoration: BoxDecoration(
                    color: context.colors.textSecondary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(15.r),
                  ),
                  child: Center(
                    child: Text(
                      "Cancel",
                      style: context.typography.title.copyWith(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: context.colors.textPrimary,
                        fontFamily: "Inter",
                      ),
                    ),
                  ),
                ),
              ),
              // SizedBox(
              //   width: 130.w,
              //   height: 48.h,
              //   child: MyButton(
              //     fontWeight: FontWeight.w500,
              //     label: 'Cancel',
              //     backgroundColor: const Color(0xFFf5f5f5),
              //     textColor: context.colors.textPrimary,
              //     onPressed: widget.onCancel,
              //   ),
              // ),
              SizedBox(
                width: 130.w,
                height: 48.h,
                child: MyButton(
                  fontWeight: FontWeight.w500,
                  label: 'Confirm',
                  textColor: context.colors.background,
                  onPressed: () {
                    if (selectedNumber == 0) {
                      setState(() => _showIntensityError = true);
                      return;
                    }
                    widget.onConfirm(selectedNumber);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── NumberBox ─────────────────────────────────────────────────────────────────

class _NumberBox extends StatelessWidget {
  final int number;
  final bool isSelected;

  const _NumberBox({required this.number, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42.w,
      height: 42.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.r),
        color: isSelected
            ? context.colors.primary.withValues(alpha: 0.2)
            : const Color(0xFFf5f5f5),
        border: Border.all(
          color: isSelected ? context.colors.primary : const Color(0xFFe0e0e0),
          width: 2.w,
        ),
      ),
      child: Center(
        child: Text(
          number.toString(),
          style: TextStyle(
            color: context.colors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
          ),
        ),
      ),
    );
  }
}
