import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kena_emotional_journey/app/components/my_button.dart';
import 'package:kena_emotional_journey/app/routes/routes_name.dart';
import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';

class EmotionTypeBottomSheet extends StatelessWidget {
  const EmotionTypeBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 255.h,
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: context.colors.background,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30.r),
          topRight: Radius.circular(30.r),
        ),
      ),
      child: Column(
        children: [
          Container(
            height: 5.h,
            width: 55.w,
            decoration: BoxDecoration(
              color: context.colors.textSecondary,
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
          SizedBox(height: 15.h),
          Text(
            'Select Emotions',
            style: context.typography.title.copyWith(
              color: context.colors.textPrimary,
              fontSize: 18.sp,
              fontFamily: "Raleway",
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 25.h),
          MyButton(
            label: "Core Emotions",
            onPressed: () {
              // Pop with the route name so the caller can push & await it
              Navigator.pop(context, RoutesName.coreEmotions);
            },
          ),
          SizedBox(height: 10.h),
          MyButton(
            label: "Aspirational Emotions",
            onPressed: () {
              Navigator.pop(context, RoutesName.aspirationalEmotions);
            },
            borderColor: context.colors.primary,
            borderWidth: 1,
            backgroundColor: context.colors.background,
            textColor: context.colors.primary,
          ),
        ],
      ),
    );
  }
}
