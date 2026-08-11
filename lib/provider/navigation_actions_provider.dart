import 'package:flutter/material.dart';
import 'package:kena_emotional_journey/app/routes/routes_name.dart';
import 'package:kena_emotional_journey/services/common/session_manager/session_controller.dart';
import 'package:kena_emotional_journey/services/user/user_home_service.dart';

/// ============================================================
/// NAVIGATION ACTIONS CONTROLLER
/// Single source of truth for: Aspire / Forecast / Activities /
/// Analytics / Community — used to live as private methods on
/// _HomeScreenState, now usable from ANY screen (drawer, nav bar,
/// grid cards, etc.) via Provider.
///
/// Register once (e.g. in main.dart):
///   ChangeNotifierProvider(create: (_) => NavigationActionsController())
///
/// Use anywhere:
///   final actions = context.read<NavigationActionsController>();
///   actions.onAspireTap(context);
///
/// For loading spinners, watch it instead:
///   final actions = context.watch<NavigationActionsController>();
///   isLoading: actions.aspireLoading
/// ============================================================

class NavigationActionsController extends ChangeNotifier {
  NavigationActionsController({
    UserHomeService? userHomeService,
    SessionController? sessionController,
  }) : _userHomeService = userHomeService ?? UserHomeService(),
       _sessionController = sessionController ?? SessionController();

  final UserHomeService _userHomeService;
  final SessionController _sessionController;

  bool _aspireLoading = false;
  bool _forecastLoading = false;

  bool get aspireLoading => _aspireLoading;
  bool get forecastLoading => _forecastLoading;
  bool get isAnyLoading => _aspireLoading || _forecastLoading;

  void _setAspireLoading(bool value) {
    _aspireLoading = value;
    notifyListeners();
  }

  void _setForecastLoading(bool value) {
    _forecastLoading = value;
    notifyListeners();
  }

  void _closeDrawerIfOpen(BuildContext context) {
    final scaffold = Scaffold.maybeOf(context);
    if (scaffold != null) {
      if (scaffold.isDrawerOpen) {
        scaffold.closeDrawer();
      } else if (scaffold.isEndDrawerOpen) {
        scaffold.closeEndDrawer();
      }
    }
  }

  /// Same logic as the old `_onAspireTap` in HomeScreen.
  Future<void> onAspireTap(BuildContext context) async {
    if (_aspireLoading) return;
    _setAspireLoading(true);
    try {
      final result = await _userHomeService.getUserEmotions(context: context);
      final hasData =
          result != null &&
          result.data != null &&
          result.data!.isNotEmpty &&
          ((result.data!.first.coreEmotions?.isNotEmpty ?? false) ||
              (result.data!.first.aspirationEmotions?.isNotEmpty ?? false));

      if (!context.mounted) return;

      _closeDrawerIfOpen(context);

      if (hasData) {
        Navigator.pushNamed(context, RoutesName.selectedEmotionsScreen);
      } else {
        Navigator.pushNamed(
          context,
          RoutesName.coreEmotions,
          arguments: {'isFromHome': true},
        );
      }
    } finally {
      _setAspireLoading(false);
    }
  }

  /// Same logic as the old `_onForecastTap` in HomeScreen.
  Future<void> onForecastTap(BuildContext context) async {
    if (_forecastLoading) return;
    _setForecastLoading(true);

    try {
      final forecastResult = await _userHomeService.getForecast(
        context: context,
      );
      final endDayResult = await _userHomeService.getEndDay(context: context);

      if (!context.mounted) return;

      final forecastData = (forecastResult?.data?.isNotEmpty ?? false)
          ? forecastResult!.data!.first
          : null;
      final forecast = forecastData?.forecast;

      final hasForecast =
          forecast != null &&
          ((forecast.emotions?.isNotEmpty ?? false) ||
              (forecast.plan?.isNotEmpty ?? false));

      final endDayData = (endDayResult?.data?.isNotEmpty ?? false)
          ? endDayResult!.data!.first
          : null;
      final endDay = endDayData?.endDay;

      final hasEndDay =
          endDay != null && ((endDay.emotions?.isNotEmpty ?? false));

      _closeDrawerIfOpen(context);

      if (hasEndDay) {
        Navigator.pushNamed(
          context,
          RoutesName.endDayComparisonScreen,
        );
        return;
      } else if (hasForecast) {
        Navigator.pushNamed(
          context,
          RoutesName.forecastResultScreen,
          arguments: forecastData,
        );
        return;
      } else {
        Navigator.pushNamed(
          context,
          RoutesName.startForecastScreen,
          arguments: {'isFromHome': true},
        );
      }
    } catch (e) {
      debugPrint("Forecast tap error: $e");
    } finally {
      _setForecastLoading(false);
    }
  }

  /// Same logic as the old `_onActivitiesTap` in HomeScreen.
  void onActivitiesTap(BuildContext context) {
    Navigator.pushNamed(context, RoutesName.activitiesScreen);
  }

  /// Same logic as the old `_onAnalyticsTap` in HomeScreen.
  void onAnalyticsTap(BuildContext context) {
    Navigator.pushNamed(context, RoutesName.analyticsScreen);
  }

  /// Same logic as the old `_onCommunityTap` in HomeScreen.
  void onCommunityTap(BuildContext context) {
    if (_sessionController.communityId == null ||
        _sessionController.communityId!.trim().isEmpty) {
      Navigator.pushNamed(context, RoutesName.emptyCommunity);
    } else {
      Navigator.pushNamed(context, RoutesName.myCommunity);
    }
  }
}
