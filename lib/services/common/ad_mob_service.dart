import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
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

    await MobileAds.instance.updateRequestConfiguration(
      RequestConfiguration(testDeviceIds: <String>[]),
    );

    _initialized = true;
    log('[AdMobService] Initialized (TEST ADS ONLY)');
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
  // 🔑 AD UNIT IDS (Google test IDs — see warning above)
  // ─────────────────────────────────────────────

  static String get bannerAdUnitId => Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/6300978111'
      : 'ca-app-pub-3940256099942544/2435281174';

  static String get nativeAdUnitId => Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/2247696110'
      : 'ca-app-pub-3940256099942544/3986624511';

  static String get interstitialAdUnitId => Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/1033173712'
      : 'ca-app-pub-3940256099942544/4411468910';

  static String get rewardedAdUnitId => Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/5224354917'
      : 'ca-app-pub-3940256099942544/1712485313';

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
  // 🧩 NATIVE AD
  // ─────────────────────────────────────────────
  static Future<void> loadNativeAd({
    required String factoryId,
    required void Function(NativeAd ad) onAdLoaded,
    void Function(LoadAdError error)? onAdFailedToLoad,
  }) async {
    if (!await shouldShowAds()) return;

    final nativeAd = NativeAd(
      adUnitId: nativeAdUnitId,
      factoryId: factoryId,
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          debugPrint('✅ Native ad loaded');
          onAdLoaded(ad as NativeAd);
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('❌ Native ad failed to load: $error');
          ad.dispose();
          onAdFailedToLoad?.call(error);
        },
        onAdOpened: (ad) => debugPrint('📖 Native ad opened'),
        onAdClosed: (ad) => debugPrint('📕 Native ad closed'),
        onAdImpression: (ad) => debugPrint('👁️ Native ad impression'),
      ),
    );
    nativeAd.load();
  }

  // ─────────────────────────────────────────────
  // 📺 INTERSTITIAL AD (with session cap + cooldown)
  // ─────────────────────────────────────────────

  static InterstitialAd? _interstitialAd;
  static bool _isInterstitialAdReady = false;
  static DateTime? _lastInterstitialShownAt;
  static int _interstitialShownCount = 0;

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
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              debugPrint('❌ Interstitial ad failed to show: $error');
              ad.dispose();
              _interstitialAd = null;
              _isInterstitialAdReady = false;
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

  /// Shows the interstitial ad if ready, respecting session cap and cooldown.
  static Future<bool> showInterstitialAd() async {
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
  // 🎁 REWARDED AD
  // ─────────────────────────────────────────────

  static RewardedAd? _rewardedAd;
  static bool _isRewardedAdReady = false;

  /// Pre-loads a rewarded ad. Call this early so the ad is ready when
  static void loadRewardedAd() {
    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('✅ Rewarded ad loaded');
          _rewardedAd = ad;
          _isRewardedAdReady = true;

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              debugPrint('📕 Rewarded ad dismissed');
              ad.dispose();
              _rewardedAd = null;
              _isRewardedAdReady = false;
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              debugPrint('❌ Rewarded ad failed to show: $error');
              ad.dispose();
              _rewardedAd = null;
              _isRewardedAdReady = false;
            },
          );
        },
        onAdFailedToLoad: (error) {
          debugPrint('❌ Rewarded ad failed to load: $error');
          _isRewardedAdReady = false;
        },
      ),
    );
  }

  /// Shows the rewarded ad if ready.
  static bool showRewardedAd({
    required void Function(AdWithoutView ad, RewardItem reward)
    onUserEarnedReward,
  }) {
    if (_isRewardedAdReady && _rewardedAd != null) {
      _rewardedAd!.show(onUserEarnedReward: onUserEarnedReward);
      return true;
    }
    debugPrint('⚠️ Rewarded ad not ready yet');
    return false;
  }

  // ─────────────────────────────────────────────
  // 🧹 CLEANUP
  // ─────────────────────────────────────────────

  /// Disposes all preloaded full-screen ads. Call when the app is closing
  /// or on logout.
  static void dispose() {
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    _interstitialAd = null;
    _rewardedAd = null;
    _isInterstitialAdReady = false;
    _isRewardedAdReady = false;
  }
}
