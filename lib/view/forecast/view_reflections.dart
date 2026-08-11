import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kena_emotional_journey/app/components/my_scaffold.dart';
import 'package:kena_emotional_journey/app/routes/routes_name.dart';
import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';
import 'package:kena_emotional_journey/generated/assets/assets.gen.dart';

class ViewReflections extends StatefulWidget {
  const ViewReflections({super.key});

  @override
  State<ViewReflections> createState() => _ViewReflectionsState();
}

class _ViewReflectionsState extends State<ViewReflections> {
  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.w),
        child: Column(
          children: [
            Row(
              children: [
                BackButton(color: context.colors.textPrimary),
                Expanded(
                  child: Text(
                    textAlign: TextAlign.center,
                    "Forecast",
                    style: context.typography.headline.copyWith(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w600,
                      fontFamily: "sfpro",
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, RoutesName.homeScreen);
                  },
                  child: Assets.icons.homeIcon.svg(width: 40.w, height: 40.h),
                ),
              ],
            ),
            SizedBox(height: 30.h),
            Container(
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(children: [
                  
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
