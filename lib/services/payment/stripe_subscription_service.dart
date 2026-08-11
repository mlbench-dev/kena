// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:kena_emotional_journey/app/data/exception/app_exceptions.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:flutter_stripe/flutter_stripe.dart';
// import 'package:kena_emotional_journey/app/utils/extensions/flush_bar_extension.dart';
// import 'package:kena_emotional_journey/repository/payment/stripe_subscription_repo.dart';
// import 'package:kena_emotional_journey/services/common/session_manager/session_controller.dart';
// import 'package:kena_emotional_journey/services/payment/subscription_cache_service.dart';
// 
// /// ============================================
// /// STRIPE SUBSCRIPTION SERVICE
// /// ============================================
// /// Simplified 3-Step Flow:
// /// Step 1: Get subscription data (config/plans/me)
// /// Step 2: Subscribe (create subscription + show payment sheet)
// /// Step 3: Activate (if trial mode)
// /// ============================================
// 
// class StripeSubscriptionService {
//   final StripeSubscriptionRepository _repository =
//       StripeSubscriptionRepository();
// 
//   // Fallback Stripe keys from provided data
//   String? get _fallbackPublishableKey => dotenv.env['STRIPE_PAYMENT_KEY'];
//   String? get _fallbackMonthlyPriceId => dotenv.env['MONTHLY_PRICE_ID'];
//   String? get _fallbackAnnualPriceId => dotenv.env['ANNUAL_PRICE_ID'];
// 
//   // ============================================
//   // STEP 1: INITIALIZATION & CONFIG
//   // ============================================
// 
//   /// Initialize Stripe SDK with publishable key
//   /// Call this first before any Stripe operations
//   Future<bool> initializeStripe() async {
//     try {
//       final response = await _repository.getClientConfig();
// 
//       if (_isSuccess(response) && response['data'] != null) {
//         final data = response['data'];
//         if (data is List && data.isNotEmpty) {
//           final configData = data[0] as Map<String, dynamic>?;
//           final publishableKey = configData?['publishableKey'] as String?;
// 
//           if (publishableKey != null && publishableKey.isNotEmpty) {
//             try {
//               Stripe.publishableKey = publishableKey;
//               await Stripe.instance.applySettings();
//               debugPrint('✅ Stripe SDK initialized from API');
//               return true;
//             } catch (stripeError) {
//               debugPrint('⚠️ API key failed, using fallback');
//               return await _initializeWithFallbackKey();
//             }
//           }
//         }
//       }
//       return await _initializeWithFallbackKey();
//     } catch (e) {
//       debugPrint('⚠️ Config failed: $e, using fallback');
//       return await _initializeWithFallbackKey();
//     }
//   }
// 
//   /// Initialize Stripe with fallback key
//   Future<bool> _initializeWithFallbackKey() async {
//     try {
//       final fallbackKey = _fallbackPublishableKey;
//       if (fallbackKey == null) {
//         debugPrint('❌ No fallback Stripe key available');
//         return false;
//       }
//       Stripe.publishableKey = fallbackKey;
//       await Stripe.instance.applySettings();
//       debugPrint('✅ Stripe SDK initialized with fallback key');
//       return true;
//     } catch (e) {
//       debugPrint('❌ Failed to initialize Stripe: $e');
//       return false;
//     }
//   }
// 
//   // ============================================
//   // STEP 1: GET SUBSCRIPTION PLANS
//   // ============================================
// 
//   /// Get available subscription plans
//   Future<List<Map<String, dynamic>>?> getSubscriptionPlans() async {
//     try {
//       final response = await _repository.getAvailablePlans();
// 
//       if (_isSuccess(response) && response['data'] != null) {
//         final data = response['data'];
//         if (data is List && data.isNotEmpty) {
//           final plansData = data[0] as Map<String, dynamic>?;
//           final plans = plansData?['plans'] as List<dynamic>?;
// 
//           if (plans != null) {
//             final plansList = plans
//                 .map((plan) => plan as Map<String, dynamic>)
//                 .toList();
//             debugPrint('✅ Retrieved ${plansList.length} plans from API');
//             return plansList;
//           }
//         }
//       }
//       return _getFallbackPlans();
//     } catch (e) {
//       debugPrint('⚠️ Plans failed: $e, using fallback');
//       return _getFallbackPlans();
//     }
//   }
// 
//   /// Get fallback subscription plans
//   List<Map<String, dynamic>> _getFallbackPlans() {
//     return [
//       {
//         'priceId': _fallbackMonthlyPriceId,
//         'name': 'Monthly Plan',
//         'unitAmountDecimal': '9.99',
//         'interval': 'month',
//       },
//       {
//         'priceId': _fallbackAnnualPriceId,
//         'name': 'Annual Plan',
//         'unitAmountDecimal': '99.99',
//         'interval': 'year',
//       },
//     ];
//   }
// 
//   // ============================================
//   // STEP 1: GET CURRENT SUBSCRIPTION STATUS
//   // ============================================
// 
//   /// Get current user's subscription status.
//   /// Saves the result to local cache so the app can work offline / fast.
//   Future<Map<String, dynamic>?> getCurrentSubscriptionStatus() async {
//     try {
//       final response = await _repository.getCurrentSubscription();
// 
//       if (_isSuccess(response) && response['data'] != null) {
//         final data = response['data'];
//         if (data is List && data.isNotEmpty) {
//           final status = data[0] as Map<String, dynamic>?;
//           if (status != null) {
//             // ✅ Persist to local cache every time we get a fresh response
//             await SubscriptionCacheService().saveFromBackendResponse(status);
//           }
//           return status;
//         }
//       }
//       return null;
//     } on UnauthorizedException {
//       // Let auth errors propagate so the caller can redirect to login
//       rethrow;
//     } on SocketException {
//       // Let connection errors propagate so the caller can show no-connection
//       rethrow;
//     } on NoInternetException {
//       // Let connection errors propagate
//       rethrow;
//     } catch (e) {
//       debugPrint('❌ Error getting subscription status: $e');
//       return null;
//     }
//   }
// 
//   // ============================================
//   // STEP 2: SUBSCRIBE (MAIN FLOW)
//   // ============================================
// 
//   /// Subscribe - Main entry point for subscription
//   /// Handles both trial and direct payment modes
//   Future<Map<String, dynamic>?> subscribe(
//     BuildContext context,
//     String priceId, {
//     VoidCallback? onLoadingChanged,
//   }) async {
//     try {
//       onLoadingChanged?.call();
// 
//       // Debug: Ensure session token is loaded (especially important on iOS)
//       final sessionController = SessionController();
//       final token = sessionController.token;
//       debugPrint(
//         '🔐 [StripeService] Session token: ${token != null ? "EXISTS" : "NULL - calling init()"}',
//       );
// 
//       if (token == null) {
//         // Try to reload from storage (iOS timing issue fix)
//         await sessionController.init();
//         debugPrint(
//           '🔐 [StripeService] After init(), token: ${sessionController.token != null ? "EXISTS" : "STILL NULL"}',
//         );
//       }
// 
//       // Call API to create subscription
//       final response = await _repository.createDirectSubscription(
//         priceId: priceId,
//       );
// 
//       // Log full response for debugging
//       debugPrint('📦 Subscription API Response: $response');
// 
//       if (_isSuccess(response) && response['data'] != null) {
//         final data = response['data'];
//         if (data is List && data.isNotEmpty) {
//           final subscriptionData = data[0] as Map<String, dynamic>?;
//           final mode = subscriptionData?['mode'] as String?;
// 
//           debugPrint('✅ Subscription created, Mode: $mode');
// 
//           // Handle trial setup mode
//           if (mode == 'trial_setup') {
//             return await _handleTrialMode(
//               context,
//               subscriptionData,
//               priceId,
//               onLoadingChanged: onLoadingChanged,
//             );
//           }
//           // Handle direct payment mode
//           else {
//             return await _handleDirectPayment(
//               context,
//               subscriptionData,
//               onLoadingChanged: onLoadingChanged,
//             );
//           }
//         }
//       }
// 
//       // Show server error message if available
//       final errorMessage =
//           response['message']?.toString() ?? 'Failed to create subscription';
//       debugPrint('❌ Subscription API Error: $errorMessage');
// 
//       if (context.mounted) {
//         context.flushBarErrorMessage(message: errorMessage);
//       }
//       onLoadingChanged?.call();
//       return null;
//     } catch (e) {
//       debugPrint('❌ Error in subscribe: $e');
//       if (context.mounted) {
//         context.flushBarErrorMessage(message: 'Subscription failed');
//       }
//       onLoadingChanged?.call();
//       return null;
//     }
//   }
// 
//   /// Handle trial setup mode
//   Future<Map<String, dynamic>?> _handleTrialMode(
//     BuildContext context,
//     Map<String, dynamic>? subscriptionData,
//     String priceId, {
//     VoidCallback? onLoadingChanged,
//   }) async {
//     final setupIntentClientSecret =
//         subscriptionData?['setupIntentClientSecret'] as String?;
// 
//     if (setupIntentClientSecret == null) {
//       debugPrint('❌ No setup intent client secret');
//       onLoadingChanged?.call();
//       return null;
//     }
// 
//     // Step 2a: Show payment sheet to collect payment method
//     final paymentCollected = await _showPaymentSheet(
//       context,
//       setupIntentClientSecret: setupIntentClientSecret,
//       onLoadingChanged: onLoadingChanged,
//     );
// 
//     if (!paymentCollected) {
//       return null;
//     }
// 
//     // Step 3: Activate trial
//     final setupIntentId = subscriptionData?['setupIntentId'] as String?;
//     if (setupIntentId != null) {
//       return await activateTrial(
//         context,
//         priceId,
//         setupIntentId,
//         onLoadingChanged: onLoadingChanged,
//       );
//     }
// 
//     onLoadingChanged?.call();
//     return null;
//   }
// 
//   /// Handle direct payment mode
//   Future<Map<String, dynamic>?> _handleDirectPayment(
//     BuildContext context,
//     Map<String, dynamic>? subscriptionData, {
//     VoidCallback? onLoadingChanged,
//   }) async {
//     final paymentIntentClientSecret =
//         subscriptionData?['paymentIntentClientSecret'] as String?;
// 
//     // If no payment intent, check if subscription is already updated
//     // This happens for downgrades/renewals where no immediate payment is needed
//     if (paymentIntentClientSecret == null) {
//       final subscription = subscriptionData?['subscription'];
//       final isActive = subscription is Map && subscription['isActive'] == true;
// 
//       if (isActive) {
//         debugPrint('✅ Plan updated (no payment required - downgrade/renewal)');
//         if (context.mounted) {
//           context.flushBarSuccessMessage(message: 'Plan updated successfully!');
//         }
//         onLoadingChanged?.call();
//         return subscription as Map<String, dynamic>?;
//       }
// 
//       debugPrint('❌ No payment intent and subscription not active');
//       if (context.mounted) {
//         context.flushBarErrorMessage(
//           message: 'Server did not return payment details. Please try again.',
//         );
//       }
//       onLoadingChanged?.call();
//       return null;
//     }
// 
//     // Show payment sheet for upgrades (when payment is needed)
//     final paymentSuccess = await _showPaymentSheet(
//       context,
//       paymentIntentClientSecret: paymentIntentClientSecret,
//       onLoadingChanged: onLoadingChanged,
//       subscriptionData: subscriptionData,
//     );
// 
//     if (paymentSuccess && context.mounted) {
//       context.flushBarSuccessMessage(message: 'Subscription successful!');
//       return subscriptionData?['subscription'] as Map<String, dynamic>?;
//     }
// 
//     return null;
//   }
// 
//   // ============================================
//   // STEP 2: SHOW PAYMENT SHEET
//   // ============================================
// 
//   /// Show Stripe payment sheet
//   Future<bool> _showPaymentSheet(
//     BuildContext context, {
//     String? setupIntentClientSecret,
//     String? paymentIntentClientSecret,
//     VoidCallback? onLoadingChanged,
//     Map<String, dynamic>? subscriptionData,
//   }) async {
//     try {
//       await Stripe.instance.initPaymentSheet(
//         paymentSheetParameters: SetupPaymentSheetParameters(
//           setupIntentClientSecret: setupIntentClientSecret,
//           paymentIntentClientSecret: paymentIntentClientSecret,
//           merchantDisplayName: 'Kena',
//           style: ThemeMode.light,
//           googlePay: Platform.isAndroid
//               ? const PaymentSheetGooglePay(
//                   merchantCountryCode: 'US',
//                   testEnv: true,
//                 )
//               : null,
//         ),
//       );
// 
//       await Stripe.instance.presentPaymentSheet();
//       debugPrint('✅ Payment sheet completed');
//       return true;
//     } catch (e) {
//       debugPrint('❌ Payment sheet error: $e');
// 
//       // Check if payment intent is already succeeded (server processed it)
//       if (e.toString().contains('succeeded')) {
//         final subscription = subscriptionData?['subscription'];
//         final isActive =
//             subscription is Map && subscription['isActive'] == true;
// 
//         if (isActive) {
//           debugPrint(
//             '✅ Payment already succeeded on server - treating as success',
//           );
//           if (context.mounted) {
//             context.flushBarSuccessMessage(
//               message: 'Plan updated successfully!',
//             );
//           }
//           return true;
//         }
// 
//         debugPrint(
//           '❌ Payment intent already succeeded but subscription not active',
//         );
//         if (context.mounted) {
//           context.flushBarErrorMessage(
//             message: 'Payment already processed by server. Please try again.',
//           );
//         }
//       } else if (context.mounted) {
//         context.flushBarErrorMessage(message: 'Payment failed');
//       }
//       return false;
//     }
//   }
// 
//   // ============================================
//   // STEP 3: ACTIVATE TRIAL (Only if trial mode)
//   // ============================================
// 
//   /// Activate trial subscription after payment method collection
//   Future<Map<String, dynamic>?> activateTrial(
//     BuildContext context,
//     String priceId,
//     String setupIntentId, {
//     VoidCallback? onLoadingChanged,
//   }) async {
//     try {
//       onLoadingChanged?.call();
// 
//       final response = await _repository.activateSubscription(
//         priceId: priceId,
//         setupIntentId: setupIntentId,
//       );
// 
//       if (_isSuccess(response) && response['data'] != null) {
//         final data = response['data'];
//         if (data is List && data.isNotEmpty) {
//           final subscriptionData = data[0] as Map<String, dynamic>?;
// 
//           debugPrint('✅ Trial activated');
//           debugPrint('Trial days: ${subscriptionData?['trialDaysRemaining']}');
// 
//           if (context.mounted) {
//             context.flushBarSuccessMessage(message: 'Trial activated!');
//           }
// 
//           onLoadingChanged?.call();
//           return subscriptionData;
//         }
//       }
// 
//       if (context.mounted) {
//         context.flushBarErrorMessage(message: 'Failed to activate trial');
//       }
//       onLoadingChanged?.call();
//       return null;
//     } catch (e) {
//       debugPrint('❌ Error activating trial: $e');
//       if (context.mounted) {
//         context.flushBarErrorMessage(message: 'Trial activation failed');
//       }
//       onLoadingChanged?.call();
//       return null;
//     }
//   }
// 
//   // ============================================
//   // HELPER METHODS
//   // ============================================
// 
//   /// Check if API response is successful
//   bool _isSuccess(Map<String, dynamic> response) {
//     return response['success'] == true || response['status'] == 200;
//   }
// 
//   // ============================================
//   // CANCEL SUBSCRIPTION
//   // ============================================
// 
//   /// Cancel subscription
//   Future<Map<String, dynamic>?> cancelSubscription(
//     BuildContext context, {
//     bool atPeriodEnd = true,
//     VoidCallback? onLoadingChanged,
//   }) async {
//     try {
//       onLoadingChanged?.call();
// 
//       final response = await _repository.cancelSubscription(
//         atPeriodEnd: atPeriodEnd,
//       );
// 
//       if (_isSuccess(response) && response['data'] != null) {
//         final data = response['data'];
//         if (data is List && data.isNotEmpty) {
//           final result = data[0] as Map<String, dynamic>?;
//           debugPrint('✅ Subscription cancelled: $result');
//           onLoadingChanged?.call();
//           return result;
//         }
//       }
// 
//       if (context.mounted) {
//         context.flushBarErrorMessage(message: 'Failed to cancel subscription');
//       }
//       onLoadingChanged?.call();
//       return null;
//     } catch (e) {
//       debugPrint('❌ Error cancelling subscription: $e');
//       if (context.mounted) {
//         context.flushBarErrorMessage(message: 'Failed to cancel subscription');
//       }
//       onLoadingChanged?.call();
//       return null;
//     }
//   }
// 
//   // ============================================
//   // CHANGE SUBSCRIPTION PLAN
//   // ============================================
// 
//   /// Change subscription plan
//   Future<Map<String, dynamic>?> changeSubscriptionPlan(
//     BuildContext context,
//     String newPriceId, {
//     VoidCallback? onLoadingChanged,
//   }) async {
//     try {
//       onLoadingChanged?.call();
// 
//       final response = await _repository.changeSubscriptionPlan(
//         newPriceId: newPriceId,
//       );
// 
//       if (_isSuccess(response) && response['data'] != null) {
//         final data = response['data'];
//         if (data is List && data.isNotEmpty) {
//           final result = data[0] as Map<String, dynamic>?;
//           debugPrint('✅ Subscription plan changed: $result');
//           if (context.mounted) {
//             context.flushBarSuccessMessage(
//               message: 'Plan changed successfully!',
//             );
//           }
//           onLoadingChanged?.call();
//           return result;
//         }
//       }
// 
//       if (context.mounted) {
//         context.flushBarErrorMessage(message: 'Failed to change plan');
//       }
//       onLoadingChanged?.call();
//       return null;
//     } catch (e) {
//       debugPrint('❌ Error changing plan: $e');
//       if (context.mounted) {
//         context.flushBarErrorMessage(message: 'Failed to change plan');
//       }
//       onLoadingChanged?.call();
//       return null;
//     }
//   }
// }
// 
// // ============================================
// // HELPER FUNCTIONS (Outside class - for backward compatibility)
// // ============================================
// 
// /// Check if user is in trial
// bool isUserInTrial(Map<String, dynamic>? subscriptionData) {
//   return subscriptionData?['isTrial'] == true;
// }
// 
// /// Check if subscription is active
// bool isSubscriptionActive(Map<String, dynamic>? subscriptionData) {
//   return subscriptionData?['isActive'] == true;
// }
// 
// /// Get trial days remaining
// int? getTrialDaysRemaining(Map<String, dynamic>? subscriptionData) {
//   return subscriptionData?['trialDaysRemaining'] as int?;
// }
// 
// /// Get subscription type
// String? getSubscriptionType(Map<String, dynamic>? subscriptionData) {
//   return subscriptionData?['subscriptionType'] as String?;
// }
