import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:kena_emotional_journey/app/routes/notification_route_resolver.dart';
import 'package:kena_emotional_journey/app/utils/service_error_handler.dart';
import 'package:kena_emotional_journey/app/view/app.dart';
import 'package:kena_emotional_journey/repository/user/user_notifications_repo.dart';
import 'package:kena_emotional_journey/services/common/session_manager/session_controller.dart';

class PushNotificationsService {
  final String tag = 'NotificationsService';
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;

  final SessionController _session = SessionController();
  final UserNotificationsRepository _userRepo = UserNotificationsRepository();

  static bool _isInitializing = false;
  static StreamSubscription<RemoteMessage>? _onMessageSub;
  static StreamSubscription<RemoteMessage>? _onMessageOpenedAppSub;

  /// Emits when a foreground FCM message arrives.
  /// Listen to this to trigger API refresh of unread count.
  static final StreamController<void> _foregroundMessageController =
      StreamController<void>.broadcast();
  static Stream<void> get onForegroundMessage =>
      _foregroundMessageController.stream;

  Future<void> initialize(
    BuildContext context, {
    required String userId,
    double? userLat,
    double? userLng,
  }) async {
    if (_isInitializing) {
      debugPrint(
        'ℹ️ FCM initialization already in progress. Skipping duplicate call.',
      );
      return;
    }

    _isInitializing = true;

    try {
      if (await isIOSSimulator()) {
        debugPrint('⚠️ iOS Simulator detected — skipping FCM init');
        return;
      }

      debugPrint('🔔 Initializing Notifications for user: $userId');

      NotificationSettings settings = await _firebaseMessaging
          .requestPermission(alert: true, sound: true, badge: true);

      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        debugPrint('🚫 User denied notification permissions.');
        return;
      }

      if (settings.authorizationStatus == AuthorizationStatus.notDetermined) {
        debugPrint('⚪ Notification permission not determined.');
        return;
      }

      debugPrint('✅ Notification permission granted.');

      // APNS token is iOS-only; skip on Android
      if (Platform.isIOS) {
        String? apnsToken = await _firebaseMessaging.getAPNSToken();
        int retryCount = 0;
        while (apnsToken == null && retryCount < 10) {
          await Future.delayed(const Duration(seconds: 1));
          apnsToken = await _firebaseMessaging.getAPNSToken();
          retryCount++;
          debugPrint('⏳ Waiting for APNS token... (attempt $retryCount)');
        }

        if (apnsToken == null) {
          debugPrint(
            '❌ APNS token not available after 10 attempts. Skipping FCM init.',
          );
          return;
        }

        debugPrint('✅ APNS Token received');
      }

      // Delete cached token to force Firebase to generate a fresh token
      await _firebaseMessaging.deleteToken();
      debugPrint('🗑️ Old FCM token deleted');

      final String? token = await _firebaseMessaging.getToken();
      debugPrint('TOKEN RECEIVED $token');
      log('📌 FCM Token: $token');

      if (token != null) {
        await sendTokenToServer(
          context,
          userId: userId,
          token: token,
          userLat: userLat,
          userLng: userLng,
        );
        await _registerFcmToken(token);
      }

      _onMessageSub ??= FirebaseMessaging.onMessage.listen((
        RemoteMessage message,
      ) {
        debugPrint(
          '📩 Foreground FCM received: ${message.notification?.title} - ${message.notification?.body}',
        );
        debugPrint('📩 Foreground FCM data: ${message.data}');

        // Notify listeners that a foreground message arrived — they should refresh from API
        _foregroundMessageController.add(null);
      });

      await FirebaseMessaging.instance.getInitialMessage().then((message) {
        if (message != null) {
          debugPrint(
            '📩 Notification caused app launch: ${message.notification?.body}',
          );
          _handleNotificationNavigation(message);
        }
      });

      _onMessageOpenedAppSub ??= FirebaseMessaging.onMessageOpenedApp.listen((
        RemoteMessage message,
      ) {
        debugPrint('📩 Notification clicked: ${message.notification?.body}');
        _handleNotificationNavigation(message);
      });
    } catch (e) {
      debugPrint('❌ FCM Initialization Error: $e');
    } finally {
      _isInitializing = false;
    }
  }

  Future<void> initAPNSToken() async {
    final String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();
    debugPrint('📌 APNs Token: $apnsToken');
  }

  Future<String?> getFCMToken() async {
    try {
      if (Platform.isIOS) {
        String? apnsToken;
        try {
          apnsToken = await _firebaseMessaging.getAPNSToken();
        } on FirebaseException catch (_) {
          debugPrint(
            '⚠️ APNS token not set yet — skipping FCM token retrieval',
          );
          return null;
        }
        if (apnsToken == null) {
          debugPrint('⚠️ APNS token is null — skipping FCM token retrieval');
          return null;
        }
      }
      final token = await _firebaseMessaging.getToken();
      log('📌 FCM Token retrieved: $token');
      return token;
    } on FirebaseException catch (e) {
      if (e.code.contains('apns-token-not-set')) {
        debugPrint('⚠️ APNS token not set yet — returning null');
        return null;
      }
      rethrow;
    }
  }

  Future<void> sendTokenToServer(
    BuildContext context, {
    required String userId,
    required String token,
    double? userLat,
    double? userLng,
  }) async {
    try {
      await _userRepo.sendToken(
        userId: userId,
        token: token,
        userLat: userLat,
        userLng: userLng,
      );
    } catch (e) {
      if (context.mounted) ErrorHandler.handle(context, e, serviceName: tag);
    }
  }

  /// Register the FCM token with the notifications service — required for
  /// the thought-monitoring check-in prompts to be delivered.
  Future<void> _registerFcmToken(String token) async {
    try {
      await _userRepo.registerFcmToken(token: token);
    } catch (e) {
      debugPrint('⚠️ FCM token registration failed silently: $e');
    }
  }

  Future<void> pushNotification(
    BuildContext context,
    String receiverId,
    String title,
    String message,
  ) async {
    try {
      await _userRepo.sendNotification(
        receiverId: receiverId,
        title: title,
        message: message,
      );
    } catch (e) {
      if (context.mounted) {
        ErrorHandler.handle(context, e, serviceName: tag);
      }
    }
  }

  Future<void> initFCM({
    required BuildContext context,
    double? userLat,
    double? userLng,
  }) async {
    debugPrint('IN INIT FCM');
    final id = _session.user?.id ?? '';
    debugPrint('Initializing FCM for user ID: $id');
    await initialize(context, userId: id, userLat: userLat, userLng: userLng);
  }

  Future<bool> isIOSSimulator() async {
    if (!Platform.isIOS) return false;

    final deviceInfo = DeviceInfoPlugin();
    final iosInfo = await deviceInfo.iosInfo;

    return !iosInfo.isPhysicalDevice;
  }

  void _handleNotificationNavigation(RemoteMessage message) {
    final type = message.data['type'] as String?;
    final route = NotificationRouteResolver.routeForType(
      type,
      communityId: _session.communityId,
    );

    // Defer navigation to after the current frame to avoid _debugLocked
    SchedulerBinding.instance.addPostFrameCallback((_) {
      App.navigatorKey.currentState?.pushNamed(route);
    });
  }
}
