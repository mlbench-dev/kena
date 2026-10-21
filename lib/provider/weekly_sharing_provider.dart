import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kena_emotional_journey/app/components/my_dialog.dart';
import 'package:kena_emotional_journey/app/utils/premium_features.dart';
import 'package:kena_emotional_journey/app/utils/extensions/flush_bar_extension.dart';
import 'package:kena_emotional_journey/provider/subscription_provider.dart';
import 'package:kena_emotional_journey/services/user/user_home_service.dart';
import 'package:kena_emotional_journey/view/analytics/weekly_overall.dart'
    show ShareWeeklyDialog;

/// Centralizes the "start/stop sharing weekly forecast with circle" flow so
/// [WeeklyOverall] and [WeeklyFeeds] share one implementation and one status
/// instead of each keeping its own copy — toggling it updates the shared
/// state in place, no full-screen reload required.
class WeeklySharingController extends ChangeNotifier {
  WeeklySharingController({UserHomeService? userHomeService})
    : _service = userHomeService ?? UserHomeService();

  final UserHomeService _service;

  bool _isShared = false;
  bool _isStopping = false;

  bool get isShared => _isShared;
  bool get isStopping => _isStopping;

  /// Call after fetching a screen's own weekly feed data so the controller
  /// reflects the server's current "am I sharing" status.
  void syncSharedStatus(bool isShared) {
    if (_isShared == isShared) return;
    _isShared = isShared;
    notifyListeners();
  }

  /// The user's local date as `yyyy-MM-dd`. The weekly feed, shared-users and
  /// stop-sharing calls must all send the same date; without one the server
  /// falls back to its UTC date, which near midnight differs from local.
  static String localDate([DateTime? date]) =>
      DateFormat('yyyy-MM-dd').format(date ?? DateTime.now());

  /// [endDate] should be the same date the weekly feed was loaded with.
  Future<void> startSharing(BuildContext context, {String? endDate}) async {
    if (!context.requirePremium(PremiumFeature.shareWeeklyForecast)) return;
    final shared = await MyDialogBox.show<bool>(
      context,
      child: ShareWeeklyDialog(
        parentContext: context,
        endDate: endDate ?? localDate(),
      ),
    );

    if (shared == true) {
      _isShared = true;
      notifyListeners();
    }
  }

  /// Stops sharing the weekly forecast for the week ending on [endDate]
  /// (same date as the feed). No member list is needed for this.
  Future<void> stopSharing(BuildContext context, {String? endDate}) async {
    if (_isStopping) return;

    _isStopping = true;
    notifyListeners();

    final isStillShared = await _service.stopSharingWeeklyForecast(
      endDate: endDate ?? localDate(),
      context: context,
    );

    _isStopping = false;
    if (isStillShared != null) _isShared = isStillShared;
    notifyListeners();

    if (isStillShared == false && context.mounted) {
      context.flushBarSuccessMessage(
        message: 'Stopped sharing weekly forecast',
      );
    }
  }
}
