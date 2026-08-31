import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kena_emotional_journey/app/components/loading_widget.dart';
import 'package:kena_emotional_journey/app/components/my_button.dart';
import 'package:kena_emotional_journey/app/components/my_scaffold.dart';
import 'package:kena_emotional_journey/app/components/ui_helper.dart';
import 'package:kena_emotional_journey/app/routes/routes_name.dart';
import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';
import 'package:kena_emotional_journey/app/utils/extensions/flush_bar_extension.dart';
import 'package:kena_emotional_journey/model/subscription/subscription_model.dart';
import 'package:kena_emotional_journey/services/payment/paystack_subscription_service.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class ActiveSubscriptionScreen extends StatefulWidget {
  const ActiveSubscriptionScreen({super.key});

  @override
  State<ActiveSubscriptionScreen> createState() =>
      _ActiveSubscriptionScreenState();
}

class _ActiveSubscriptionScreenState extends State<ActiveSubscriptionScreen> {
  final _paystackService = PaystackSubscriptionService();

  bool _isLoading = true;
  bool _hasSubscription = false;
  bool _isActive = false;
  bool _isTrial = false;
  bool _cancelAtPeriodEnd = false;
  bool _willRenew = false;
  String? _status;
  int? _daysRemaining;
  String? _currentPeriodEnd;
  Price? _price;
  String? _subscriptionType;
  bool _isFreemium = false;
  String? _pendingSubscriptionType;
  String? _pendingChangeEffectiveDate;

  @override
  void initState() {
    super.initState();
    _fetchSubscriptionData();
  }

  Future<void> _fetchSubscriptionData() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final subscription = await _paystackService
          .getCurrentSubscriptionStatus();

      if (subscription != null) {
        debugPrint('✅ Subscription data fetched: $subscription');

        if (mounted) {
          // Parse using SubscriptionModel for type safety
          final data =
              subscription['data'] is List && subscription['data'].isNotEmpty
              ? subscription['data'][0]
              : subscription;

          setState(() {
            _hasSubscription = data['hasSubscription'] == true;
            _isActive = data['isActive'] == true;
            _isTrial = data['isTrial'] == true;
            _cancelAtPeriodEnd = data['cancelAtPeriodEnd'] == true;
            _willRenew = data['willRenew'] == true;
            _status = data['status']?.toString();
            _daysRemaining = data['daysRemaining'] as int?;
            _currentPeriodEnd = data['currentPeriodEnd']?.toString();
            _subscriptionType = data['subscriptionType']?.toString();
            _isFreemium =
                _status?.toLowerCase() == 'freemium' ||
                _subscriptionType?.toLowerCase() == 'freemium';
            _pendingSubscriptionType = data['pendingSubscriptionType']
                ?.toString();
            _pendingChangeEffectiveDate = data['pendingChangeEffectiveDate']
                ?.toString();

            // Parse price from API
            final priceJson = data['price'];
            if (priceJson != null) {
              _price = Price.fromJson(priceJson as Map<String, dynamic>);
            }
          });
        }
      } else {
        debugPrint('⚠️ No subscription data returned');
        if (mounted) {
          setState(() {
            _hasSubscription = false;
            _isFreemium = false;
            _pendingSubscriptionType = null;
            _pendingChangeEffectiveDate = null;
          });
        }
      }
    } catch (e) {
      debugPrint('❌ Error fetching subscription: $e');
      if (mounted) {
        context.flushBarErrorMessage(
          message: 'Failed to load subscription data',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Format date string from ISO format to display format
  String _formatDate(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return 'Unknown';
    try {
      final dateTime = DateTime.parse(isoDate);
      final day = dateTime.day.toString().padLeft(2, '0');
      final month = dateTime.month.toString().padLeft(2, '0');
      final year = dateTime.year.toString();
      return '$month/$day/$year';
    } catch (_) {
      return 'Unknown';
    }
  }

  /// Get the plan name for display (e.g. "Monthly Plan", "Annual Plan")
  String _getPlanName() {
    if (_isFreemium) return 'Freemium';
    if (!_hasSubscription) return 'Subscription Plan';

    final priceName = _price?.name;
    if (priceName != null && priceName.isNotEmpty) return priceName;

    final interval = _price?.interval?.toLowerCase();
    if (interval == 'year' || _subscriptionType == 'annual') {
      return 'Annual Plan';
    }
    if (interval == 'month' || _subscriptionType == 'monthly') {
      return 'Monthly Plan';
    }
    return 'Subscription Plan';
  }

  String _getFeaturesTitle() {
    if (_isFreemium) return 'Freemium includes:';
    if (_subscriptionType?.toLowerCase() == 'monthly' ||
        _price?.interval?.toLowerCase() == 'month') {
      return 'Monthly includes:';
    }
    return 'Annual includes:';
  }

  List<String> _getFeatures() {
    return [
      _isFreemium ? 'With ads' : 'Remove ads - Premium',
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

  /// Get subscription status text for display
  String _getStatusText() {
    if (!_hasSubscription) return 'No Active Subscription';
    if (_isTrial) return 'Trial Period';
    if (_isActive && !_cancelAtPeriodEnd) return 'Active';
    if (_cancelAtPeriodEnd) return 'Cancels at Period End';
    return _status?.toUpperCase() ?? 'Unknown';
  }

  /// Get price display from API data
  String _getPriceText() {
    // Don't show price during trial
    if (_isTrial) return '';

    // Use actual price from API
    if (_price != null) {
      final unitAmount = _price!.unitAmount;
      final unitAmountDecimal = _price!.unitAmountDecimal;
      final currency = _price!.currency?.toUpperCase() ?? 'USD';

      final symbol = _getCurrencySymbol(currency);

      if (unitAmountDecimal != null && unitAmountDecimal.isNotEmpty) {
        return '$symbol$unitAmountDecimal';
      }
      if (unitAmount != null) {
        final amount = unitAmount / 100;
        return '$symbol${amount.toStringAsFixed(2)}';
      }
    }

    return '';
  }

  /// Get currency symbol
  String _getCurrencySymbol(String currency) {
    switch (currency) {
      case 'KES':
        return 'KES';
      case 'NGN':
        return '₦';
      case 'GHS':
        return 'GH₵';
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'JPY':
        return '¥';
      default:
        return '$currency ';
    }
  }

  /// Get billing interval text from API data
  String _getBillingInterval() {
    if (_isTrial) return '/trial';

    final interval = _price?.interval?.toLowerCase();
    if (interval != null && interval.isNotEmpty) {
      return '/$interval';
    }

    // Fallback based on subscription type
    if (_subscriptionType == 'annual') return '/year';
    if (_subscriptionType == 'monthly') return '/month';

    return '';
  }

  /// Get text describing a pending Apple plan change (e.g. a scheduled
  /// monthly -> annual crossgrade), or null if none is pending.
  String? _getPendingChangeText() {
    if (_pendingSubscriptionType == null || _pendingSubscriptionType!.isEmpty) {
      return null;
    }

    final planName = _pendingSubscriptionType == 'annual'
        ? 'Annual Plan'
        : _pendingSubscriptionType == 'monthly'
        ? 'Monthly Plan'
        : _pendingSubscriptionType!;

    if (_pendingChangeEffectiveDate != null) {
      return 'Switching to $planName on ${_formatDate(_pendingChangeEffectiveDate)}.';
    }
    return 'Switching to $planName at the end of your current billing period.';
  }

  /// Get renewal text based on subscription status
  String _getRenewalText() {
    if (!_hasSubscription) {
      return 'You do not have an active subscription.';
    }

    if (_isTrial) {
      if (_daysRemaining != null) {
        return 'You have $_daysRemaining days remaining in your trial period. Your subscription will start after the trial ends.';
      }
      return 'Your trial period is active. Subscribe to continue enjoying all features.';
    }

    if (_cancelAtPeriodEnd) {
      return 'Your subscription will end on ${_formatDate(_currentPeriodEnd)} and will not be renewed.';
    }

    if (_willRenew && _currentPeriodEnd != null) {
      return 'Your plan will automatically renew on ${_formatDate(_currentPeriodEnd)}.';
    }

    return 'Your subscription is active.';
  }

  /// Handle cancel subscription
  Future<void> _handleCancelSubscription() async {
    if (!_hasSubscription || !_isActive) {
      context.flushBarErrorMessage(message: 'No active subscription to cancel');
      return;
    }

    // Show confirmation dialog
    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Subscription?'),
        content: const Text(
          'Your subscription will be cancelled and will not renew automatically. You can still use the app until the end of your current billing period.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep Subscription'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Cancel Subscription'),
          ),
        ],
      ),
    );

    if (shouldCancel != true) return;

    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final result = await _paystackService.cancelSubscription(
        context,
        atPeriodEnd: true,
      );

      if (result != null) {
        if (mounted) {
          context.flushBarSuccessMessage(
            message: 'Subscription cancelled successfully',
          );
        }
        // Refresh data
        await _fetchSubscriptionData();
      } else {
        if (mounted) {
          context.flushBarErrorMessage(
            message: 'Failed to cancel subscription',
          );
        }
      }
    } catch (e) {
      debugPrint('❌ Error cancelling subscription: $e');
      if (mounted) {
        context.flushBarErrorMessage(message: 'Failed to cancel subscription');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Handle change plan - navigate to subscription plan screen
  /// and refresh data when returning.
  Future<void> _handleChangePlan() async {
    final result = await Navigator.pushNamed(
      context,
      RoutesName.subscriptionPlan,
      arguments: {'showBackButton': true},
    );

    // Refresh subscription data when coming back (regardless of result)
    if (mounted) {
      await _fetchSubscriptionData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      appBar: AppBar(
        systemOverlayStyle: UIHelper.statusBarDark,
        leading: BackButton(color: context.colors.primary),
        centerTitle: true,
        title: Text(
          "Subscription Plan",
          style: context.typography.title.copyWith(
            color: const Color(0xFF172A2B),
            fontSize: 20,
            fontWeight: FontWeight.w600,
            fontFamily: "sfpro",
          ),
        ),
        // actions: [
        // IconButton(
        //   icon: Icon(Icons.refresh, color: context.colors.primary),
        //   onPressed: _isLoading ? null : _fetchSubscriptionData,
        // ),
        // ],
      ),
      body: _isLoading
          ? Center(
              child: LoadingAnimationWidget.staggeredDotsWave(
                color: context.colors.primary,
                size: 45,
              ),
            )
          : SingleChildScrollView(
              // ✅ Prevent overflow
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  children: [
                    /// 🔹 Top Plan Card
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                      width: double.infinity,
                      height: 77,
                      decoration: BoxDecoration(
                        color: context.colors.primary,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _getPlanName(),
                                  style: context.typography.title.copyWith(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w700,
                                    color: context.colors.background,
                                    fontFamily: "Raleway",
                                  ),
                                ),
                                SizedBox(height: 3.h),
                                Text(
                                  _getStatusText(),
                                  style: context.typography.title.copyWith(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: context.colors.background.withValues(
                                      alpha: 0.8,
                                    ),
                                    fontFamily: "Raleway",
                                  ),
                                ),
                              ],
                            ),
                          ),

                          /// Show price only if not trial and has price data
                          if (_getPriceText().isNotEmpty)
                            Row(
                              children: [
                                Text(
                                  _getPriceText(),
                                  style: const TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFFF3E5AB),
                                  ),
                                ),
                                SizedBox(width: 3.w),
                                Text(
                                  _getBillingInterval(),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xfff3e5ab80),
                                    fontStyle: FontStyle.italic,
                                    fontFamily: "sfpro",
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),

                    SizedBox(height: 10.h),

                    /// 🔹 Renewal Text
                    Text(
                      _getRenewalText(),
                      style: context.typography.title.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: context.colors.textSecondary,
                        fontFamily: "sfpro",
                      ),
                    ),

                    if (_getPendingChangeText() != null) ...[
                      SizedBox(height: 10.h),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAF3FF),
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: const Color(0xFFB8D4F5)),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.event_repeat,
                              color: const Color(0xFF1F6FCF),
                              size: 20.sp,
                            ),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: Text(
                                _getPendingChangeText()!,
                                style: context.typography.body.copyWith(
                                  fontSize: 12,
                                  color: const Color(0xFF1F6FCF),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    SizedBox(height: 10.h),

                    /// 🔹 Single Container (All Sections)
                    PlanIncludes(
                      sections: [
                        PlanSection(
                          title: _getFeaturesTitle(),
                          items: _getFeatures(),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.h),

                    /// 🔹 Cancel Plan UI - Platform Specific
                    /// Android: Show Cancel Button
                    /// iOS: Show message to cancel from Apple Account Settings
                    if (_hasSubscription && _isActive && !_cancelAtPeriodEnd)
                      Platform.isAndroid
                          ? TextButton(
                              onPressed: _isLoading
                                  ? null
                                  : _handleCancelSubscription,
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: LoadingWidget(size: 2),
                                    )
                                  : Text(
                                      "Cancel Plan",
                                      style: context.typography.body.copyWith(
                                        fontFamily: "Raleway",
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: context.colors.primary,
                                        decoration: TextDecoration.underline,
                                        decorationColor: context.colors.primary,
                                      ),
                                    ),
                            )
                          : Padding(
                              padding: EdgeInsets.only(bottom: 16.h),
                              child: Container(
                                padding: EdgeInsets.all(12.w),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF9E6),
                                  borderRadius: BorderRadius.circular(8.r),
                                  border: Border.all(
                                    color: const Color(0xFFE6D5A8),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      color: const Color(0xFFB8860B),
                                      size: 20.sp,
                                    ),
                                    SizedBox(width: 10.w),
                                    Expanded(
                                      child: Text(
                                        "To cancel, go to iPhone Settings > Apple Account > Subscriptions",
                                        style: context.typography.body.copyWith(
                                          fontSize: 12,
                                          color: const Color(0xFFB8860B),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                    /// 🔹 Change Plan Button
                    MyButton(
                      label: _hasSubscription && _isActive
                          ? "Change Plan"
                          : "Subscribe Now",
                      onPressed: _isLoading ? null : _handleChangePlan,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

/// 🔹 Model for Sections
class PlanSection {
  final String title;
  final List<String> items;

  PlanSection({required this.title, required this.items});
}

/// 🔹 Single Container Widget
class PlanIncludes extends StatelessWidget {
  final List<PlanSection> sections;

  const PlanIncludes({super.key, required this.sections});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF4EA),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: context.colors.textSecondary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: sections.map((section) {
          return Padding(
            padding: EdgeInsets.only(bottom: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  section.title,
                  style: context.typography.title.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: context.colors.textPrimary,
                    fontFamily: "sfpro",
                  ),
                ),

                ...section.items.map(
                  (item) => Padding(
                    padding: EdgeInsets.only(bottom: 6.h),
                    child: PlanIncludesTile(text: item),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// 🔹 Tile
class PlanIncludesTile extends StatelessWidget {
  final String text;

  const PlanIncludesTile({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.check, color: context.colors.primary, size: 17),
        SizedBox(width: 10.w),
        Expanded(
          // ✅ prevents overflow for long text
          child: Text(
            text,
            style: context.typography.title.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: context.colors.textPrimary.withValues(alpha: 0.8),
              fontFamily: "sfpro",
            ),
          ),
        ),
      ],
    );
  }
}
