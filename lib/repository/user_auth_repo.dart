import 'package:flutter/cupertino.dart';
import 'package:kena_emotional_journey/app/network/base_api_services.dart';
import 'package:kena_emotional_journey/app/network/network_api_services.dart';
import 'package:kena_emotional_journey/app/utils/app_url.dart';
// import 'package:kena/services/common/session_manager/session_controller.dart';

class UserAuthRepository {
  final BaseApiServices _apiServices = NetworkApiService();
  // final SessionController _sessionController = SessionController();

  Future<Map<String, dynamic>> userSignup(Map<String, dynamic> data) async {
    return _apiServices.post(url: AppUrl.userSignup, data: data);
  }

  Future<Map<String, dynamic>> userOAuth(Map<String, dynamic> data) async {
    return _apiServices.post(url: AppUrl.userOAuth, data: data);
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    return _apiServices.put(url: AppUrl.profileUpdate, data: data);
  }

  Future<Map<String, dynamic>> userLogin(Map<String, dynamic> data) async {
    return _apiServices.post(url: AppUrl.userLogin, data: data);
  }

  //fetch profile
  Future<Map<String, dynamic>> getCurrentUserProfile() async {
    return _apiServices.get(url: AppUrl.getProfile);
  }

  Future<Map<String, dynamic>> verifySignupOtp(
    Map<String, dynamic> data,
  ) async {
    debugPrint('verifyOtp called with data: $data'); //#muttas
    return _apiServices.post(url: AppUrl.verifyUserOtp, data: data);
  }

  Future<Map<String, dynamic>> forgotPassword(Map<String, dynamic> data) async {
    return _apiServices.post(url: AppUrl.forgotPassword, data: data);
  }

  Future<Map<String, dynamic>> verifyPasswordOtp(
    Map<String, dynamic> data,
  ) async {
    return _apiServices.post(url: AppUrl.verifyOtp, data: data);
  }

  Future<Map<String, dynamic>> resetPassword(Map<String, dynamic> data) async {
    return _apiServices.post(url: AppUrl.resetPassword, data: data);
  }

  Future<Map<String, dynamic>> changePassword(Map<String, dynamic> data) async {
    return _apiServices.post(url: AppUrl.changePassword, data: data);
  }

  // Delete User Account
  Future<Map<String, dynamic>> deleteUserAccount() async {
    return _apiServices.delete(url: AppUrl.deleteUserAccount);
  }

  //add to favorites
  Future<Map<String, dynamic>> removeFromFavorites({
    required String vendorId,
  }) async {
    final data = {'vendorId': vendorId};
    return _apiServices.post(url: AppUrl.removeFromFavorites, data: data);
  }

  //Add User Review
  Future<Map<String, dynamic>> addUserReview(Map<String, dynamic> data) async {
    return _apiServices.post(url: AppUrl.addUserReview, data: data);
  }

  //Resend OTP
  Future<Map<String, dynamic>> resendSignupOtp(
    Map<String, dynamic> data,
  ) async {
    return _apiServices.post(url: AppUrl.resendOtp, data: data);
  }

  //Search Vendors
  // Future<Map<String, dynamic>> searchVendors({required String query}) async {
  //   // Trim and ensure query is string
  //   final safeQuery = (query.trim().isEmpty) ? '' : query.trim();

  //   // If empty, skip backend call and return empty results
  //   if (safeQuery.isEmpty) {
  //     return {'success': true, 'vendors': []};
  //   }

  //   final uri = Uri.parse(
  //     AppUrl.searchVendors,
  //   ).replace(queryParameters: {'query': safeQuery});

  //   debugPrint('Search Vendor API URL: ${uri.toString()}'); // debug

  //   final response = await _apiServices.get(url: uri.toString());

  //   // Ensure success key exists
  //   if (response['success'] is! bool) {
  //     return {'success': false, 'vendors': []};
  //   }

  //   return response;
  // }

  //Search Vendors
  Future<Map<String, dynamic>> searchVendors({
    required String queryString,
  }) async {
    return _apiServices.get(url: '${AppUrl.searchVendors}?$queryString');
  }

  /// Get user reviews by user ID
  /// Get user reviews
  Future<Map<String, dynamic>> getUserReviews() async {
    return _apiServices.get(url: AppUrl.getUserReviews);
  }
}
