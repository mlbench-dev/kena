import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kena_emotional_journey/app/components/my_scaffold.dart';
import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';
import 'package:kena_emotional_journey/generated/assets/assets.gen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      isSafeArea: false,
      body: Stack(
        children: [
          Positioned(left: 0, top: 0, child: Assets.icons.vectors.svg()),
          Positioned(left: 98, top: 50, child: Assets.icons.ellipse.svg()),
          Positioned(
            left: 140.w,
            top: 160.h,
            // right: 0,
            // bottom: 0,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.w),
              decoration: BoxDecoration(
                color: context.colors.textSecondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(30.w),
              ),
              child: Assets.icons.logo.logo.svg(width: 80.w, height: 85.w),
            ),
          ),
          Positioned(
            left: 130.w,
            top: 280.h,
            child: Center(
              child: Text(
                'Kena',
                style: GoogleFonts.momoTrustDisplay(
                  fontSize: 50.sp,
                  color: context.colors.tertiary,
                  fontWeight: FontWeight.w400,
                  // fontFamily: 'sfpro',
                ),
              ),
            ),
          ),
          Positioned(
            left: 70.w,
            top: 360.h,
            child: SizedBox(
              width: 250.w,
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  // Base style applied to all spans
                  style: context.typography.body.copyWith(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'inter',
                    height:
                        1.5, // 👈 Adjust this value (e.g. 1.4 to 1.8) to increase the gap
                    color: context.colors.textPrimary,
                  ),
                  children: [
                    TextSpan(
                      text: 'Small Steps',
                      style: TextStyle(color: context.colors.primary),
                    ),
                    const TextSpan(text: ','),
                    TextSpan(
                      text: ' Brighter',
                      style: TextStyle(color: context.colors.secondary),
                    ),
                    TextSpan(
                      text:
                          ' Days\nGrowing Together', // Added explicit newline if you want guaranteed break
                      style: TextStyle(color: context.colors.tertiary),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 30.w,
            top: 427.h,
            child: Text(
              'Your space for self-reflection, \nmeaningful progress and real support.',
              textAlign: TextAlign.center,
              style: context.typography.body.copyWith(
                fontSize: 18.sp,
                fontWeight: FontWeight.w400,
                fontFamily: 'inter',
                height:
                    1.5, // 👈 Adjust this value (e.g. 1.4 to 1.8) to increase the gap
                color: context.colors.textPrimary,
              ),
            ),
          ),
          Positioned(
            // left: 0,
            // right: 0,
            bottom: 0.h,
            child: Assets.images.group.image(),
          ),
          Positioned(
            right: 140.w,
            bottom: 25.h,
            child: Text(
              'Welcome',
              style: context.typography.body.copyWith(
                fontSize: 20.sp,
                fontWeight: FontWeight.w400,
                fontFamily: 'inter',
                height:
                    1.5, // 👈 Adjust this value (e.g. 1.4 to 1.8) to increase the gap
                color: context.colors.tertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
