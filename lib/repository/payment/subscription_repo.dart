// import 'package:kena_emotional_journey/app/network/base_api_services.dart';
// import 'package:kena_emotional_journey/app/network/network_api_services.dart';
// import 'package:kena_emotional_journey/app/utils/app_url.dart';
// import 'package:kena_emotional_journey/services/common/session_manager/session_controller.dart';

// class SubscriptionRepository {
//   final BaseApiServices _apiServices = NetworkApiService();
//   final _sessionController = SessionController();

//   Future<Map<String, dynamic>> createPaymentIntent(String priceId) async {
//     final userId = _sessionController.user!.id;
//     return _apiServices.post(
//       url: AppUrl.createPaymentIntent,
//       data: {'userId': userId, 'priceId': priceId},
//     );
//   }

//   Future<Map<String, dynamic>> createStripeSubscription(
//     String priceId,
//     String customerId,
//     String setupIntentId,
//   ) async {
//     final userId = _sessionController.user!.id;
//     return _apiServices.post(
//       url: AppUrl.createSubscription,
//       data: {
//         'userId': userId,
//         'priceId': priceId,
//         'customerId': customerId,
//         'setupIntentId': setupIntentId,
//         'platform': 'android',
//       },
//     );
//   }

//   //Fetch subscription details
//   Future<Map<String, dynamic>> fetchSubscriptionDetails() async {
//     final userId = _sessionController.user!.id;
//     return _apiServices.get(
//       url: '${AppUrl.getSubscriptionDetails}?userId=$userId',
//     );
//   }

//   //Cancel Subscription
//   Future<Map<String, dynamic>> cancelSubscription() async {
//     final userId = _sessionController.user!.id;
//     return _apiServices.post(
//       url: AppUrl.cancelSubcription,
//       data: {'userId': userId},
//     );
//   }
// }
