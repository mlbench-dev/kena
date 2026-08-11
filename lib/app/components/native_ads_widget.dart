import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:kena_emotional_journey/services/common/ad_mob_service.dart';

/// A reusable native ad tile for scrolling content (community/daily/
/// weekly feeds, activity lists). Insert one of these every 6–10 items
/// in your ListView/GridView builder rather than between every item.
///
/// ⚠️ Native ads also require a `NativeAdFactory` registered on the
/// native side (Android `MainActivity.kt`, iOS `AppDelegate.swift`) that
/// renders the ad using your own layout — this widget only handles the
/// Flutter/Dart side of loading + disposing it. See the accompanying
/// explanation for the native factory registration step.
///
/// Usage:
/// ```dart
/// ListView.builder(
///   itemCount: items.length,
///   itemBuilder: (context, index) {
///     if (index != 0 && index % 8 == 0) {
///       return const NativeAdWidget(factoryId: 'listTile');
///     }
///     return FeedItemTile(item: items[index]);
///   },
/// )
/// ```
class NativeAdWidget extends StatefulWidget {
  const NativeAdWidget({super.key, required this.factoryId, this.height = 120});

  /// Must match the factory ID registered natively via
  /// `registerNativeAdFactory(flutterEngine, factoryId, factory)`.
  final String factoryId;
  final double height;

  @override
  State<NativeAdWidget> createState() => _NativeAdWidgetState();
}

class _NativeAdWidgetState extends State<NativeAdWidget> {
  NativeAd? _nativeAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    AdMobService.loadNativeAd(
      factoryId: widget.factoryId,
      onAdLoaded: (ad) {
        if (mounted) {
          setState(() {
            _nativeAd = ad;
            _isAdLoaded = true;
          });
        }
      },
      onAdFailedToLoad: (_) {
        if (mounted) {
          setState(() => _isAdLoaded = false);
        }
      },
    );
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAdLoaded || _nativeAd == null) {
      return const SizedBox.shrink();
    }

    return Container(
      height: widget.height,
      alignment: Alignment.center,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: AdWidget(ad: _nativeAd!),
    );
  }
}
