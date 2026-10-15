import 'package:flutter/material.dart';
import 'package:kena_emotional_journey/app/components/no_internet_dialog.dart';
import 'package:kena_emotional_journey/app/routes/routes_name.dart';
import 'package:kena_emotional_journey/app/utils/extensions/flush_bar_extension.dart';
import 'package:kena_emotional_journey/model/forecast/forecast_model.dart';
import 'package:kena_emotional_journey/services/common/session_manager/session_controller.dart';
import 'package:kena_emotional_journey/services/user/user_home_service.dart';

/// Central place for the home screen's navigation actions (Aspire, Forecast,
/// Activities, Analytics, Community) so any widget can trigger them via
/// `context.read<NavigationActionsController>()`.
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
  bool _endDayReflectionLoading = false;

  bool get aspireLoading => _aspireLoading;
  bool get forecastLoading => _forecastLoading;
  bool get endDayReflectionLoading => _endDayReflectionLoading;
  bool get isAnyLoading => _aspireLoading || _forecastLoading;

  void _setAspireLoading(bool value) {
    _aspireLoading = value;
    notifyListeners();
  }

  void _setForecastLoading(bool value) {
    _forecastLoading = value;
    notifyListeners();
  }

  void _setEndDayReflectionLoading(bool value) {
    _endDayReflectionLoading = value;
    notifyListeners();
  }

  /// Shows a "no internet" dialog and returns `false` when offline, so
  /// callers can bail out before hitting the network.
  Future<bool> _requireConnection(BuildContext context) =>
      NoInternetDialog.guard(context);

  /// Fetches today's forecast and reports whether the user completed it.
  Future<bool> hasForecast(BuildContext context) async {
    final forecastResult = await _userHomeService.getForecast(context: context);
    return _forecastHasContent(forecastResult);
  }

  bool _forecastHasContent(ForecastModel? forecastResult) {
    final forecastData = (forecastResult?.data?.isNotEmpty ?? false)
        ? forecastResult!.data!.first
        : null;
    final forecast = forecastData?.forecast;
    return forecast != null &&
        ((forecast.emotions?.isNotEmpty ?? false) ||
            (forecast.plan?.isNotEmpty ?? false));
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

  Future<void> onAspireTap(BuildContext context) async {
    if (_aspireLoading) return;
    if (!await _requireConnection(context)) return;
    if (!context.mounted) return;
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

  Future<void> onForecastTap(BuildContext context) async {
    if (_forecastLoading) return;
    if (!await _requireConnection(context)) return;
    if (!context.mounted) return;
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
      final hasForecast = _forecastHasContent(forecastResult);

      final endDayData = (endDayResult?.data?.isNotEmpty ?? false)
          ? endDayResult!.data!.first
          : null;
      final endDay = endDayData?.endDay;
      final hasEndDay =
          endDay != null && ((endDay.emotions?.isNotEmpty ?? false));

      _closeDrawerIfOpen(context);

      if (hasEndDay) {
        Navigator.pushNamed(context, RoutesName.endDayComparisonScreen);
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

  Future<void> onEndDayReflectionTap(BuildContext context) async {
    if (_endDayReflectionLoading) return;

    _setEndDayReflectionLoading(true);
    try {
      final hasForecastData = await hasForecast(context);

      if (!context.mounted) return;

      if (!hasForecastData) {
        context.flushBarErrorMessage(
          message: 'Please complete your forecast first',
        );
        return;
      }

      final comparisonResult = await _userHomeService.getComparison(
        context: context,
      );
      final comparisonData = comparisonResult?.data;
      final hasRealityData =
          comparisonData != null &&
          comparisonData.isNotEmpty &&
          (comparisonData.first.reality?.emotions?.isNotEmpty ?? false);

      if (!context.mounted) return;

      if (hasRealityData) {
        Navigator.pushNamed(context, RoutesName.endDayComparisonScreen);
      } else {
        Navigator.pushNamed(
          context,
          RoutesName.endDayReflection,
          arguments: {'isFromHome': true},
        );
      }
    } catch (e) {
      debugPrint('Error loading end-of-day comparison: $e');
    } finally {
      _setEndDayReflectionLoading(false);
    }
  }

  Future<void> onActivitiesTap(BuildContext context) async {
    if (!await _requireConnection(context)) return;
    if (!context.mounted) return;
    Navigator.pushNamed(context, RoutesName.activitiesScreen);
  }

  Future<void> onAnalyticsTap(BuildContext context) async {
    if (!await _requireConnection(context)) return;
    if (!context.mounted) return;
    Navigator.pushNamed(context, RoutesName.analyticsScreen);
  }

  Future<void> onCommunityTap(BuildContext context) async {
    if (!await _requireConnection(context)) return;
    if (!context.mounted) return;
    if (_sessionController.communityId == null ||
        _sessionController.communityId!.trim().isEmpty) {
      Navigator.pushNamed(context, RoutesName.emptyCommunity);
    } else {
      Navigator.pushNamed(context, RoutesName.myCommunity);
    }
  }
}
