import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kena_emotional_journey/app/components/my_button.dart';
import 'package:kena_emotional_journey/app/components/my_scaffold.dart';
import 'package:kena_emotional_journey/app/utils/app_constants.dart';
import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';
import 'package:kena_emotional_journey/app/utils/legal_links.dart';
import 'package:kena_emotional_journey/services/common/auth_service.dart';

class FreeTrailScreen extends StatelessWidget {
  const FreeTrailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color kenaDarkGreen = Color(0xFF34543B);

    return MyScaffold(
      body: SafeArea(
        // The fix: Entire body is now scrollable
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              children: [
                SizedBox(height: 15.h),

                // App Logo
                Text(
                  "Kena",
                  style: context.typography.title.copyWith(
                    fontFamily: 'ZenAntiqueSoft',
                    fontSize: 32.sp,
                    color: context.colors.tertiary,
                    fontWeight: FontWeight.w400,
                  ),
                ),

                SizedBox(height: 40.h),

                // Celebration Icon
                Container(
                  width: 104.r, // radius * 2
                  height: 104.r,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFC8E6C9), // Lighter top
                        Color(0xFFE8F5E9), // Faded bottom
                      ],
                    ),
                  ),
                  child: Center(
                    child: Text("🎉", style: TextStyle(fontSize: 45.sp)),
                  ),
                ),

                SizedBox(height: 30.h),

                // Header Text
                Text(
                  "Enjoy free access — for now",
                  textAlign: TextAlign.center,
                  style: context.typography.headline.copyWith(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w600,
                    fontFamily: "sfpro",
                  ),
                ),

                SizedBox(height: 12.h),

                Text(
                  "Start with a free trial and continue your emotional journey with a simple monthly subscription.",
                  textAlign: TextAlign.center,
                  style: context.typography.body.copyWith(
                    color: context.colors.textSecondary,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    fontFamily: "sfpro",
                  ),
                ),

                SizedBox(height: 30.h),

                // Features Header
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Features Available",
                    style: context.typography.title.copyWith(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      fontFamily: "sfpro",
                    ),
                  ),
                ),

                SizedBox(height: 15.h),

                // // The Fix: Use Column for items instead of a nested ListView
                // // This prevents the "infinite height" error inside a ScrollView
                // _buildFeaturesList(context),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Color(0xFFFFFBF2),
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(
                      color: context.colors.textSecondary.withValues(
                        alpha: 0.4,
                      ),
                    ),
                  ),
                  child: Column(
                    children: [
                      FeaturesList(
                        title: "Free trial:",
                        features: [
                          'Remove ads',
                          'Record core & aspirational emotions',
                          'Record Daily pulse',
                          'Comprehensive list of emotions',
                          'Visualisation of emotions',
                          'Journaling & Notes',
                          'Limited activities (10 max)',
                          'Limited analytics (Week & month only)',
                          'Limited community features',
                          'All the above',
                          'Full community features',
                          'Detailed analytics',
                          'Search by body sensations',
                          'Thought monitoring prompts',
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30.h),

                // Trial Card
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF9F6),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: Colors.black.withValues(alpha: 0.05),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "21-Day Free Trial",
                        style: context.typography.title.copyWith(
                          color: context.colors.tertiary,
                          fontWeight: FontWeight.w600,
                          fontSize: 16.sp,
                          fontFamily: "sfpro",
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        "No charge today",
                        style: context.typography.body.copyWith(
                          color: context.colors.textSecondary,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                          fontFamily: "sfpro",
                        ),
                      ),
                      Text(
                        "Cancel anytime",
                        style: context.typography.body.copyWith(
                          color: context.colors.textPrimary,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                          fontFamily: "sfpro",
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20.h),

                // Action Button
                MyButton(
                  label: "Start Free Trial",
                  onPressed: () {
                    AuthService.goToUserHome(context);
                  },
                  textColor: context.colors.background,
                ),

                SizedBox(height: 12.h),

                Text(
                  "You won't be charged until your trial ends.",
                  style: context.typography.body.copyWith(
                    color: Colors.grey,
                    fontSize: 13.sp,
                  ),
                ),

                SizedBox(height: 12.h),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => openLegalUrl(
                        context,
                        ExternalLinks.standardEULATerms,
                      ),
                      child: Text(
                        'Terms of Use',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: context.colors.primary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'and',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: context.colors.textSecondary,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    GestureDetector(
                      onTap: () => openLegalUrl(
                        context,
                        ExternalLinks.kenaPrivacyPolicy,
                      ),
                      child: Text(
                        'Privacy Policy',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: context.colors.primary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 30.h), // Bottom safety margin
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper to build the feature items without using a ListView
  Widget _buildFeaturesList(BuildContext context) {
    final features = [
      "'Core' emotions tracking",
      "Daily Emotional forecasting",
      "End of day review of forecast vs actual",
      "Comprehensive list of emotions",
      "'Aspirational' emotions tracking",
      "Emotion visualization",
      "Journaling",
    ];

    return Column(
      children: features
          .map((text) => _buildFeatureItem(context, text))
          .toList(),
    );
  }

  Widget _buildFeatureItem(BuildContext context, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check, size: 16.sp, color: Colors.black54),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              text,
              style: context.typography.body.copyWith(
                fontSize: 14.sp,
                color: context.colors.textPrimary,
                fontWeight: FontWeight.w400,
                fontFamily: "sfpro",
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FeaturesList extends StatelessWidget {
  final List<String> features;
  final String title;
  const FeaturesList({super.key, required this.features, required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: context.typography.title.copyWith(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: context.colors.textPrimary,
            fontFamily: "sfpro",
          ),
        ),
        SizedBox(height: 10.h),
        ...features.map(
          (e) => Padding(
            padding: EdgeInsets.symmetric(vertical: 5.h),
            child: FeatureName(title: e),
          ),
        ),
      ],
    );
  }
}

class FeatureName extends StatelessWidget {
  const FeatureName({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.check, color: context.colors.tertiary, size: 18.r),
        SizedBox(width: 5.w),
        Text(
          title,
          style: context.typography.title.copyWith(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: context.colors.textSecondary.withValues(alpha: 0.9),
            fontFamily: "sfpro",
          ),
        ),
      ],
    );
  }
}
