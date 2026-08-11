import 'package:flutter/material.dart';
import 'package:kena_emotional_journey/app/network/base_api_services.dart';
import 'package:kena_emotional_journey/app/network/network_api_services.dart';
import 'package:kena_emotional_journey/app/utils/app_url.dart';
import 'package:kena_emotional_journey/services/common/session_manager/session_controller.dart';

enum IAPEnvironments {
  sandbox('Sandbox'),
  testflight('TestFlight'),
  production('Production');

  const IAPEnvironments(this.id);
  final String id;
}

class InAppPurchaseRepository {
  final BaseApiServices _apiServices = NetworkApiService();

  final _sessionController = SessionController();

  Future<Map<String, dynamic>> createAppleSubscription(
    String receiptData,
    String productId,
    String transactionId,
    String purchaseStatus,
  ) async {
    final userId = _sessionController.user!.id;
    final Map<String, dynamic> data = {
      'userId': userId,
      'receiptData': receiptData,
      'productId': productId,
      'transactionId': transactionId,
      'originalTransactionId': null,
      'purchaseStatus': purchaseStatus,
      /*initially it's null, but once the
        subscription is created, it will be returned from Apple */
      'environment': IAPEnvironments.production.id,
      'platform': 'ios',
    };
    debugPrint('SENDING FOLLOWING TRANSACTION DATA TO BACKEND IS: $data');
    return _apiServices.post(url: AppUrl.appleVerify, data: data);
  }
}
