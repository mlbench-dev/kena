import 'package:flutter/material.dart';
import 'package:kena_emotional_journey/app/components/my_dialog.dart';
import 'package:kena_emotional_journey/app/utils/extensions/flush_bar_extension.dart';
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

  Future<void> startSharing(BuildContext context) async {
    final shared = await MyDialogBox.show<bool>(
      context,
      child: ShareWeeklyDialog(parentContext: context),
    );

    if (shared == true) {
      _isShared = true;
      notifyListeners();
    }
  }

  Future<void> stopSharing(BuildContext context) async {
    if (_isStopping) return;

    final sharedResult = await _service.getSharedMembers(context: context);
    if (!context.mounted) return;

    final userIds =
        sharedResult?.data?.map((m) => m.id).whereType<String>().toList() ?? [];
    if (userIds.isEmpty) {
      context.flushBarErrorMessage(message: 'No shared members found');
      return;
    }

    _isStopping = true;
    notifyListeners();

    final today = DateTime.now().toIso8601String().split('T')[0];
    final success = await _service.stopSharingWeeklyForecast(
      userIds: userIds,
      endDate: today,
      context: context,
    );

    _isStopping = false;
    if (success) {
      _isShared = false;
    }
    notifyListeners();

    if (success && context.mounted) {
      context.flushBarSuccessMessage(
        message: 'Stopped sharing weekly forecast',
      );
    }
  }
}
