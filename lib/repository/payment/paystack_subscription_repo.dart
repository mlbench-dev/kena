import 'package:kena_emotional_journey/app/network/base_api_services.dart';
import 'package:kena_emotional_journey/app/network/network_api_services.dart';
import 'package:kena_emotional_journey/app/utils/app_url.dart';

class PaystackSubscriptionRepository {
  final BaseApiServices _apiServices = NetworkApiService();

  /// Get client configuration for Paystack SDK initialization
  Future<Map<String, dynamic>> getClientConfig() async {
    final response = await _apiServices.get(url: AppUrl.subscriptionConfig);
    return response;
  }

  /// Get available subscription plans
  Future<Map<String, dynamic>> getAvailablePlans() async {
    final response = await _apiServices.get(url: AppUrl.subscriptionPlans);
    return response;
  }

  /// Get current user's subscription status
  Future<Map<String, dynamic>> getCurrentSubscription() async {
    final response = await _apiServices.get(url: AppUrl.subscriptionMe);
    return response;
  }

  /// Initialize trial (no checkout required)
  Future<Map<String, dynamic>> createSetupIntent() async {
    final response = await _apiServices.post(
      url: AppUrl.subscriptionSetupIntent,
      data: {},
    );
    return response;
  }

  /// Create subscription (trial setup or Paystack checkout, depending on server response)
  Future<Map<String, dynamic>> createDirectSubscription({
    required String priceId,
    bool forceCheckout = false,
  }) async {
    final data = {'priceId': priceId, 'forceCheckout': forceCheckout};
    final response = await _apiServices.post(
      url: AppUrl.subscriptionSubscribe,
      data: data,
    );
    return response;
  }

  /// Activate subscription after a successful Paystack checkout
  Future<Map<String, dynamic>> activateSubscription({
    required String reference,
    String? priceId,
  }) async {
    final data = {
      'reference': reference,
      if (priceId != null) 'priceId': priceId,
    };
    final response = await _apiServices.post(
      url: AppUrl.subscriptionActivate,
      data: data,
    );
    return response;
  }

  /// Cancel subscription (stops auto-renewal at period end)
  Future<Map<String, dynamic>> cancelSubscription() async {
    final response = await _apiServices.post(
      url: AppUrl.subscriptionCancel,
      data: {},
    );
    return response;
  }

  /// Renew a previously canceled subscription
  Future<Map<String, dynamic>> renewSubscription() async {
    final response = await _apiServices.post(
      url: AppUrl.subscriptionRenew,
      data: {},
    );
    return response;
  }

  /// Change subscription plan (upgrade/downgrade)
  Future<Map<String, dynamic>> changeSubscriptionPlan({
    required String newPriceId,
  }) async {
    final data = {'newPriceId': newPriceId};
    final response = await _apiServices.post(
      url: AppUrl.subscriptionChange,
      data: data,
    );
    return response;
  }

  /// Get recent subscription activities
  Future<Map<String, dynamic>> getSubscriptionActivities({int? limit}) async {
    String url = AppUrl.subscriptionActivities;
    if (limit != null) {
      url += '?limit=$limit';
    }
    final response = await _apiServices.get(url: url);
    return response;
  }

  /// Notify the backend that the user selected the Freemium plan.
  /// The backend records this as an active freemium subscription
  /// so it appears in the user's subscription history.
  Future<Map<String, dynamic>> selectFreemiumPlan() async {
    final response = await _apiServices.post(
      url: AppUrl.subscriptionFreemium,
      data: {'plan': 'freemium'},
    );
    return response;
  }
}
