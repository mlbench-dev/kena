import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kena_emotional_journey/app/components/my_button.dart';
import 'package:kena_emotional_journey/app/components/my_dialog.dart';
import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';
import 'package:kena_emotional_journey/generated/assets/assets.gen.dart';
import 'package:kena_emotional_journey/services/payment/paystack_subscription_service.dart';
import 'package:kena_emotional_journey/view/subscription/active_subscription_screen.dart';

const _featuresBackgroundColor = Color(0xFFF2F3F5);

/// "Get Premium" upsell shown when a Freemium user taps a Premium-only feature.
/// The monthly price is loaded from the plans API.
class PremiumDialog extends StatefulWidget {
  const PremiumDialog({
    super.key,
    this.features = const [
      'Unlimited activities',
      'All Time analytics & full calendar history',
      'Search emotions by body sensation',
      'Share your daily & weekly forecasts',
      "View friends' weekly forecasts",
    ],
  });

  final List<String> features;

  static Future<void> show(BuildContext context) {
    return MyDialogBox.show(context, child: const PremiumDialog());
  }

  @override
  State<PremiumDialog> createState() => _PremiumDialogState();
}

class _PremiumDialogState extends State<PremiumDialog> {
  String? _price;
  bool _isPriceLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPrice();
  }

  Future<void> _loadPrice() async {
    final price = await PaystackSubscriptionService().getMonthlyPriceText();
    if (!mounted) return;
    setState(() {
      _price = price;
      _isPriceLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: _featuresBackgroundColor,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.close,
                  color: context.colors.tertiary.withValues(alpha: 0.7),
                  size: 22.sp,
                ),
              ),
            ),
          ),
          Assets.icons.premiumBadge.svg(width: 48.w, height: 44.h),
          SizedBox(height: 8.h),
          Text(
            'Get Premium',
            style: context.typography.headline.copyWith(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: context.colors.tertiary,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Unlock this feature and get access to all premium benefits.',
            textAlign: TextAlign.center,
            style: context.typography.headline.copyWith(
              fontSize: 13.sp,
              fontWeight: FontWeight.w400,
              color: context.colors.textSecondary,
            ),
          ),
          SizedBox(height: 14.h),
          _PlanCard(price: _price, isLoading: _isPriceLoading),
          SizedBox(height: 10.h),
          _FeatureList(features: widget.features),
          SizedBox(height: 14.h),
          MyButton(
            label: 'Manage Plan',
            backgroundColor: context.colors.primary,
            textColor: Colors.white,
            fontSize: 17,
            onPressed: () {
              final navigator = Navigator.of(context)..pop();
              ActiveSubscriptionScreen.open(navigator);
            },
          ),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.price, required this.isLoading});

  final String? price;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
      decoration: BoxDecoration(
        color: context.colors.tertiary,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Monthly Subscription',
            style: context.typography.headline.copyWith(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          if (isLoading)
            SizedBox(
              width: 16.w,
              height: 16.w,
              child: const CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          else if (price != null)
            RichText(
              text: TextSpan(
                text: price,
                style: context.typography.headline.copyWith(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
                children: [
                  TextSpan(
                    text: ' /month',
                    style: context.typography.headline.copyWith(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _FeatureList extends StatelessWidget {
  const _FeatureList({required this.features});

  final List<String> features;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: _featuresBackgroundColor,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        children: [
          for (final feature in features)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 5.h),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check,
                      size: 14.sp,
                      color: context.colors.tertiary,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      feature,
                      style: context.typography.headline.copyWith(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        color: context.colors.tertiary.withValues(alpha: 0.85),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
