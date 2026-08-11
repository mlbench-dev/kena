import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';

class EmptyFeedScreen extends StatelessWidget {
  final bool isStopSharing;
  const EmptyFeedScreen({super.key, required this.isStopSharing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 270.w,
            child: Text(
              isStopSharing
                  ? "You are no longer sharing your forecast"
                  : "Your friend has not shared their forecast today.",
              textAlign: TextAlign.center,
              style: context.typography.body.copyWith(
                fontSize: 18.sp,
                fontWeight: FontWeight.w400,
                color: context.colors.textPrimary,
              ),
            ),
          ),
          // SizedBox(height: 20.h),
          // Padding(
          //   padding: EdgeInsets.only(bottom: 100.w),
          //   child: MyButton(
          //     label: isStopSharing
          //         ? "Reshare your Forecast"
          //         : "Share your Forecast",
          //     onPressed: () {
          //       isStopSharing
          //           ? Navigator.pushNamed(
          //               context,
          //               RoutesName.forecastResultScreen,
          //             )
          //           : null;
          //     },
          //   ),
          // ),
        ],
      ),
    );
  }
}
