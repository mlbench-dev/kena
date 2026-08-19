import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kena_emotional_journey/app/data/exception/app_exceptions.dart';
import 'package:kena_emotional_journey/app/utils/extensions/flush_bar_extension.dart';
import 'package:kena_emotional_journey/repository/payment/paystack_subscription_repo.dart';
import 'package:kena_emotional_journey/services/common/session_manager/session_controller.dart';
import 'package:kena_emotional_journey/services/payment/subscription_cache_service.dart';
import 'package:kena_emotional_journey/view/subscription/paystack_checkout_screen.dart';

/// Handles the Paystack subscription flow: fetch config/plans, subscribe
/// (trial or hosted checkout), and activate after checkout completes.
class PaystackSubscriptionService {
  final PaystackSubscriptionRepository _repository =
      PaystackSubscriptionRepository();

  // Fallback config from .env (client-side only — secret key stays on the backend)
  String? get _fallbackPublicKey => dotenv.env['PAYSTACK_PUBLIC_KEY'];
  String? get _fallbackMonthlyPlanCode =>
      dotenv.env['PAYSTACK_PLAN_MONTHLY_CODE'];
  String? get _fallbackAnnualPlanCode =>
      dotenv.env['PAYSTACK_PLAN_ANNUAL_CODE'];
  String? get _fallbackCallbackUrl => dotenv.env['PAYSTACK_CALLBACK_URL'];
  String get _fallbackCurrency => dotenv.env['PAYSTACK_CURRENCY'] ?? 'KES';

  String? _callbackUrl;

  /// Fetch Paystack config from the backend (public key, trial days, callback URL).
  Future<bool> initializePaystack() async {
    try {
      final response = await _repository.getClientConfig();
      final config = _extractData(response);

      if (config != null) {
        _callbackUrl = config['callbackUrl'] as String? ?? _fallbackCallbackUrl;
        return true;
      }

      _callbackUrl = _fallbackCallbackUrl;
      return _fallbackPublicKey != null;
    } catch (e) {
      debugPrint('Paystack config failed: $e, using fallback');
      _callbackUrl = _fallbackCallbackUrl;
      return _fallbackPublicKey != null;
    }
  }

  Future<List<Map<String, dynamic>>?> getSubscriptionPlans() async {
    try {
      final response = await _repository.getAvailablePlans();
      final plansData = _extractData(response);
      final plans = plansData?['plans'] as List<dynamic>?;

      if (plans != null) {
        return plans.map((plan) => plan as Map<String, dynamic>).toList();
      }
      return _getFallbackPlans();
    } catch (e) {
      debugPrint('Fetching plans failed: $e, using fallback');
      return _getFallbackPlans();
    }
  }

  List<Map<String, dynamic>> _getFallbackPlans() {
    return [
      {
        'priceId': _fallbackMonthlyPlanCode,
        'name': 'Monthly Plan',
        'currency': _fallbackCurrency,
        'unitAmountDecimal': '500.00',
        'interval': 'month',
      },
      {
        'priceId': _fallbackAnnualPlanCode,
        'name': 'Annual Plan',
        'currency': _fallbackCurrency,
        'unitAmountDecimal': '5000.00',
        'interval': 'year',
      },
    ];
  }

  /// Get current user's subscription status and persist it to local cache.
  Future<Map<String, dynamic>?> getCurrentSubscriptionStatus() async {
    try {
      final response = await _repository.getCurrentSubscription();
      final status = _extractData(response);

      if (status != null) {
        await SubscriptionCacheService().saveFromBackendResponse(status);
      }
      return status;
    } on UnauthorizedException {
      rethrow; // let the caller redirect to login
    } on SocketException {
      rethrow; // let the caller show a no-connection state
    } on NoInternetException {
      rethrow;
    } catch (e) {
      debugPrint('Error getting subscription status: $e');
      return null;
    }
  }

  /// Main entry point for subscribing. Handles both trial and checkout modes.
  Future<Map<String, dynamic>?> subscribe(
    BuildContext context,
    String priceId, {
    bool forceCheckout = false,
    VoidCallback? onLoadingChanged,
  }) async {
    try {
      onLoadingChanged?.call();

      // Ensure session token is loaded (especially important on iOS)
      final sessionController = SessionController();
      if (sessionController.token == null) {
        await sessionController.init();
      }

      final response = await _repository.createDirectSubscription(
        priceId: priceId,
        forceCheckout: forceCheckout,
      );
      if (!context.mounted) return null;

      final subscriptionData = _extractData(response);
      if (subscriptionData != null) {
        final mode = subscriptionData['mode'] as String?;
        if (mode == 'trial_setup') {
          return _handleTrialMode(context, subscriptionData);
        }
        return _handleCheckout(context, subscriptionData, priceId: priceId);
      }

      final errorMessage =
          response['message']?.toString() ?? 'Failed to create subscription';
      if (context.mounted) {
        context.flushBarErrorMessage(message: errorMessage);
      }
      return null;
    } catch (e) {
      debugPrint('Error in subscribe: $e');
      if (context.mounted) {
        context.flushBarErrorMessage(message: 'Subscription failed');
      }
      return null;
    } finally {
      onLoadingChanged?.call();
    }
  }

  /// Trial setup is activated instantly server-side — no checkout required.
  Map<String, dynamic>? _handleTrialMode(
    BuildContext context,
    Map<String, dynamic> subscriptionData,
  ) {
    final subscription =
        subscriptionData['subscription'] as Map<String, dynamic>?;
    if (context.mounted) {
      context.flushBarSuccessMessage(message: 'Trial started!');
    }
    return subscription;
  }

  /// Opens the Paystack hosted checkout page, then activates the
  /// subscription once the user completes payment.
  Future<Map<String, dynamic>?> _handleCheckout(
    BuildContext context,
    Map<String, dynamic> subscriptionData, {
    required String priceId,
  }) async {
    final authorizationUrl = subscriptionData['authorizationUrl'] as String?;
    final reference = subscriptionData['reference'] as String?;

    if (authorizationUrl == null || reference == null) {
      // No payment required (e.g. downgrade applied immediately)
      final subscription =
          subscriptionData['subscription'] as Map<String, dynamic>?;
      if (subscription != null && subscription['isActive'] == true) {
        if (context.mounted) {
          context.flushBarSuccessMessage(message: 'Plan updated successfully!');
        }
        return subscription;
      }
      if (context.mounted) {
        context.flushBarErrorMessage(
          message: 'Server did not return payment details. Please try again.',
        );
      }
      return null;
    }

    final completed = await _openCheckout(context, authorizationUrl);
    if (!context.mounted) return null;
    if (!completed) {
      context.flushBarErrorMessage(message: 'Payment was not completed');
      return null;
    }

    return activateSubscription(context, reference, priceId: priceId);
  }

  /// Shows the Paystack checkout page and waits for the user to finish paying.
  Future<bool> _openCheckout(
    BuildContext context,
    String authorizationUrl,
  ) async {
    final completed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => PaystackCheckoutScreen(
          authorizationUrl: authorizationUrl,
          callbackUrl: _callbackUrl ?? _fallbackCallbackUrl,
        ),
      ),
    );
    return completed ?? false;
  }

  /// Confirms the subscription using the Paystack transaction reference.
  Future<Map<String, dynamic>?> activateSubscription(
    BuildContext context,
    String reference, {
    String? priceId,
  }) async {
    try {
      final response = await _repository.activateSubscription(
        reference: reference,
        priceId: priceId,
      );
      final subscriptionData = _extractData(response);

      if (subscriptionData != null) {
        await SubscriptionCacheService().saveFromBackendResponse(
          subscriptionData,
        );
        if (context.mounted) {
          context.flushBarSuccessMessage(message: 'Subscription successful!');
        }
        return subscriptionData;
      }

      if (context.mounted) {
        context.flushBarErrorMessage(
          message: 'Failed to activate subscription',
        );
      }
      return null;
    } catch (e) {
      debugPrint('Error activating subscription: $e');
      if (context.mounted) {
        context.flushBarErrorMessage(message: 'Subscription activation failed');
      }
      return null;
    }
  }

  Future<Map<String, dynamic>?> cancelSubscription(
    BuildContext context, {
    bool atPeriodEnd = true,
    VoidCallback? onLoadingChanged,
  }) async {
    try {
      onLoadingChanged?.call();

      final response = await _repository.cancelSubscription();
      final result = _extractData(response);
      if (result != null) return result;

      if (context.mounted) {
        context.flushBarErrorMessage(message: 'Failed to cancel subscription');
      }
      return null;
    } catch (e) {
      debugPrint('Error cancelling subscription: $e');
      if (context.mounted) {
        context.flushBarErrorMessage(message: 'Failed to cancel subscription');
      }
      return null;
    } finally {
      onLoadingChanged?.call();
    }
  }

  /// Changes the subscription plan; may require a Paystack checkout for upgrades.
  Future<Map<String, dynamic>?> changeSubscriptionPlan(
    BuildContext context,
    String newPriceId, {
    VoidCallback? onLoadingChanged,
  }) async {
    try {
      onLoadingChanged?.call();

      final response = await _repository.changeSubscriptionPlan(
        newPriceId: newPriceId,
      );
      if (!context.mounted) return null;

      final result = _extractData(response);
      if (result != null) {
        final authorizationUrl = result['authorizationUrl'] as String?;
        final reference = result['reference'] as String?;

        if (authorizationUrl != null && reference != null) {
          final completed = await _openCheckout(context, authorizationUrl);
          if (!context.mounted) return null;
          if (!completed) {
            context.flushBarErrorMessage(message: 'Payment was not completed');
            return null;
          }
          return activateSubscription(context, reference, priceId: newPriceId);
        }

        if (context.mounted) {
          context.flushBarSuccessMessage(message: 'Plan changed successfully!');
        }
        return (result['subscription'] as Map<String, dynamic>?) ?? result;
      }

      if (context.mounted) {
        context.flushBarErrorMessage(message: 'Failed to change plan');
      }
      return null;
    } catch (e) {
      debugPrint('Error changing plan: $e');
      if (context.mounted) {
        context.flushBarErrorMessage(message: 'Failed to change plan');
      }
      return null;
    } finally {
      onLoadingChanged?.call();
    }
  }

  bool _isSuccess(Map<String, dynamic> response) {
    return response['success'] == true || response['status'] == 200;
  }

  /// Pulls the first item out of a `response['data']` list, if present.
  Map<String, dynamic>? _extractData(Map<String, dynamic> response) {
    if (!_isSuccess(response)) return null;
    final data = response['data'];
    if (data is List && data.isNotEmpty) {
      return data[0] as Map<String, dynamic>?;
    }
    return null;
  }

  /// Tells the backend the user selected the Freemium plan.
  Future<Map<String, dynamic>?> selectFreemiumPlan() async {
    try {
      final response = await _repository.selectFreemiumPlan();
      debugPrint('✅ Freemium plan synced with backend: $response');

      // Cache the backend response — saveFromBackendResponse auto-detects
      // subscriptionType == "freemium" and sets the freemium flag.
      final data = _extractData(response);
      if (data != null) {
        await SubscriptionCacheService().saveFromBackendResponse(data);
      }
      return data;
    } catch (e) {
      debugPrint('⚠️ Could not sync freemium with backend (non-critical): $e');
      return null;
    }
  }
}

// Kept as top-level functions for backward compatibility with existing call sites.

bool isUserInTrial(Map<String, dynamic>? subscriptionData) {
  return subscriptionData?['isTrial'] == true;
}

bool isSubscriptionActive(Map<String, dynamic>? subscriptionData) {
  return subscriptionData?['isActive'] == true;
}

int? getTrialDaysRemaining(Map<String, dynamic>? subscriptionData) {
  return subscriptionData?['daysRemaining'] as int?;
}

String? getSubscriptionType(Map<String, dynamic>? subscriptionData) {
  return subscriptionData?['subscriptionType'] as String?;
}
