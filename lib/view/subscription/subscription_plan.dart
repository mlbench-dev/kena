import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kena_emotional_journey/app/components/my_button.dart';
import 'package:kena_emotional_journey/app/components/my_dialog.dart';
import 'package:kena_emotional_journey/app/components/my_scaffold.dart';
import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';
import 'package:kena_emotional_journey/app/utils/extensions/flush_bar_extension.dart';
import 'package:kena_emotional_journey/services/common/auth_service.dart';
import 'package:kena_emotional_journey/services/payment/iap_services.dart';
import 'package:kena_emotional_journey/services/payment/paystack_subscription_service.dart';
import 'package:kena_emotional_journey/services/payment/subscription_cache_service.dart';
import 'package:kena_emotional_journey/services/payment/subscription_services.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class SubscriptionPlanScreen extends StatefulWidget {
  final bool showBackButton;
  const SubscriptionPlanScreen({super.key, this.showBackButton = false});

  @override
  State<SubscriptionPlanScreen> createState() => _SubscriptionPlanScreenState();
}

class _SubscriptionPlanScreenState extends State<SubscriptionPlanScreen> {
  int selectedIndex = 0;
  bool isSubscriptionLoading = false;
  bool isPlansLoading = true;

  final InAppPurchaseServices _iapServices = InAppPurchaseServices();
  final PaystackSubscriptionService _paystackService =
      PaystackSubscriptionService();

  List<Map<String, dynamic>> availablePlans = [];
  String? selectedPriceId;
  int? trialDays;

  @override
  void initState() {
    super.initState();
    _loadSubscriptionPlans();

    // Only load IAP for iOS
    if (Platform.isIOS) {
      _iapServices.loadSubscriptions(null, null);
      _iapServices.startListeningToPurchaseUpdates(context);
    }
  }

  @override
  void dispose() {
    if (Platform.isIOS) {
      _iapServices.closeSubscriptionStream();
    }
    super.dispose();
  }

  Future<void> _loadSubscriptionPlans() async {
    setState(() => isPlansLoading = true);

    try {
      // Initialize Paystack config
      await _paystackService.initializePaystack();

      // Load plans from API (with fallback handled in service)
      final plans = await _paystackService.getSubscriptionPlans();

      if (plans != null && mounted) {
        setState(() {
          availablePlans = plans;
          if (plans.isNotEmpty) {
            selectedPriceId = plans[0]['priceId'] as String?;
          }
          isPlansLoading = false;
        });

        debugPrint('✅ Loaded ${plans.length} subscription plans');
        for (final plan in plans) {
          debugPrint(
            'Plan: ${plan['name']} - ${plan['priceId']} - ${plan['unitAmountDecimal']}',
          );
        }
      } else {
        setState(() => isPlansLoading = false);
        debugPrint('❌ No plans available');
      }
    } catch (e) {
      debugPrint('❌ Error loading subscription plans: $e');
      setState(() => isPlansLoading = false);
    }
  }

  String _getCurrencySymbol(String currency) {
    switch (currency.toUpperCase()) {
      case 'KES':
        return 'KES';
      case 'NGN':
        return '₦';
      case 'USD':
        return '\$';
      case 'GHS':
        return 'GH₵';
      default:
        return '${currency.toUpperCase()} ';
    }
  }

  String _getPaidFeaturesTitle() {
    final planName = selectedIndex >= 0 && selectedIndex < availablePlans.length
        ? (availablePlans[selectedIndex]['name'] as String? ?? '').toLowerCase()
        : '';
    return planName.contains('month')
        ? 'Monthly includes:'
        : 'Annual includes:';
  }

  List<String> _getFeatures({required bool isFreemium}) {
    return [
      isFreemium ? 'With ads' : 'Remove ads - Premium',
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
    ];
  }

  Widget _buildPlanOption({
    required bool isSelected,
    required String name,
    required String description,
    required String priceText,
    String? intervalText,
    required VoidCallback onTap,
  }) {
    const Color kenaDarkGreen = Color(0xFF34543B);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.symmetric(vertical: 25.w, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15.r),
          border: Border.all(
            color: isSelected
                ? kenaDarkGreen
                : Colors.grey.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Custom Radio Circle
            Container(
              width: 18.r,
              height: 18.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? kenaDarkGreen : Colors.grey,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 11.r,
                        height: 11.r,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: kenaDarkGreen,
                        ),
                      ),
                    )
                  : null,
            ),
            SizedBox(width: 12.w),

            // Text Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: context.typography.title.copyWith(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: context.colors.textPrimary,
                    ),
                  ),
                  // Text(
                  //   description,
                  //   style: context.typography.body.copyWith(
                  //     fontSize: 13.sp,
                  //     color: context.colors.textSecondary,
                  //     fontFamily: "Raleway",
                  //     fontWeight: FontWeight.w400,
                  //   ),
                  // ),
                ],
              ),
            ),

            // Price Content
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  priceText,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: context.colors.primary,
                    fontFamily: 'Inter',
                  ),
                ),
                if (intervalText != null)
                  Text(
                    intervalText,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[500],
                      fontFamily: 'Inter',
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        leading: widget.showBackButton
            ? BackButton(
                onPressed: () => Navigator.pop(context),
                color: context.colors.primary,
              )
            : const SizedBox.shrink(),
        title: Text(
          "Choose Your Plan",
          style: context.typography.headline.copyWith(
            fontSize: 20.sp,
            fontFamily: "Raleway",
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: isPlansLoading
          ? Center(
              child: LoadingAnimationWidget.staggeredDotsWave(
                color: context.colors.primary,
                size: 45,
              ),
            )
          : Padding(
              padding: EdgeInsets.only(
                left: 16.w,
                right: 16.w,
                bottom: 10.h,
                top: 10.h,
              ),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildPlanOption(
                            isSelected: selectedIndex == -1,
                            name: 'Freemium',
                            description: 'With Ads',
                            priceText: 'Free',
                            onTap: () {
                              setState(() {
                                selectedIndex = -1;
                                selectedPriceId = null;
                              });
                            },
                          ),
                          // Display subscription plans from API
                          if (availablePlans.isNotEmpty) ...[
                            for (int i = 0; i < availablePlans.length; i++)
                              _buildPlanOption(
                                isSelected: selectedIndex == i,
                                name:
                                    (availablePlans[i]['interval'] as String?)
                                            ?.toLowerCase() ==
                                        'year'
                                    ? 'Annual'
                                    : 'Monthly',
                                description: 'Best for getting started',
                                priceText:
                                    '${_getCurrencySymbol(availablePlans[i]['currency'] as String? ?? 'KES')}${availablePlans[i]['unitAmountDecimal'] as String? ?? '0.00'}',
                                intervalText:
                                    '/${availablePlans[i]['interval'] as String? ?? 'month'}',
                                onTap: () {
                                  setState(() {
                                    selectedIndex = i;
                                    selectedPriceId =
                                        availablePlans[i]['priceId'] as String?;
                                  });
                                },
                              ),
                            SizedBox(height: 16.h),
                          ],
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
                                if (selectedIndex == -1)
                                  FeaturesList(
                                    title: "Freemium includes:",
                                    features: _getFeatures(isFreemium: true),
                                  )
                                else
                                  FeaturesList(
                                    title: _getPaidFeaturesTitle(),
                                    features: _getFeatures(isFreemium: false),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  MyButton(
                    label: "Proceed",
                    isLoading: isSubscriptionLoading,
                    onPressed: () async {
                      // ── FREEMIUM: no payment needed ──────────────────────
                      if (selectedIndex == -1) {
                        setState(() => isSubscriptionLoading = true);
                        try {
                          final currentSubscription = await _paystackService
                              .getCurrentSubscriptionStatus();
                          final currentStatus = currentSubscription?['status']
                              ?.toString()
                              .toLowerCase();
                          final currentType =
                              currentSubscription?['subscriptionType']
                                  ?.toString()
                                  .toLowerCase();
                          final isFreemium =
                              currentStatus == 'freemium' ||
                              currentType == 'freemium';
                          final hasExistingSubscription =
                              !isFreemium &&
                              (currentSubscription?['isActive'] == true ||
                                  currentSubscription?['isTrial'] == true ||
                                  currentSubscription?['hasSubscription'] ==
                                      true ||
                                  currentStatus == 'active' ||
                                  currentStatus == 'trial');

                          if (hasExistingSubscription) {
                            final shouldSwitch = await MyDialogBox.show<bool>(
                              context,
                              child: const FreemiumChangeDialog(),
                            );
                            if (shouldSwitch != true) return;
                          }

                          // 1. Save locally first — app access is immediate
                          await SubscriptionCacheService()
                              .saveFreemiumSubscription();

                          // 2. Sync with backend (best-effort, non-blocking)
                          //    Errors are caught inside selectFreemiumPlan()
                          //    so the UX is never blocked.
                          _paystackService.selectFreemiumPlan().then((_) {
                            debugPrint('🟢 Freemium backend sync completed');
                          });

                          if (context.mounted) {
                            context.flushBarSuccessMessage(
                              message:
                                  'Welcome! You are now on the Freemium plan.',
                            );
                            await Future.delayed(const Duration(seconds: 3));
                            if (context.mounted) {
                              AuthService.goToUserHome(context);
                            }
                          }
                        } finally {
                          if (mounted) {
                            setState(() => isSubscriptionLoading = false);
                          }
                        }
                        return;
                      }

                      // ── PAID PLAN ─────────────────────────────────────────
                      if (selectedPriceId == null) {
                        if (context.mounted) {
                          context.flushBarErrorMessage(
                            message: 'Please select a plan',
                          );
                        }
                        return;
                      }

                      // Check if user is already subscribed to this plan
                      final currentSubscription = await _paystackService
                          .getCurrentSubscriptionStatus();
                      final currentPriceId =
                          currentSubscription?['priceId'] as String?;
                      final isActive = currentSubscription?['isActive'] == true;

                      debugPrint('🔍 Subscription Check:');
                      debugPrint('  Current priceId: $currentPriceId');
                      debugPrint('  Selected priceId: $selectedPriceId');
                      debugPrint('  Is active: $isActive');
                      debugPrint(
                        '  Match: ${currentPriceId == selectedPriceId}',
                      );

                      // Only show dialog if user has an active subscription to the SAME plan
                      if (isActive && currentPriceId == selectedPriceId) {
                        // User is already subscribed to this plan, show dialog
                        if (mounted) {
                          MyDialogBox.show(
                            context,
                            child: AlreadySubscribedDialog(
                              onResubscribe: () async {
                                setState(() => isSubscriptionLoading = true);
                                try {
                                  await SubscriptionScreenService()
                                      .handleSubscribeButton(
                                        context,
                                        selectedIndex,
                                        isSignupFlow: false,
                                        updateLoading: () {
                                          if (mounted) {
                                            setState(
                                              () => isSubscriptionLoading =
                                                  !isSubscriptionLoading,
                                            );
                                          }
                                        },
                                        priceId: selectedPriceId,
                                      );
                                } finally {
                                  if (mounted) {
                                    setState(
                                      () => isSubscriptionLoading = false,
                                    );
                                  }
                                }
                              },
                            ),
                          );
                        }
                        return;
                      }

                      // User already has an active subscription on a
                      // DIFFERENT plan — the backend rejects /mobile/subscribe
                      // in this case (409 "subscription already exists").
                      // Switching plans must go through /subscription/change.
                      //
                      // On iOS this must still go through StoreKit: buying a
                      // new product in the same subscription group is how
                      // Apple handles upgrade/downgrade/proration. Calling
                      // Paystack's web checkout here would bypass Apple's IAP
                      // requirement for digital subscriptions.
                      if (isActive &&
                          currentPriceId != null &&
                          Platform.isIOS) {
                        setState(() => isSubscriptionLoading = true);
                        try {
                          await SubscriptionScreenService()
                              .handleSubscribeButton(
                                context,
                                selectedIndex,
                                isSignupFlow: false,
                                updateLoading: () {
                                  if (mounted) {
                                    setState(
                                      () => isSubscriptionLoading =
                                          !isSubscriptionLoading,
                                    );
                                  }
                                },
                                priceId: selectedPriceId,
                              );
                        } finally {
                          if (mounted) {
                            setState(() => isSubscriptionLoading = false);
                          }
                        }
                        return;
                      }

                      if (isActive && currentPriceId != null) {
                        setState(() => isSubscriptionLoading = true);
                        try {
                          final result = await _paystackService
                              .changeSubscriptionPlan(
                                context,
                                selectedPriceId!,
                              );
                          if (result != null && context.mounted) {
                            if (widget.showBackButton) {
                              // Delay to let the success flushbar's route
                              // finish pushing before we pop this screen —
                              // popping immediately can pop the flushbar's
                              // own route instead of this one.
                              await Future.delayed(const Duration(seconds: 1));
                              if (context.mounted) {
                                Navigator.pop(context, true);
                              }
                            } else {
                              await Future.delayed(const Duration(seconds: 1));
                              if (context.mounted) {
                                AuthService.goToUserHome(context);
                              }
                            }
                          }
                        } finally {
                          if (mounted) {
                            setState(() => isSubscriptionLoading = false);
                          }
                        }
                        return;
                      }

                      setState(() => isSubscriptionLoading = true);
                      try {
                        await SubscriptionScreenService().handleSubscribeButton(
                          context,
                          selectedIndex,
                          isSignupFlow: false,
                          updateLoading: () {
                            if (mounted) {
                              setState(
                                () => isSubscriptionLoading =
                                    !isSubscriptionLoading,
                              );
                            }
                          },
                          priceId: selectedPriceId,
                        );
                      } finally {
                        if (mounted) {
                          setState(() => isSubscriptionLoading = false);
                        }
                      }
                    },
                    fontWeight: FontWeight.w600,
                    fontSize: 16.sp,
                  ),
                ],
              ),
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
        Icon(Icons.check, color: context.colors.primary, size: 18.r),
        SizedBox(width: 5.w),
        Text(
          title,
          style: context.typography.title.copyWith(
            fontSize: 12.sp,
            fontWeight: FontWeight.w400,
            color: context.colors.textSecondary.withValues(alpha: 0.9),
            fontFamily: "sfpro",
          ),
        ),
      ],
    );
  }
}

class AlreadySubscribedDialog extends StatelessWidget {
  const AlreadySubscribedDialog({super.key, required this.onResubscribe});

  final VoidCallback onResubscribe;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20.r)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Already Subscribed",
            style: context.typography.title.copyWith(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: context.colors.textPrimary,
              fontFamily: "Raleway",
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            "You're already subscribed to this plan. Would you like to resubscribe?",
            textAlign: TextAlign.center,
            style: context.typography.title.copyWith(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: context.colors.textSecondary,
              fontFamily: "Raleway",
            ),
          ),
          SizedBox(height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: context.colors.textSecondary.withValues(
                        alpha: 0.2,
                      ),
                      borderRadius: BorderRadius.circular(15.r),
                    ),
                    child: Center(
                      child: Text(
                        "Cancel",
                        style: context.typography.title.copyWith(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: context.colors.textPrimary,
                          fontFamily: "Raleway",
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: MyButton(
                  fontWeight: FontWeight.w600,
                  label: "Resubscribe",
                  onPressed: () {
                    Navigator.pop(context);
                    onResubscribe();
                  },
                  backgroundColor: context.colors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class FreemiumChangeDialog extends StatelessWidget {
  const FreemiumChangeDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20.r)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Switch to Freemium?',
            textAlign: TextAlign.center,
            style: context.typography.title.copyWith(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: context.colors.textPrimary,
              fontFamily: 'Raleway',
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Are you sure you want to change your current plan to Freemium? Your current subscription will be replaced, premium benefits will end, and ads will be shown.',
            textAlign: TextAlign.center,
            style: context.typography.title.copyWith(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: context.colors.textSecondary,
              fontFamily: 'Raleway',
            ),
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context, false),
                  child: Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: context.colors.textSecondary.withValues(
                        alpha: 0.2,
                      ),
                      borderRadius: BorderRadius.circular(15.r),
                    ),
                    child: Center(
                      child: Text(
                        'Cancel',
                        style: context.typography.title.copyWith(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: context.colors.textPrimary,
                          fontFamily: 'Raleway',
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: MyButton(
                  fontWeight: FontWeight.w600,
                  label: 'Confirm',
                  onPressed: () => Navigator.pop(context, true),
                  backgroundColor: context.colors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
