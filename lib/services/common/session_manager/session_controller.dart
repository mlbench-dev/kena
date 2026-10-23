// Enum for storage keys to prevent typos
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:kena_emotional_journey/app/utils/enums.dart';
import 'package:kena_emotional_journey/app/utils/local_storage.dart';
import 'package:kena_emotional_journey/model/user/users_model.dart';

enum StorageKey {
  accessToken('access_token'),
  communityId('community_id'),
  refreshToken('refresh_token'),
  userType('user_type'),
  user('user'),
  vendor('vendor'),
  distanceFilter('distance_filter'),
  activities('activities'),
  // Subscription cache keys
  subIsActive('sub_is_active'),
  subIsTrial('sub_is_trial'),
  subHasSubscription('sub_has_subscription'),
  subStatus('sub_status'),
  subPlan('sub_plan'),
  subExpiryDate('sub_expiry_date'),
  subLastSyncedAt('sub_last_synced_at'),
  subCacheJson('sub_cache_json');

  const StorageKey(this.value);
  final String value;
}

class SessionController extends ChangeNotifier {
  factory SessionController() => _instance;
  SessionController._internal();
  static final SessionController _instance = SessionController._internal();
  final LocalStorage _localStorage = LocalStorage();

  String? _token;
  String? _communityId;
  String? _refreshToken;
  UserModel? _user;
  UserType? userType;
  bool? _isPermissionRequested;
  int unreadNotificationCount = 0;
  double _distanceFilter = 5.0; // Default 5km

  String? get token => _token;

  String? get communityId => _communityId;
  String? get refreshToken =>
      _refreshToken; //TODO: Refresh token logic isn't implemented yet.
  UserModel? get user => _user;
  bool get isLoggedIn => _token != null;
  bool get isPermissionRequested => _isPermissionRequested ?? false;
  double get distanceFilter => _distanceFilter;
  List<Map<String, dynamic>> _activities = [];
  List<Map<String, dynamic>> get activities => _activities;

  bool _initialized = false;
  Future<void>? _initFuture;

  Future<void> init() {
    if (_initialized) return Future.value();
    _initFuture ??= _initializeSession();
    return _initFuture!;
  }

  /// Returns true if the session is fully initialized
  bool get isInitialized => _initialized;

  /// Resets init flags so [init] can be called again (e.g. after [clearSession])
  void _resetInitState() {
    _initialized = false;
    _initFuture = null;
  }

  Future<void> _initializeSession() async {
    _token = await _localStorage.readValue(StorageKey.accessToken.value);
    _refreshToken = await _localStorage.readValue(
      StorageKey.refreshToken.value,
    );
    final type = await _localStorage.readValue(StorageKey.userType.value);
    //Load activities
    final activitiesString = await _localStorage.readValue(
      StorageKey.activities.value,
    );

    final value = await _localStorage.readValue(StorageKey.communityId.value);
    _communityId = value?.toString();

    if (activitiesString != null) {
      final decoded = jsonDecode(activitiesString);

      if (decoded is List) {
        _activities = decoded
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
      }
    }

    // Load user data
    final userString = await _localStorage.readValue(StorageKey.user.value);
    if (userString != null) {
      try {
        final userJson = jsonDecode(userString) as Map<String, dynamic>;
        _user = UserModel.fromJson(userJson);
        log('User loaded from storage: ${_user?.username}');
      } catch (e) {
        log('Failed to decode user: $e');
        _user = null;
      }
    }

    if (type != null) {
      userType = UserType.fromString(type);
      log('User type loaded: $type');
    }
    if (_token != null) {
      log('Token loaded: $_token');
    }

    // Load distance filter preference
    final distanceStr = await _localStorage.readValue(
      StorageKey.distanceFilter.value,
    );
    if (distanceStr != null) {
      _distanceFilter = double.tryParse(distanceStr) ?? 5.0;
      log('Distance filter loaded: $_distanceFilter km');
    }

    _initialized = true;
  }

  Future<void> saveUserType() async {
    if (userType == null) {
      log('User type is null, cannot save to local storage');
      return;
    }
    await _localStorage.setValue(StorageKey.userType.value, userType!.value);
    log('User type saved: ${userType!.value}');
  }

  Future<void> saveToken({
    required String token,
    // required String refreshToken,
  }) async {
    _token = token;
    // _refreshToken = refreshToken;
    await _localStorage.setValue(StorageKey.accessToken.value, token);
    log('Access Token saved: $token');
    // await _localStorage.setValue(StorageKey.refreshToken.value, refreshToken);
    // log('Refresh Token saved: $refreshToken');
  }

  Future<void> saveCommunityId({required String communityId}) async {
    _communityId = communityId;
    await _localStorage.setValue(StorageKey.communityId.value, communityId);
    log('Community ID saved: $communityId');
  }

  Future<void> clearCommunityId() async {
    _communityId = null;
    await _localStorage.clearValue(StorageKey.communityId.value);
    notifyListeners();
  }

  Future<void> saveActivities(List<Map<String, dynamic>> activities) async {
    _activities = activities;
    await _localStorage.setValue(
      StorageKey.activities.value,
      jsonEncode(activities),
    );
  }

  Future<void> saveUser(UserModel user) async {
    _user = user;
    notifyListeners();
    final encoded = jsonEncode(user.toJson());
    await _localStorage.setValue(StorageKey.user.value, encoded);
    // log('User saved: ${user.id}');
  }

  Future<void> saveDistanceFilter(double distance) async {
    _distanceFilter = distance;
    await _localStorage.setValue(
      StorageKey.distanceFilter.value,
      distance.toString(),
    );
    log('Distance filter saved: $distance km');
  }

  Future<void> updateLocationRequestStatus({bool status = false}) async {
    _isPermissionRequested = status;
  }

  /// Decrements the user's remaining meetup requests by 1
  /// Each user gets 10 requests per day (default from API)
  /// This only updates locally - the server resets to 10 daily
  // Future<bool> decrementRequestsRemaining() async {
  //   if (_user == null) {
  //     log('Cannot decrement requests: user is null');
  //     return false;
  //   }

  // final currentRequests = _user!.requestsRemaining ?? 0;
  // if (currentRequests <= 0) {
  //   log('Cannot decrement requests: already at 0');
  //   return false;
  // }

  // Create a new UserModel with decremented requests
  // final updatedUser = UserModel(
  //   id: _user!.id,
  //   email: _user!.email,
  //   name: _user!.name,
  //   imageUrl: _user!.imageUrl,
  //   createdAt: _user!.createdAt,
  //   updatedAt: _user!.updatedAt,
  //   favoriteVendors: _user!.favoriteVendors,
  //   newVendorAlert: _user!.newVendorAlert,
  //   distanceBasedAlert: _user!.distanceBasedAlert,
  //   favoriteVendorAlert: _user!.favoriteVendorAlert,
  //   lat: _user!.lat,
  //   lng: _user!.lng,
  //   requestsRemaining: currentRequests - 1,
  //   requestsLastResetAt: _user!.requestsLastResetAt,
  //   language: _user!.language,
  //   averageRating: _user!.averageRating,
  //   totalReviews: _user!.totalReviews,
  // );

  // await saveUser(updatedUser);
  // log('Requests remaining decremented to: ${currentRequests - 1}');
  // return true;
  // }

  //   Future<void> saveUser(UserModel user) async {
  //     _user = user;
  //     final encoded = jsonEncode(user.toJson());
  //     await _localStorage.setValue(StorageKey.user.value, encoded);
  //     log('User saved: ${user.id}');
  //   }

  Future<void> clearSession() async {
    _token = null;
    _communityId = null;
    _isPermissionRequested = false;
    _refreshToken = null;
    userType = null;
    _user = null;
    _activities = [];

    // Wipe ALL secure storage, not just the StorageKey values: other services
    // keep per-user data there too (sub_is_entitled, sub_is_freemium, answered
    // check-ins), and leaving those behind leaks the previous user's
    // entitlement to the next account that logs in on this device.
    await _localStorage.clearAll();

    // Cached network images (profile photos, community posts) are user data.
    try {
      await DefaultCacheManager().emptyCache();
    } catch (e) {
      log('Image cache clear failed: $e');
    }

    // ✅ Reset init state so session can be reloaded on next init() call
    _resetInitState();

    log('Session cleared: All data removed');
  }
}
