import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kena_emotional_journey/app/components/loading_widget.dart';
import 'package:kena_emotional_journey/app/components/my_bottom_sheet.dart';
import 'package:kena_emotional_journey/app/components/my_button.dart';
import 'package:kena_emotional_journey/app/components/my_scaffold.dart';
import 'package:kena_emotional_journey/app/components/my_text_field.dart';
import 'package:kena_emotional_journey/app/components/ui_helper.dart';
import 'package:kena_emotional_journey/app/routes/routes_name.dart';
import 'package:kena_emotional_journey/app/utils/app_constants.dart';
import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';
import 'package:kena_emotional_journey/app/utils/extensions/flush_bar_extension.dart';
import 'package:kena_emotional_journey/app/utils/legal_links.dart';
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
  bool _canRequestRefund = false;
  Map<String, dynamic>? _refund;
  bool _isWithdrawingRefund = false;

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

          setState(() => _applySubscriptionData(data));
        }
      } else {
        debugPrint('⚠️ No subscription data returned');
        if (mounted) {
          setState(() {
            _hasSubscription = false;
            _isFreemium = false;
            _pendingSubscriptionType = null;
            _pendingChangeEffectiveDate = null;
            _canRequestRefund = false;
            _refund = null;
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

  /// Copies a `/subscription/me` (or `/subscription/refund`) payload into
  /// state. Call inside setState.
  void _applySubscriptionData(Map<String, dynamic> data) {
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
    _pendingSubscriptionType = data['pendingSubscriptionType']?.toString();
    _pendingChangeEffectiveDate = data['pendingChangeEffectiveDate']
        ?.toString();
    _canRequestRefund = data['canRequestRefund'] == true;
    _refund = data['refund'] is Map<String, dynamic>
        ? data['refund'] as Map<String, dynamic>
        : null;

    // Parse price from API
    final priceJson = data['price'];
    _price = priceJson is Map<String, dynamic>
        ? Price.fromJson(priceJson)
        : null;
  }

  /// Monthly or annual paid plan (never freemium).
  bool get _isPaidPlan {
    if (_isFreemium) return false;
    final subType = _subscriptionType?.toLowerCase();
    final interval = _price?.interval?.toLowerCase();
    return subType == 'monthly' ||
        subType == 'annual' ||
        interval == 'month' ||
        interval == 'year';
  }

  bool get _showRefundButton => _isPaidPlan && _canRequestRefund;

  String? get _refundStatus => _refund?['status']?.toString();

  /// Opens the refund request sheet and applies the updated subscription
  /// when the request is submitted.
  Future<void> _handleRequestRefund() async {
    final updated = await MyBottomSheet.show<Map<String, dynamic>>(
      context,
      backgroundColor: context.colors.background,
      child: _RefundRequestSheet(service: _paystackService),
    );
    if (!mounted || updated == null) return;

    setState(() => _applySubscriptionData(updated));
    context.flushBarSuccessMessage(message: 'Refund request submitted');
  }

  /// Withdraws a refund request that is still pending review.
  Future<void> _handleWithdrawRefund() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel refund request?'),
        content: const Text(
          'Your refund request will be withdrawn and your subscription will continue as normal.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep Request'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Cancel Request'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isWithdrawingRefund = true);
    final result = await _paystackService.withdrawRefund();
    if (!mounted) return;
    setState(() => _isWithdrawingRefund = false);

    if (result.isSuccess) {
      setState(() => _applySubscriptionData(result.subscription!));
      context.flushBarSuccessMessage(message: 'Refund request cancelled');
    } else {
      context.flushBarErrorMessage(message: result.errorMessage!);
      // State may have moved on (e.g. already reviewed) — resync.
      await _fetchSubscriptionData();
    }
  }

  /// User-facing text for the current refund status, or null when there is
  /// nothing to show (no request, or it was withdrawn).
  String? _getRefundStatusText() {
    switch (_refundStatus) {
      case 'pending_review':
        return 'Your refund request is being reviewed.';
      case 'processing':
        return 'Refund approved. Your money is on its way (5–10 business days).';
      case 'refunded':
        return 'Refund completed on ${_formatDate(_refund?['refundedAt']?.toString())}.';
      case 'rejected':
        final note = _refund?['adminNote']?.toString();
        return note != null && note.isNotEmpty
            ? 'Your refund request was declined: $note'
            : 'Your refund request was declined.';
      case 'failed':
        return 'There was a problem with your refund. Our team is looking into it.';
      default:
        return null;
    }
  }

  Widget _buildRefundStatusCard() {
    final text = _getRefundStatusText();
    if (text == null) return const SizedBox.shrink();

    final (
      Color bg,
      Color border,
      Color fg,
      IconData icon,
    ) = switch (_refundStatus) {
      'pending_review' => (
        const Color(0xFFFFF9E6),
        const Color(0xFFE6D5A8),
        const Color(0xFFB8860B),
        Icons.hourglass_top,
      ),
      'processing' || 'refunded' => (
        const Color(0xFFEAF7EE),
        const Color(0xFFB5DEC2),
        const Color(0xFF2E7D4F),
        Icons.check_circle_outline,
      ),
      _ => (
        const Color(0xFFFDECEA),
        const Color(0xFFF2C2BC),
        const Color(0xFFC0392B),
        Icons.error_outline,
      ),
    };

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: 10.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: fg, size: 20.sp),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  text,
                  style: context.typography.body.copyWith(
                    fontSize: 12,
                    color: fg,
                  ),
                ),
              ),
            ],
          ),
          if (_refundStatus == 'pending_review')
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _isWithdrawingRefund ? null : _handleWithdrawRefund,
                child: _isWithdrawingRefund
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: LoadingWidget(size: 2),
                      )
                    : Text(
                        'Cancel request',
                        style: context.typography.body.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: fg,
                          decoration: TextDecoration.underline,
                          decorationColor: fg,
                        ),
                      ),
              ),
            ),
        ],
      ),
    );
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

  String _getFeaturesTitle() => '${_getPlanName()} includes:';

  List<String> _getFeatures() {
    return [
      _isFreemium ? 'With ads' : 'Remove ads - Premium',
      'Record core & aspirational emotions',
      'Record Daily pulse',
      'Comprehensive list of emotions',
      'Visualisation of emotions',
      'Journaling & Notes',
      'Full activities',
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

  /// Get price display from API data.
  /// Shown during trial too — Apple requires the price the user will be
  /// charged to be visible on the subscription screen, not hidden until
  /// the trial ends.
  String _getPriceText() {
    if (_isFreemium) return 'Free';

    // iOS uses hardcoded StoreKit prices ($9.99/mo, $99.99/yr) since Apple
    // pricing is fixed per product, independent of the backend-reported
    // currency/amount used on Android.
    if (Platform.isIOS) {
      final interval = _price?.interval?.toLowerCase();
      final subType = _subscriptionType?.toLowerCase();
      if (interval == 'year' || subType == 'annual') return '\$99.99';
      if (interval == 'month' || subType == 'monthly') return '\$9.99';
      return '';
    }

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
      // No auto-renewal happens at trial end — the user must subscribe
      // manually, so this only discloses the price, never a renewal promise.
      final priceText = _getPriceText();
      final intervalText = _getBillingInterval();
      final billingLine = priceText.isNotEmpty
          ? ' Subscribe for $priceText$intervalText to continue after your trial ends.'
          : '';

      if (_daysRemaining != null) {
        return 'You have $_daysRemaining days remaining in your trial period.$billingLine';
      }
      return 'Your trial period is active.$billingLine';
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
    await Navigator.pushNamed(
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
        leading: BackButton(color: context.colors.textPrimary),
        centerTitle: true,
        title: Text(
          _isLoading ? "Subscription Plan" : _getPlanName(),
          style: context.typography.title.copyWith(
            color: const Color(0xFF172A2B),
            fontSize: 20,
            fontWeight: FontWeight.w600,
            fontFamily: "sfpro",
          ),
        ),
        actions: [
          if (!_isLoading && _showRefundButton)
            TextButton(
              onPressed: _handleRequestRefund,
              child: Text(
                'Refund',
                style: context.typography.body.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: context.colors.tertiary,
                  fontFamily: "sfpro",
                ),
              ),
            ),
        ],
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
                      constraints: const BoxConstraints(minHeight: 77),
                      decoration: BoxDecoration(
                        color: context.colors.tertiary,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                    color: Color(0x80F3E5AB),
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

                    /// 🔹 Refund status
                    _buildRefundStatusCard(),

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
                    SizedBox(height: 16.h),

                    /// 🔹 Terms of Use & Privacy Policy
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

/// Bottom sheet collecting the refund reason. Pops with the updated
/// subscription map when the request is submitted.
class _RefundRequestSheet extends StatefulWidget {
  const _RefundRequestSheet({required this.service});

  final PaystackSubscriptionService service;

  @override
  State<_RefundRequestSheet> createState() => _RefundRequestSheetState();
}

class _RefundRequestSheetState extends State<_RefundRequestSheet> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final result = await widget.service.requestRefund(
      reason: _reasonController.text.trim(),
    );
    if (!mounted) return;

    if (result.isSuccess) {
      Navigator.of(context).pop(result.subscription);
      return;
    }

    // A request is already open — show its status on the subscription screen.
    if (result.code == 'refund_already_requested') {
      final status = await widget.service.getRefundStatus();
      if (!mounted) return;
      if (status.isSuccess) {
        Navigator.of(context).pop(status.subscription);
        return;
      }
    }

    setState(() {
      _isSubmitting = false;
      _errorMessage = result.errorMessage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 16.h),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Request a refund',
              style: context.typography.title.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: context.colors.textPrimary,
                fontFamily: "sfpro",
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Our team will review your request. If approved, your subscription will end and the payment will be refunded.',
              style: context.typography.body.copyWith(
                fontSize: 13,
                color: context.colors.textSecondary,
                fontFamily: "sfpro",
              ),
            ),
            SizedBox(height: 16.h),
            MyTextField(
              controller: _reasonController,
              borderColor: context.colors.textSecondary.withValues(alpha: 0.02),
              fillColor: context.colors.textSecondary.withValues(alpha: 0.04),
              enabled: !_isSubmitting,
              maxLines: 4,
              maxLength: 500,
              textCapitalization: TextCapitalization.sentences,
              hint: 'Why would you like a refund?',
              borderRadius: 16.r,
              validator: (value) {
                final reason = value?.trim() ?? '';
                if (reason.length < 3) {
                  return 'Please enter at least 3 characters';
                }
                return null;
              },
            ),
            if (_errorMessage != null) ...[
              SizedBox(height: 4.h),
              Text(
                _errorMessage!,
                style: context.typography.body.copyWith(
                  fontSize: 13,
                  color: Colors.red,
                ),
              ),
            ],
            SizedBox(height: 16.h),
            MyButton(
              label: 'Submit',
              isLoading: _isSubmitting,
              onPressed: _isSubmitting ? null : _submit,
            ),
          ],
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
        color: context.colors.textSecondary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10.r),
        // border: Border.all(
        //   color: context.colors.textSecondary.withValues(alpha: 0.2),
        // ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: sections.map((section) {
          return Padding(
            padding: EdgeInsets.only(bottom: 8.h),
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
                SizedBox(height: 10.h),
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
        Icon(Icons.check, color: context.colors.tertiary, size: 17),
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
