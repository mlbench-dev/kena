import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:kena_emotional_journey/services/payment/subscription_cache_service.dart';

/// ============================================================
/// AD MOB SERVICE
/// ============================================================

class AdMobService {
  AdMobService._();

  static bool _initialized = false;

  /// Initializes the Mobile Ads SDK. Safe to call multiple times.
  static Future<void> initialize() async {
    if (_initialized) return;
    await MobileAds.instance.initialize();

    // Production release builds use live ad unit IDs, so any device not listed
    // here gets real ads (real impressions/clicks on your own test runs risk an
    // invalid-traffic flag on the AdMob account). To add a device: run the
    // app on it once, then copy the ID from the console line Google prints,
    // e.g. "To get test ads on this device, set: ... testDeviceIdentifiers
    // = @[ @"XXXXXXXX-XXXX-..." ]" (iOS) or "Use RequestConfiguration...
    // testDeviceIds": ["XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"]" (Android). Put
    // the IDs in .env as ADMOB_TEST_DEVICE_IDS=id1,id2.
    final testDeviceIds =
        dotenv.env['ADMOB_TEST_DEVICE_IDS']
            ?.split(',')
            .map((id) => id.trim())
            .where((id) => id.isNotEmpty)
            .toList() ??
        <String>[];

    await MobileAds.instance.updateRequestConfiguration(
      RequestConfiguration(testDeviceIds: testDeviceIds),
    );

    _initialized = true;
    log(
      '[AdMobService] Initialized (${testDeviceIds.length} test device(s), '
      'testAds: $_useTestAds)',
    );
  }

  static Future<bool> shouldShowAds() async {
    // Freemium users have a "valid" subscription for app access,
    // but they should still see ads.
    final isFreemium = await SubscriptionCacheService().isFreemiumActive();
    if (isFreemium) return true;

    // Paid / trial subscribers do NOT see ads.
    final isSubscribed = await SubscriptionCacheService().isSubscriptionValid();
    return !isSubscribed;
  }

  // ─────────────────────────────────────────────
  // 🔑 AD UNIT IDS (Kena production — from .env)
  // ─────────────────────────────────────────────

  static const String _flavor = String.fromEnvironment(
    'FLAVOR',
    defaultValue: 'production',
  );

  /// Live ad units are only requested from release builds of the production
  /// flavor. Debug/profile builds and dev/staging flavors always get Google's
  /// test units so our own testing never generates invalid traffic.
  static bool get _useTestAds => !kReleaseMode || _flavor != 'production';

  // Google sample ad units: https://developers.google.com/admob/flutter/test-ads
  static const String _testAndroidBanner =
      'ca-app-pub-3940256099942544/6300978111';
  static const String _testIosBanner = 'ca-app-pub-3940256099942544/2934735716';
  static const String _testAndroidInterstitial =
      'ca-app-pub-3940256099942544/1033173712';
  static const String _testIosInterstitial =
      'ca-app-pub-3940256099942544/4411468910';

  static String _resolveUnitId(String envKey, String testId) {
    if (_useTestAds) return testId;
    final id = dotenv.env[envKey]?.trim();
    if (id == null || id.isEmpty) {
      // Missing config must never crash the app; fall back to a test unit.
      log('[AdMobService] $envKey missing in .env — using test ad unit');
      return testId;
    }
    return id;
  }

  static String get bannerAdUnitId => Platform.isAndroid
      ? _resolveUnitId('ANDROID_ADMOB_BANNER_UNIT_ID', _testAndroidBanner)
      : _resolveUnitId('IOS_ADMOB_BANNER_UNIT_ID', _testIosBanner);

  static String get interstitialAdUnitId => Platform.isAndroid
      ? _resolveUnitId(
          'ANDROID_ADMOB_INTERSTITIAL_UNIT_ID',
          _testAndroidInterstitial,
        )
      : _resolveUnitId('IOS_ADMOB_INTERSTITIAL_UNIT_ID', _testIosInterstitial);

  // ─────────────────────────────────────────────
  // 📐 BANNER AD
  // ─────────────────────────────────────────────

  static Future<void> loadBannerAd({
    required void Function(BannerAd ad) onAdLoaded,
    void Function(LoadAdError error)? onAdFailedToLoad,
    AdSize size = AdSize.banner,
  }) async {
    if (!await shouldShowAds()) return;

    final bannerAd = BannerAd(
      adUnitId: bannerAdUnitId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint('✅ Banner ad loaded');
          onAdLoaded(ad as BannerAd);
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('❌ Banner ad failed to load: $error');
          ad.dispose();
          onAdFailedToLoad?.call(error);
        },
        onAdOpened: (ad) => debugPrint('📖 Banner ad opened'),
        onAdClosed: (ad) => debugPrint('📕 Banner ad closed'),
        onAdImpression: (ad) => debugPrint('👁️ Banner ad impression'),
      ),
    );
    bannerAd.load();
  }

  // ─────────────────────────────────────────────
  // 📺 INTERSTITIAL AD (with session cap + cooldown)
  // ─────────────────────────────────────────────

  static InterstitialAd? _interstitialAd;
  static bool _isInterstitialAdReady = false;
  static DateTime? _lastInterstitialShownAt;
  static int _interstitialShownCount = 0;
  static VoidCallback? _onInterstitialClosed;

  /// Max interstitials shown per app session (per your requirement: 1–2).
  static const int maxInterstitialsPerSession = 2;

  /// Minimum gap between two interstitials.
  static const Duration interstitialCooldown = Duration(minutes: 5);

  /// Pre-loads an interstitial ad. Call this early
  static Future<void> loadInterstitialAd() async {
    if (!await shouldShowAds()) return;
    if (_isInterstitialAdReady) return;

    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('✅ Interstitial ad loaded');
          _interstitialAd = ad;
          _isInterstitialAdReady = true;

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              debugPrint('📕 Interstitial ad dismissed');
              ad.dispose();
              _interstitialAd = null;
              _isInterstitialAdReady = false;
              _notifyInterstitialClosed();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              debugPrint('❌ Interstitial ad failed to show: $error');
              ad.dispose();
              _interstitialAd = null;
              _isInterstitialAdReady = false;
              _notifyInterstitialClosed();
            },
          );
        },
        onAdFailedToLoad: (error) {
          debugPrint('❌ Interstitial ad failed to load: $error');
          _isInterstitialAdReady = false;
        },
      ),
    );
  }

  static void _notifyInterstitialClosed() {
    final callback = _onInterstitialClosed;
    _onInterstitialClosed = null;
    callback?.call();
  }

  /// Shows the interstitial ad if ready, respecting session cap and cooldown.
  ///
  /// [onClosed] runs once the ad is dismissed (or fails to show). It is only
  /// called when this returns true.
  static Future<bool> showInterstitialAd({VoidCallback? onClosed}) async {
    if (!await shouldShowAds()) return false;

    if (_interstitialShownCount >= maxInterstitialsPerSession) {
      debugPrint(
        '⚠️ Interstitial session cap reached ($maxInterstitialsPerSession)',
      );
      return false;
    }

    final lastShown = _lastInterstitialShownAt;
    if (lastShown != null &&
        DateTime.now().difference(lastShown) < interstitialCooldown) {
      debugPrint('⚠️ Interstitial cooldown active');
      return false;
    }

    if (_isInterstitialAdReady && _interstitialAd != null) {
      _onInterstitialClosed = onClosed;
      _interstitialAd!.show();
      _lastInterstitialShownAt = DateTime.now();
      _interstitialShownCount++;
      // Pre-load the next one for the following opportunity.
      loadInterstitialAd();
      return true;
    }

    debugPrint('⚠️ Interstitial ad not ready yet');
    return false;
  }

  /// Resets the per-session interstitial counter. Call on app restart if
  /// your session boundary differs from process lifetime.
  static void resetInterstitialSession() {
    _interstitialShownCount = 0;
    _lastInterstitialShownAt = null;
  }

  // ─────────────────────────────────────────────
  // 🧹 CLEANUP
  // ─────────────────────────────────────────────

  /// Disposes all preloaded full-screen ads. Call when the app is closing
  /// or on logout.
  static void dispose() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _isInterstitialAdReady = false;
  }
}
