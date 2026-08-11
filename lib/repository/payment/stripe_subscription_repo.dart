// import 'package:flutter/foundation.dart';
// import 'package:kena_emotional_journey/app/network/base_api_services.dart';
// import 'package:kena_emotional_journey/app/network/network_api_services.dart';
// import 'package:kena_emotional_journey/app/utils/app_url.dart';
// import 'package:kena_emotional_journey/services/common/session_manager/session_controller.dart';
// 
// class StripeSubscriptionRepository {
//   final BaseApiServices _apiServices = NetworkApiService();
//   final SessionController _sessionController = SessionController();
// 
//   /// Get client configuration for Stripe SDK initialization
//   Future<Map<String, dynamic>> getClientConfig() async {
//     final response = await _apiServices.get(url: AppUrl.subscriptionConfig);
//     return response;
//   }
// 
//   /// Get available subscription plans
//   Future<Map<String, dynamic>> getAvailablePlans() async {
//     final response = await _apiServices.get(url: AppUrl.subscriptionPlans);
//     return response;
//   }
// 
//   /// Get current user's subscription status
//   Future<Map<String, dynamic>> getCurrentSubscription() async {
//     final response = await _apiServices.get(url: AppUrl.subscriptionMe);
//     return response;
//   }
// 
//   /// Create setup intent for trial flow
//   Future<Map<String, dynamic>> createSetupIntent() async {
//     final response = await _apiServices.post(
//       url: AppUrl.subscriptionSetupIntent,
//       data: {},
//     );
//     return response;
//   }
// 
//   /// Activate subscription after payment method setup
//   Future<Map<String, dynamic>> activateSubscription({
//     required String priceId,
//     required String setupIntentId,
//   }) async {
//     final data = {'priceId': priceId, 'setupIntentId': setupIntentId};
//     final response = await _apiServices.post(
//       url: AppUrl.subscriptionActivate,
//       data: data,
//     );
//     return response;
//   }
// 
//   /// Direct subscription (alternative flow)
//   Future<Map<String, dynamic>> createDirectSubscription({
//     required String priceId,
//   }) async {
//     // Debug: Check if token exists
//     final token = _sessionController.token;
//     debugPrint(
//       '🔑 [StripeRepo] Auth token before subscribe: ${token != null ? "PRESENT" : "NULL"}',
//     );
//     if (token == null) {
//       debugPrint(
//         '⚠️ [StripeRepo] WARNING: No auth token found! User may not be logged in.',
//       );
//     }
// 
//     final data = {'priceId': priceId};
//     final response = await _apiServices.post(
//       url: AppUrl.subscriptionSubscribe,
//       data: data,
//     );
//     return response;
//   }
// 
//   /// Cancel subscription
//   Future<Map<String, dynamic>> cancelSubscription({
//     bool atPeriodEnd = true,
//   }) async {
//     final data = {'atPeriodEnd': atPeriodEnd};
//     final response = await _apiServices.post(
//       url: AppUrl.subscriptionCancel,
//       data: data,
//     );
//     return response;
//   }
// 
//   /// Renew subscription
//   Future<Map<String, dynamic>> renewSubscription() async {
//     final response = await _apiServices.post(
//       url: AppUrl.subscriptionRenew,
//       data: {},
//     );
//     return response;
//   }
// 
//   /// Change subscription plan
//   Future<Map<String, dynamic>> changeSubscriptionPlan({
//     required String newPriceId,
//     String prorationBehavior = 'create_prorations',
//   }) async {
//     final data = {
//       'newPriceId': newPriceId,
//       'prorationBehavior': prorationBehavior,
//     };
//     final response = await _apiServices.post(
//       url: AppUrl.subscriptionChange,
//       data: data,
//     );
//     return response;
//   }
// 
//   /// Get recent subscription activities
//   Future<Map<String, dynamic>> getSubscriptionActivities({
//     int? limit,
//     String? userId,
//   }) async {
//     String queryString = '';
//     if (limit != null) {
//       queryString += 'limit=$limit';
//     }
//     if (userId != null) {
//       queryString += '${queryString.isNotEmpty ? '&' : ''}userId=$userId';
//     }
// 
//     String url = AppUrl.subscriptionActivities;
//     if (queryString.isNotEmpty) {
//       url += '?$queryString';
//     }
// 
//     final response = await _apiServices.get(url: url);
//     return response;
//   }
// }
