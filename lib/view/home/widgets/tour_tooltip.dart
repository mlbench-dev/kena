import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';

class TourTooltip extends StatelessWidget {
  final String title;
  final String description;
  final int currentStep; // 0-indexed
  final int totalSteps;
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final bool isLastStep;

  const TourTooltip({
    super.key,
    required this.title,
    required this.description,
    required this.currentStep,
    required this.totalSteps,
    required this.onNext,
    required this.onSkip,
    this.isLastStep = false,
  });

  static const _accentGreen = Color(0xFF2D5C4D); // match your app's exact green

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      padding: EdgeInsets.all(13.w),
      decoration: BoxDecoration(
        color: context.colors.background,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 12.r,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: Column(
              key: ValueKey<int>(currentStep),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: context.typography.body.copyWith(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: context.colors.textPrimary,
                      fontFamily: 'sfpro',
                    ),
                    children: [
                      TextSpan(text: title),
                      const TextSpan(text: ':'),
                    ],
                  ),
                ),
                SizedBox(height: 5.h),
                Text(
                  description,
                  style: context.typography.body.copyWith(
                    fontSize: 13.sp,
                    color: context.colors.textPrimary,
                    height: 1.3,
                    fontFamily: 'sfpro',
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: onSkip,
                child: Text(
                  'Skip',
                  style: context.typography.body.copyWith(
                    fontSize: 14.sp,
                    color: _accentGreen,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'sfpro',
                  ),
                ),
              ),
              _DotIndicator(currentStep: currentStep, totalSteps: totalSteps),
              GestureDetector(
                onTap: onNext,
                child: Text(
                  isLastStep ? 'Done' : 'Next',
                  style: context.typography.body.copyWith(
                    fontSize: 14.sp,
                    color: _accentGreen,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'sfpro',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DotIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const _DotIndicator({required this.currentStep, required this.totalSteps});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(totalSteps, (index) {
        final isActive = index == currentStep;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: 6.w,
          height: 6.h,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive
                ? TourTooltip._accentGreen
                : TourTooltip._accentGreen.withOpacity(0.25),
          ),
        );
      }),
    );
  }
}
