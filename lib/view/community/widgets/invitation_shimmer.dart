import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class InvitationShimmer extends StatelessWidget {
  const InvitationShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: ListView.builder(
        itemCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            child: Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Row(
                children: [
                  // Avatar shimmer
                  Container(
                    height: 40.h,
                    width: 40.w,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),

                  SizedBox(width: 10.w),

                  // Text shimmer
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 10.h,
                          width: double.infinity,
                          color: Colors.white,
                        ),
                        SizedBox(height: 8.h),
                        Container(
                          height: 10.h,
                          width: 120.w,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(width: 10.w),

                  // Button shimmer
                  Container(height: 25.h, width: 70.w, color: Colors.white),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
