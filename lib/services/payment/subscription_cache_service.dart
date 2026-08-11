import 'dart:convert';
import 'dart:developer';

import 'package:kena_emotional_journey/app/utils/local_storage.dart';

/// ============================================================
/// SUBSCRIPTION CACHE SERVICE
/// ============================================================
/// Industry-standard pattern:
///   Backend  = source of truth (Stripe + DB)
///   Local    = cached copy (fast startup + offline support)
///
/// Decision flow on app launch:
///   1. Read local cache
///   2. If expiryDate is in the future → allow access immediately
///   3. Sync with backend in background and refresh the cache
///   4. Never block the user due to a temporary API failure
/// ============================================================
class SubscriptionCacheService {
  // ─── Singleton ───────────────────────────────────────────
  factory SubscriptionCacheService() => _instance;
  SubscriptionCacheService._internal();
  static final SubscriptionCacheService _instance =
      SubscriptionCacheService._internal();

  final LocalStorage _localStorage = LocalStorage();

  // ─── Storage keys ────────────────────────────────────────
  static const _kIsActive = 'sub_is_active';
  static const _kHasSubscription = 'sub_has_subscription';
  static const _kIsTrial = 'sub_is_trial';
  static const _kStatus = 'sub_status';
  static const _kExpiryDate = 'sub_expiry_date';
  static const _kPlan = 'sub_plan';
  static const _kLastSyncedAt = 'sub_last_synced_at';
  // Freemium flag — user explicitly chose the free tier (ads shown)
  static const _kIsFreemium = 'sub_is_freemium';

  // ──────────────────────────────────────────────────────────
  // READ — cached status (fast, no network)
  // ──────────────────────────────────────────────────────────

  /// Returns true when the user has a subscription that:
  ///   • is marked active / trial / hasSubscription in the cache, OR
  ///   • the user explicitly selected the Freemium plan, AND
  ///   • has not passed its expiry date (if one is stored).
  ///
  /// Freemium counts as a valid "subscription" for app-access purposes,
  /// but ads are still shown for freemium users (see [isFreemiumActive]).
  Future<bool> isSubscriptionValid() async {
    try {
      // Freemium users always have valid access
      final isFreemium = await _localStorage.readValue(_kIsFreemium) == 'true';
      if (isFreemium) {
        log('[SubscriptionCache] Freemium plan active — access granted');
        return true;
      }

      final isActive = await _localStorage.readValue(_kIsActive) == 'true';
      final isTrial = await _localStorage.readValue(_kIsTrial) == 'true';
      final hasSubscription =
          await _localStorage.readValue(_kHasSubscription) == 'true';

      // If none of the flags are set the cache is empty / user never subscribed
      if (!isActive && !isTrial && !hasSubscription) {
        log('[SubscriptionCache] No cached subscription flags');
        return false;
      }

      // Time-based expiry check — works offline
      final expiryStr = await _localStorage.readValue(_kExpiryDate);
      if (expiryStr != null && expiryStr.isNotEmpty) {
        try {
          final expiry = DateTime.parse(expiryStr);
          final stillValid = DateTime.now().isBefore(expiry);
          log(
            '[SubscriptionCache] Expiry check: $expiryStr → '
            '${stillValid ? "VALID" : "EXPIRED"}',
          );
          return stillValid;
        } catch (_) {
          // If parsing fails, fall through to flag-based check
        }
      }

      // No expiry date stored — trust the cached flags
      log('[SubscriptionCache] No expiry date cached; trusting flags');
      return isActive || isTrial || hasSubscription;
    } catch (e) {
      log('[SubscriptionCache] Error reading cache: $e');
      return false;
    }
  }

  /// Returns true when the user is on the Freemium plan.
  /// Used by [AdMobService] to decide whether ads should be shown.
  /// Freemium users should always see ads even though [isSubscriptionValid]
  /// returns true for them.
  Future<bool> isFreemiumActive() async {
    try {
      return await _localStorage.readValue(_kIsFreemium) == 'true';
    } catch (e) {
      log('[SubscriptionCache] Error reading freemium flag: $e');
      return false;
    }
  }

  /// Returns true when the cached subscription is an active or trial
  /// monthly/annual plan. Freemium and users without a plan return false.
  Future<bool> hasPaidSubscription() async {
    try {
      if (await isFreemiumActive()) return false;

      final cachedSubscription = await getCachedSubscription();
      final subscriptionType =
          (cachedSubscription?['subscriptionType'] ??
                  await _localStorage.readValue(_kPlan))
              ?.toString()
              .toLowerCase();
      final isActive =
          cachedSubscription?['isActive'] == true ||
          await _localStorage.readValue(_kIsActive) == 'true';
      final isTrial =
          cachedSubscription?['isTrial'] == true ||
          await _localStorage.readValue(_kIsTrial) == 'true';

      return (subscriptionType == 'monthly' || subscriptionType == 'annual') &&
          (isActive || isTrial);
    } catch (e) {
      log('[SubscriptionCache] Error checking paid subscription: $e');
      return false;
    }
  }

  /// Returns the full cached subscription map (or null if empty).
  Future<Map<String, dynamic>?> getCachedSubscription() async {
    try {
      final raw = await _localStorage.readValue('sub_cache_json');
      if (raw == null) return null;
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (e) {
      log('[SubscriptionCache] Error reading JSON cache: $e');
      return null;
    }
  }

  /// When the cache was last synced with the backend.
  Future<DateTime?> lastSyncedAt() async {
    final raw = await _localStorage.readValue(_kLastSyncedAt);
    if (raw == null) return null;
    try {
      return DateTime.parse(raw);
    } catch (_) {
      return null;
    }
  }

  // ──────────────────────────────────────────────────────────
  // WRITE — persist backend response
  // ──────────────────────────────────────────────────────────

  /// Call this every time you receive a fresh subscription status
  /// from the backend. Extracts and persists all relevant fields.
  ///
  /// If the backend returns `subscriptionType: "freemium"`, the local
  /// freemium flag is automatically set so [isFreemiumActive] returns true
  /// (and ads are shown). If the user upgrades to a paid plan, the flag
  /// is cleared.
  Future<void> saveFromBackendResponse(Map<String, dynamic> backendData) async {
    try {
      final isActive = backendData['isActive'] == true;
      final isTrial = backendData['isTrial'] == true;
      final hasSubscription = backendData['hasSubscription'] == true;
      final status = backendData['status']?.toString() ?? '';
      final plan = backendData['subscriptionType']?.toString() ?? '';

      // Auto-detect freemium from backend response
      final isFreemium = status == 'freemium' || plan == 'freemium';

      // Derive expiry date from any available field
      final expiryRaw =
          backendData['currentPeriodEnd'] ??
          backendData['expiryDate'] ??
          backendData['trialEnd'];
      final expiryDate = expiryRaw?.toString() ?? '';

      await Future.wait([
        _localStorage.setValue(_kIsActive, isActive.toString()),
        _localStorage.setValue(_kIsTrial, isTrial.toString()),
        _localStorage.setValue(_kHasSubscription, hasSubscription.toString()),
        _localStorage.setValue(_kStatus, status),
        _localStorage.setValue(_kPlan, plan),
        _localStorage.setValue(_kExpiryDate, expiryDate),
        _localStorage.setValue(_kIsFreemium, isFreemium.toString()),
        _localStorage.setValue(
          _kLastSyncedAt,
          DateTime.now().toIso8601String(),
        ),
        _localStorage.setValue('sub_cache_json', jsonEncode(backendData)),
      ]);

      log(
        '[SubscriptionCache] Saved — '
        'isActive=$isActive, isTrial=$isTrial, '
        'hasSubscription=$hasSubscription, isFreemium=$isFreemium, '
        'expiry=$expiryDate',
      );
    } catch (e) {
      log('[SubscriptionCache] Error saving to cache: $e');
    }
  }

  // ──────────────────────────────────────────────────────────
  // FREEMIUM — save / clear
  // ──────────────────────────────────────────────────────────

  /// Persists the Freemium plan locally.
  /// Call this when the user selects Freemium on the subscription screen.
  Future<void> saveFreemiumSubscription() async {
    try {
      await Future.wait([
        _localStorage.setValue(_kIsFreemium, 'true'),
        _localStorage.setValue(_kIsActive, 'false'),
        _localStorage.setValue(_kIsTrial, 'false'),
        _localStorage.setValue(_kHasSubscription, 'false'),
        _localStorage.setValue(_kStatus, 'freemium'),
        _localStorage.setValue(_kPlan, 'freemium'),
        _localStorage.setValue(
          _kLastSyncedAt,
          DateTime.now().toIso8601String(),
        ),
      ]);
      log('[SubscriptionCache] Freemium subscription saved');
    } catch (e) {
      log('[SubscriptionCache] Error saving freemium: $e');
    }
  }

  // ──────────────────────────────────────────────────────────
  // CLEAR — on logout
  // ──────────────────────────────────────────────────────────

  Future<void> clearCache() async {
    await Future.wait([
      _localStorage.clearValue(_kIsActive),
      _localStorage.clearValue(_kIsTrial),
      _localStorage.clearValue(_kHasSubscription),
      _localStorage.clearValue(_kStatus),
      _localStorage.clearValue(_kPlan),
      _localStorage.clearValue(_kExpiryDate),
      _localStorage.clearValue(_kLastSyncedAt),
      _localStorage.clearValue(_kIsFreemium),
      _localStorage.clearValue('sub_cache_json'),
    ]);
    log('[SubscriptionCache] Cache cleared');
  }
}
