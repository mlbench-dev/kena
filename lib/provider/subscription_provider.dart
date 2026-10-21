import 'package:flutter/material.dart';
import 'package:kena_emotional_journey/app/components/premium_dialog.dart';
import 'package:kena_emotional_journey/app/utils/premium_features.dart';
import 'package:kena_emotional_journey/services/payment/subscription_cache_service.dart';
import 'package:provider/provider.dart';

/// Single source of truth for "is this user on Freemium?".

class SubscriptionProvider extends ChangeNotifier {
  SubscriptionProvider() {
    _cache.changes.addListener(refresh);
    refresh();
  }

  final SubscriptionCacheService _cache = SubscriptionCacheService();

  // Defaults to not-Freemium so paying users never see a lock flash in
  // before the cache has been read.
  bool _isFreemium = false;

  bool get isFreemium => _isFreemium;
  bool get isPremium => !_isFreemium;

  Future<void> refresh() async {
    final isFreemium = await _cache.isFreemiumActive();
    if (isFreemium == _isFreemium) return;
    _isFreemium = isFreemium;
    notifyListeners();
  }

  bool canUse(PremiumFeature feature) {
    // Every feature in PremiumFeature is Premium-only today. Add a
    return isPremium;
  }

  /// case-insensitively, so re-adding an activity they already have is free.
  bool canAddActivities({
    required Iterable<String> existingNames,
    required Iterable<String> newNames,
  }) {
    if (canUse(PremiumFeature.unlimitedActivities)) return true;
    final all = {...existingNames.map(_normalize), ...newNames.map(_normalize)}
      ..remove('');
    return all.length <= FreemiumLimits.maxActivities;
  }

  /// True when a Freemium user already has [FreemiumLimits.maxActivities]
  /// distinct activities, i.e. no new activity can be added.
  bool hasReachedActivityLimit(Iterable<String> existingNames) {
    if (canUse(PremiumFeature.unlimitedActivities)) return false;
    final names = existingNames.map(_normalize).toSet()..remove('');
    return names.length >= FreemiumLimits.maxActivities;
  }

  static String _normalize(String name) => name.trim().toLowerCase();

  @override
  void dispose() {
    _cache.changes.removeListener(refresh);
    super.dispose();
  }
}

extension PremiumGate on BuildContext {
  /// True when the user is on the Freemium plan.
  bool get isFreemium => watch<SubscriptionProvider>().isFreemium;

  bool requirePremium(PremiumFeature feature) {
    if (read<SubscriptionProvider>().canUse(feature)) return true;
    PremiumDialog.show(this);
    return false;
  }

  /// Freemium users, so screens can cache it lazily.
  Future<bool> requireActivitySlots({
    required Future<List<String>> Function() existingNames,
    required Iterable<String> newNames,
  }) async {
    final subscription = read<SubscriptionProvider>();
    if (subscription.canUse(PremiumFeature.unlimitedActivities)) return true;
    final existing = await existingNames();
    if (!mounted) return false;
    if (subscription.canAddActivities(
      existingNames: existing,
      newNames: newNames,
    )) {
      return true;
    }
    PremiumDialog.show(this);
    return false;
  }
}
