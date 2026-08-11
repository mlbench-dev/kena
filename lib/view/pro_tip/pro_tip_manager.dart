import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:kena_emotional_journey/generated/assets/assets.gen.dart';
import 'package:kena_emotional_journey/view/pro_tip/pro_tip.dart';
import 'package:kena_emotional_journey/services/common/session_manager/session_controller.dart';

/// Manages the scheduling, persistence, and retrieval of pro tips.
///
/// Tips are shown once per milestone, based on days since the user's
/// first login. Each tip is shown at most once and never repeats.
class ProTipManager {
  static String get _firstLoginKey {
    final userId = SessionController().user?.id ?? 'guest';
    return 'pro_tip_first_login_timestamp_$userId';
  }

  static String get _shownTipsKey {
    final userId = SessionController().user?.id ?? 'guest';
    return 'pro_tip_shown_ids_$userId';
  }

  /// The ordered list of pro tips, sorted by dayOffset.
  static final List<ProTip> tips = [
    ProTip(
      id: 'tip_first_login',
      dayOffset: 0,
      title: 'Pro tip',
      description:
          'Logging consistently unlocks deeper insights into your emotional patterns.',
      buttonLabel: 'Got it',
      iconBuilder: () => Assets.images.bulb.image(),
    ),
    ProTip(
      id: 'tip_3_days',
      dayOffset: 3,
      title: '3 days in a row!',
      description: "That's the foundation of real growth. Keep going!",
      buttonLabel: 'Keep going',
      iconBuilder: () => Assets.images.threeDay.image(),
    ),
    ProTip(
      id: 'tip_7_days',
      dayOffset: 7,
      title: '7 days in a row!',
      description:
          "Congratulations! You've reflected 7 days in a row. See your insights.",
      buttonLabel: 'See analytics',
      iconBuilder: () => Assets.images.week.image(),
    ),
    ProTip(
      id: 'tip_14_days',
      dayOffset: 14,
      title: 'Two weeks!',
      description:
          "Two weeks of showing up for yourself that's something to be really proud of.",
      buttonLabel: 'Explore insights',
      iconBuilder: () => Assets.images.twoWeeks.image(),
    ),
  ];

  /// Call once after a successful login/signup.
  ///
  /// Records the current timestamp as the "first login" date.
  /// Guarded: will NOT overwrite if a timestamp already exists.
  static Future<void> markFirstLoginIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getInt(_firstLoginKey) == null) {
      await prefs.setInt(_firstLoginKey, DateTime.now().millisecondsSinceEpoch);
      debugPrint('[ProTipManager] First login timestamp saved');
    }
  }

  /// Returns the next tip that is due but hasn't been shown yet,
  /// or `null` if no tip is due.
  static Future<ProTip?> getNextDueTip() async {
    final prefs = await SharedPreferences.getInstance();
    final firstLoginMillis = prefs.getInt(_firstLoginKey);
    if (firstLoginMillis == null) return null;

    final firstLogin = DateTime.fromMillisecondsSinceEpoch(firstLoginMillis);
    final daysSinceFirstLogin = DateTime.now().difference(firstLogin).inDays;

    final shownTips = prefs.getStringList(_shownTipsKey) ?? [];

    for (final tip in tips) {
      if (daysSinceFirstLogin >= tip.dayOffset &&
          !shownTips.contains(tip.id)) {
        return tip;
      }
    }
    return null;
  }

  /// Records a tip as shown so it will never appear again.
  static Future<void> markTipAsShown(String tipId) async {
    final prefs = await SharedPreferences.getInstance();
    final shownTips = prefs.getStringList(_shownTipsKey) ?? [];
    if (!shownTips.contains(tipId)) {
      shownTips.add(tipId);
      await prefs.setStringList(_shownTipsKey, shownTips);
      debugPrint('[ProTipManager] Marked tip "$tipId" as shown');
    }
  }

  // ─── Debug Helpers ──────────────────────────────────────────────────────────

  /// Sets the first login timestamp to [days] days ago.
  /// Use this in debug mode to simulate milestones without waiting.
  ///
  /// Example: `ProTipManager.debugSetFirstLoginDaysAgo(7)` will make the
  /// 7-day tip eligible on the next check.
  static Future<void> debugSetFirstLoginDaysAgo(int days) async {
    final prefs = await SharedPreferences.getInstance();
    final fakeTime = DateTime.now().subtract(Duration(days: days));
    await prefs.setInt(_firstLoginKey, fakeTime.millisecondsSinceEpoch);
    debugPrint(
      '[ProTipManager] DEBUG — first login set to $days days ago ($fakeTime)',
    );
  }

  /// Clears all pro tip related data (first login and shown tips).
  /// Call this when the user logs out so a new account on the same device starts fresh.
  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_firstLoginKey);
    await prefs.remove(_shownTipsKey);
    debugPrint('[ProTipManager] All data cleared on logout');
  }

  /// Clears all shown-tip records so every tip becomes eligible again.
  static Future<void> debugResetShownTips() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_shownTipsKey);
    debugPrint('[ProTipManager] DEBUG — all shown tips reset');
  }
}
