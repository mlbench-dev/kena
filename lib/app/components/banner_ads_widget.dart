import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:kena_emotional_journey/services/common/ad_mob_service.dart';

/// A reusable banner ad widget. Automatically hides for subscribed users
/// (handled inside [AdMobService.loadBannerAd]) and while the ad hasn't
/// loaded, so it never reserves empty space in your layout.
///
/// Usage:
/// ```dart
/// // At the bottom of a Column/Scaffold, e.g. Home, Analytics, Community:
/// const BannerAdWidget(),
/// ```
class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    AdMobService.loadBannerAd(
      onAdLoaded: (ad) {
        if (mounted) {
          setState(() {
            _bannerAd = ad;
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
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAdLoaded || _bannerAd == null) {
      return const SizedBox.shrink(); // Takes no space if ad isn't loaded
    }

    return Container(
      alignment: Alignment.center,
      width: double.infinity,
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
