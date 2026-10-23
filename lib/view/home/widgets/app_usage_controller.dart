import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:kena_emotional_journey/services/common/session_manager/session_controller.dart';
import 'package:kena_emotional_journey/services/user/user_home_service.dart';

class AppUsageController {
  final UserHomeService service;
  final SessionController _sessionController = SessionController();

  AppUsageController(this.service);

  Timer? _timer;
  DateTime? _lastInteraction;

  final int heartbeatInterval = 30; // seconds
  final int idleThreshold = 60; // seconds

  bool _isRunning = false;

  /// Call when user interacts (tap, scroll, etc.)
  void onUserInteraction() {
    _lastInteraction = DateTime.now();
  }

  /// Start tracking
  void start() {
    if (_isRunning) return;

    _isRunning = true;

    _timer = Timer.periodic(
      Duration(seconds: heartbeatInterval),
      (_) => _handleHeartbeat(),
    );
  }

  /// Stop tracking
  void stop() {
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
  }

  /// Core logic: decide whether to send heartbeat
  void _handleHeartbeat() {
    if (_lastInteraction == null) return;

    final diff = DateTime.now().difference(_lastInteraction!).inSeconds;

    if (diff <= idleThreshold) {
      _sendHeartbeat();
    } else {
      debugPrint("⏸ User idle → heartbeat skipped");
    }
  }

  /// Call backend via service
  Future<void> _sendHeartbeat() async {
    // ✅ Guard: skip heartbeat if user is not logged in (token is null)
    if (!_sessionController.isLoggedIn) {
      debugPrint("⏭ Heartbeat skipped → user not logged in (token is null)");
      return;
    }

    try {
      await service.sendAppUsage(
        appIdentifier: "com.kena.app",
        appName: "Kena",
        category: "Health",
        platform: Platform.isIOS ? "ios" : "android",
      );

      debugPrint("🔥 Heartbeat sent");
    } catch (e) {
      debugPrint("❌ Heartbeat error: $e");
    }
  }

  /// App lifecycle support
  void onAppResumed() {
    start();
    onUserInteraction();
  }

  void onAppPaused() {
    stop();
  }

  void dispose() {
    stop();
  }
}
