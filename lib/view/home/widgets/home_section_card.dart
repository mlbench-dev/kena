import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';
import 'package:kena_emotional_journey/generated/assets/assets.gen.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

/// Promo-style card used on the home screen for each main section
/// (Aspire, Daily Pulse, Activities, Analytics, Circle): a background
/// illustration with a circular icon badge, title and subtitle on top.
class HomeSectionCard extends StatelessWidget {
  const HomeSectionCard({
    super.key,
    required this.background,
    required this.icon,
    required this.title,
    required this.color,
    required this.subtitle,
    this.onTap,
    this.isLoading = false,
    this.isDisabled = false,
  });

  final AssetGenImage background;
  final SvgGenImage icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback? onTap;
  final bool isLoading;
  final bool isDisabled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading || isDisabled ? null : onTap,
      child: Opacity(
        opacity: isDisabled ? 0.5 : 1,
        child: Stack(
          children: [
            background.image(width: double.infinity, fit: BoxFit.fitWidth),
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.only(left: 8.w, right: 18.w),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: context.colors.background,
                      ),
                      child: isLoading
                          ? LoadingAnimationWidget.staggeredDotsWave(
                              size: 24.w,
                              color: color,
                            )
                          : icon.svg(color: color, width: 28.w, height: 28.h),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            style: context.typography.headline.copyWith(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: context.colors.tertiary,
                              fontFamily: 'sfpro',
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            subtitle,
                            style: context.typography.body.copyWith(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w400,
                              height: 1.3,
                              color: context.colors.tertiary,
                              fontFamily: 'sfpro',
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: context.colors.tertiary,
                      size: 20.w,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
