import 'dart:async';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:kena_emotional_journey/app/utils/extensions/flush_bar_extension.dart';
import 'package:kena_emotional_journey/services/payment/subscription_services.dart';

List<ProductDetails> iapSubscriptions = [];

class InAppPurchaseServices {
  ///
  ///IN-APP-PURCHASE (SUBSCRIPTION) SERVICES
  ///

  //Define Subscription Product IDs
  static const Set<String> _subscriptionIds = {
    'kena_yearly_subscription',
    'kena_monthly_subscription',
    // 'kena_weekly_subscription',
  };

  //Fetch Subscription Products

  // int selectedSubscription = 0;

  //Load subscriptions
  Future<void> loadSubscriptions(
    // ignore: avoid_positional_boolean_parameters
    void Function(bool loadingStatus)? updateLoading,
    void Function(List<ProductDetails> subs)? updateSubscriptionsList,
  ) async {
    debugPrint('LOADING SUBSCRIPTIONS....');
    debugPrint('PRODUCT IDs TO QUERY: $_subscriptionIds');
    updateLoading?.call(false);
    try {
      final bool available = await InAppPurchase.instance.isAvailable();
      debugPrint('IN-APP PURCHASE AVAILABLE: $available');
      if (!available) {
        debugPrint('In App Purchase not available on this device');
        updateLoading?.call(true);
        return;
      }

      debugPrint('QUERYING PRODUCT DETAILS FROM APPLE...');
      final ProductDetailsResponse response = await InAppPurchase.instance
          .queryProductDetails(_subscriptionIds);

      debugPrint('QUERY RESPONSE:');
      debugPrint('- Product Details Found: ${response.productDetails.length}');
      debugPrint('- Not Found IDs: ${response.notFoundIDs}');
      debugPrint('- Error: ${response.error}');

      if (response.notFoundIDs.isNotEmpty) {
        debugPrint('PRODUCTS NOT FOUND: ${response.notFoundIDs}');
        debugPrint('TROUBLESHOOTING:');
        debugPrint('1. Check if products exist in App Store Connect');
        debugPrint('2. Verify bundle ID matches App Store Connect');
        debugPrint('3. Ensure products are "Ready to Submit" or approved');
        debugPrint('4. Add sandbox test users for testing');
      }

      if (response.error != null) {
        debugPrint('STOREKIT ERROR DETECTED:');
        debugPrint('Error Code: ${response.error!.code}');
        debugPrint('Error Message: ${response.error!.message}');
        debugPrint('Error Source: ${response.error!.source}');

        if (response.error!.code == 'storekit_no_response') {
          debugPrint('STOREKIT NO RESPONSE - CRITICAL:');
          debugPrint('This means StoreKit cannot reach Apple servers.');
          debugPrint('IMMEDIATE ACTIONS NEEDED:');
          debugPrint('1. Ensure app has proper App Store Connect setup');
          debugPrint(
            '2. Verify bundle ID: com.kena.mlb exists in App Store Connect',
          );
          debugPrint('3. Create subscription products in App Store Connect');
          debugPrint('4. Test on physical iOS device (NOT simulator)');
          debugPrint('5. Use sandbox test account for testing');
        }
      }

      iapSubscriptions = response.productDetails;
      debugPrint('FOUND SUBSCRIPTIONS ARE: $iapSubscriptions....');

      // Log details of found products
      for (final product in iapSubscriptions) {
        debugPrint(
          'PRODUCT: ${product.id} - ${product.title} - ${product.price}',
        );
      }

      updateSubscriptionsList?.call(iapSubscriptions);
    } catch (e, stackTrace) {
      debugPrint('Failed to load subscriptions Error: $e');
      debugPrint('Stack trace: $stackTrace');
    }
    updateLoading?.call(true); //update UI (for localized pricing)
  }
  //END: Load subscriptions

  //Buy Subscription
  Future<void> buySubscription(
    ProductDetails product,
    BuildContext context,
  ) async {
    final purchaseParam = PurchaseParam(productDetails: product);
    await InAppPurchase.instance.buyNonConsumable(purchaseParam: purchaseParam);
  }
  //END: Buy Subscription

  //Open Stream
  //This will continuesly listen to events (when opened and when and
  // event happens)
  StreamSubscription<List<PurchaseDetails>>? purchaseSubscription;

  void startListeningToPurchaseUpdates(
    BuildContext context, {
    bool isSignupFlow = true,
  }) {
    // cancel old subscription if already listening
    //this is also called on subscription.dart dispose
    purchaseSubscription?.cancel();

    // purchaseSubscription = InAppPurchase.instance.purchaseStream.listen(
    //   handlePurchaseUpdates(context, purchaseSubscription,
    //       isSignupFlow: isSignupFlow),
    //   onError: (err) => debugPrint('purchaseStream error: $err'),
    // );

    purchaseSubscription = InAppPurchase.instance.purchaseStream.listen(
      (purchaseDetailsList) {
        handlePurchaseUpdates(
          // ignore: use_build_context_synchronously
          context,
          purchaseDetailsList,
          isSignupFlow: isSignupFlow,
        );
      },
      onError: (dynamic err) {
        debugPrint('purchaseStream error: $err');
        if (context.mounted) {
          context.flushBarErrorMessage(message: 'Purchase Stream Error...');
        }
      },
    );
  }
  //END: Open Stream

  //Hanlde Purchase
  Future<void> handlePurchaseUpdates(
    BuildContext context,
    List<PurchaseDetails> purchaseDetailsList, {
    bool isSignupFlow = true,
  }) async {
    for (final purchase in purchaseDetailsList) {
      await _processPurchase(context, purchase, isSignupFlow: isSignupFlow);
    }
  }
  //END: Hanlde Purchase

  //Process Purchase
  Future<void> _processPurchase(
    BuildContext context,
    PurchaseDetails purchase, {
    bool isSignupFlow = true,
  }) async {
    //Status is purchased when a new subscription is
    //created or subscription is updated. Otherwise
    //status will be 'restored'.
    //Sandbox is "Notoriously Buggy for Subscriptions" : ChatGpt
    //That's why it returns false status in sandbox
    //
    //
    //Purchased
    if (purchase.status == PurchaseStatus.purchased
    // || purchase.status == PurchaseStatus.restored
    ) {
      try {
        await _verifyAndUnlock(context, purchase, isSignupFlow: isSignupFlow);

        if (purchase.pendingCompletePurchase) {
          await InAppPurchase.instance.completePurchase(purchase);
        }
      } catch (e, st) {
        debugPrint('❌ Error verifying purchase: $e\n$st');
        if (context.mounted) {
          context.flushBarErrorMessage(message: 'Error verifying purchase...');
        }
      }
      //restored
    } else if (purchase.status == PurchaseStatus.restored) {
      await InAppPurchase.instance.completePurchase(purchase);
      debugPrint(' Purchase Restored');
    }
    //Error
    else if (purchase.status == PurchaseStatus.error) {
      debugPrint('❌ Purchase Error: ${purchase.error}');
      await InAppPurchase.instance.completePurchase(purchase);
      //Pending
    } else if (purchase.status == PurchaseStatus.pending) {
      debugPrint(' Purchase Pending...');
      //Canceled
    } else if (purchase.status == PurchaseStatus.canceled) {
      debugPrint(' Purchase Canceled by user...');
      await InAppPurchase.instance.completePurchase(purchase);
    }
  }
  //END: Process Purchase

  //Verify and Unlock
  Future<void> _verifyAndUnlock(
    BuildContext context,
    PurchaseDetails purchase, {
    bool isSignupFlow = true,
  }) async {
    ///
    // String? jwsToken;
    // if (Platform.isIOS) {
    //   try {
    //     final tokens = await StoreKitHelper.getJWSTokens();
    //     if (tokens.isNotEmpty) {
    //       jwsToken = tokens.first; // pick the latest transaction
    //       debugPrint('✅ Got JWS Token: $jwsToken');
    //     }
    //   } catch (e) {
    //     debugPrint('❌ Failed to get JWS token: $e');
    //   }
    // }

    ///

    debugPrint('-----------------------------------------------');
    debugPrint('VERIFY AND UNLOCK CALLED');
    debugPrint('PURCHASE STATUS ${purchase.status}');
    debugPrint(
      'RECEIPT DATA: ${purchase.verificationData.serverVerificationData}',
    );
    debugPrint('PRODUCT ID: ${purchase.productID}');
    debugPrint('TRANSACTION ID: ${purchase.purchaseID}');
    // debugPrint('JWS Token: $jwsToken');
    debugPrint('-----------------------------------------------');
    // Best practice: verify with your server and Apple’s receipt system
    // create here
    // if (purchase.status == PurchaseStatus.purchased) {
    //only call when subscription is created/updated
    if (context.mounted) {
      await SubscriptionScreenService().createSubscription(
        context,
        isAndroid: false,
        receiptData: purchase.verificationData.serverVerificationData, //old
        // receiptData: jwsToken ?? purchase.verificationData.serverVerificationData,
        productId: purchase.productID,
        transactionId: purchase.purchaseID ?? '',
        purchaseStatus: purchase.status.toString(),
        isSignupFlow: isSignupFlow,
      );
    }
    // }
  }
  //END: Verify and Unlock

  //Close Subscription Stream
  //This will any stream which was already opened
  void closeSubscriptionStream() {
    purchaseSubscription?.cancel();
  }

  //END: IN-APP-PURCHASE (SUBSCRIPTION) SERVICES
}
