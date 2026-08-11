import 'dart:io';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:kena_emotional_journey/app/utils/extensions/flush_bar_extension.dart';
import 'package:kena_emotional_journey/repository/payment/iap_repo.dart';
import 'package:kena_emotional_journey/services/common/auth_service.dart';
import 'package:kena_emotional_journey/services/payment/iap_services.dart';
import 'package:kena_emotional_journey/services/payment/paystack_subscription_service.dart';

class SubscriptionScreenService {
  final _iapServices = InAppPurchaseServices();
  final _paystackService = PaystackSubscriptionService();

  Future<void> handleSubscribeButton(
    BuildContext context,
    int selectedIndex, {
    bool isSignupFlow = true,
    VoidCallback? updateLoading,
    String? priceId, // Paystack plan code
  }) async {
    // iOS must always go through Apple's In-App Purchase sheet
    // (App Store guidelines forbid third-party payment for digital
    // subscriptions), regardless of whether a Paystack priceId was passed.
    if (Platform.isIOS) {
      await _handleIAPSubscription(context, selectedIndex, updateLoading);
    } else if (Platform.isAndroid || priceId != null) {
      await _handlePaystackSubscription(
        context,
        selectedIndex,
        priceId,
        updateLoading,
      );
    }
  }

  Future<void> _handlePaystackSubscription(
    BuildContext context,
    int selectedIndex,
    String? priceId,
    VoidCallback? updateLoading,
  ) async {
    debugPrint('HANDLING PAYSTACK SUBSCRIPTION');
    debugPrint('SELECTED INDEX: $selectedIndex');
    debugPrint('PRICE ID: $priceId');

    if (priceId == null) {
      debugPrint('ERROR: Price ID is required for Paystack subscription');
      if (context.mounted) {
        context.flushBarErrorMessage(message: 'Price ID is required');
      }
      return;
    }

    // Load Paystack config (public key, trial days, callback URL)
    await _paystackService.initializePaystack();
    if (!context.mounted) return;

    // Use subscribe method (handles both trial and checkout)
    final subscriptionResult = await _paystackService.subscribe(
      context,
      priceId,
      onLoadingChanged: updateLoading,
    );

    if (subscriptionResult != null) {
      debugPrint('✅ PAYSTACK SUBSCRIPTION SUCCESSFUL');
      debugPrint('Subscription Data: $subscriptionResult');

      // Navigate to success screen or update UI
      if (context.mounted) {
        context.flushBarSuccessMessage(
          message: 'Subscription created successfully!',
        );
        // Delay navigation to allow flushbar to show
        await Future.delayed(const Duration(seconds: 2));
        if (context.mounted) {
          AuthService.goToUserHome(context);
        }
      }
    } else {
      debugPrint('❌ PAYSTACK SUBSCRIPTION FAILED');
    }
  }

  Future<void> _handleIAPSubscription(
    BuildContext context,
    int selectedIndex,
    VoidCallback? updateLoading,
  ) async {
    debugPrint('IN HANDLE IAP SUBSCRIPTION,');
    debugPrint('SUBSCRIPTIONS LIST IS: $iapSubscriptions');
    debugPrint('SELECTED INDEX: $selectedIndex');

    if (iapSubscriptions.isEmpty) {
      debugPrint('No Subscription loaded from Apple');
      debugPrint(
        '''\n\nHey, In App Purchase only works on real ios device in "Release mode!"\n\n''',
      );

      if (context.mounted) {
        context.flushBarErrorMessage(
          message: 'Subscription products not available',
        );
      }
      return;
    }

    if (context.mounted) {
      context.flushBarSuccessMessage(
        message: 'Initializing payment process...',
      );
    }

    // Map indices to product IDs for more reliable selection
    final Map<int, String> productKeywords = {
      0: 'monthly',
      1: 'yearly',
      2: 'weekly',
    };

    final String keyword = productKeywords[selectedIndex] ?? 'monthly';
    debugPrint('LOOKING FOR PRODUCT WITH KEYWORD: $keyword');

    try {
      ProductDetails? selectedProduct;

      // Try to find product by ID first (more reliable)
      for (final product in iapSubscriptions) {
        if (product.id.toLowerCase().contains(keyword)) {
          selectedProduct = product;
          debugPrint('FOUND PRODUCT BY ID: ${product.id}');
          break;
        }
      }

      // Fallback to title search if ID search fails
      if (selectedProduct == null) {
        for (final product in iapSubscriptions) {
          if (product.title.toLowerCase().contains(keyword)) {
            selectedProduct = product;
            debugPrint('FOUND PRODUCT BY TITLE: ${product.title}');
            break;
          }
        }
      }

      // If still not found, use first available product as fallback
      if (selectedProduct == null && iapSubscriptions.isNotEmpty) {
        selectedProduct = iapSubscriptions.first;
        debugPrint(
          'USING FIRST AVAILABLE PRODUCT AS FALLBACK: ${selectedProduct.id}',
        );
      }

      if (selectedProduct == null) {
        throw Exception('No subscription products available');
      }

      debugPrint(
        'SELECTED PRODUCT: ${selectedProduct.id} - ${selectedProduct.title} - ${selectedProduct.price}',
      );
      await _iapServices.buySubscription(selectedProduct, context);
    } catch (e) {
      debugPrint('ERROR IN IAP SUBSCRIPTION: $e');
      if (context.mounted) {
        context.flushBarErrorMessage(
          message: 'Error processing subscription: $e',
        );
      }
    }
  }

  Future<void> createSubscription(
    BuildContext context, {
    required bool isAndroid,
    required String receiptData,
    required String productId,
    required String transactionId,
    required String purchaseStatus,
    bool isSignupFlow = true,
  }) async {
    try {
      await InAppPurchaseRepository().createAppleSubscription(
        receiptData,
        productId,
        transactionId,
        purchaseStatus,
      );
      if (context.mounted) {
        context.flushBarSuccessMessage(
          message: 'Subscription created successfully.',
        );
        // Delay navigation to allow flushbar to show
        await Future.delayed(const Duration(seconds: 2));
        if (context.mounted) {
          AuthService.goToUserHome(context);
        }
      }
    } catch (e) {
      if (context.mounted) {
        context.flushBarErrorMessage(
          message: 'Failed to verify subscription on backend. $e',
        );
      }
    }
  }
}
