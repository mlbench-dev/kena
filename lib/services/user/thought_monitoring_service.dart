import 'package:flutter/material.dart';
import 'package:kena_emotional_journey/app/utils/service_error_handler.dart';
import 'package:kena_emotional_journey/model/thought_monitoring/thought_monitoring_settings_model.dart';
import 'package:kena_emotional_journey/model/thought_monitoring/today_check_ins_model.dart';
import 'package:kena_emotional_journey/repository/thought_monitoring_repository.dart';

class ThoughtMonitoringService {
  ThoughtMonitoringService({ThoughtMonitoringRepository? repository})
    : _repository = repository ?? ThoughtMonitoringRepository();

  final ThoughtMonitoringRepository _repository;

  static const String _tag = 'ThoughtMonitoringService';

  /// Fetch the current thought monitoring settings from the server.
  ///
  /// Returns `null` on failure (fails silently — used to prefill UI).
  Future<ThoughtMonitoringSettingsData?> getSettings({
    required BuildContext context,
  }) async {
    try {
      final response = await _repository.getSettings();
      final model = ThoughtMonitoringSettingsModel.fromJson(response);
      return model.data?.first;
    } catch (e) {
      debugPrint('[$_tag] ⚠️ getSettings failed silently: $e');
      return null;
    }
  }

  /// Save thought monitoring settings to the server.
  ///
  /// [enabled]   – whether the user has opted in.
  /// [startTime] – 24-hour "HH:mm", required when [enabled] is true.
  /// [endTime]   – 24-hour "HH:mm", required when [enabled] is true.
  Future<bool> saveSettings({
    required BuildContext context,
    required bool enabled,
    String? startTime,
    String? endTime,
  }) async {
    try {
      final data = {
        'enabled': enabled,
        if (startTime != null) 'startTime': startTime,
        if (endTime != null) 'endTime': endTime,
        'timezoneOffsetMinutes': DateTime.now().timeZoneOffset.inMinutes,
      };

      final response = await _repository.saveSettings(data: data);

      if (response['success'] == true) {
        return true;
      } else {
        if (context.mounted) {
          ErrorHandler.handle(
            context,
            response['message'] ?? 'Failed to save thought monitoring settings',
            serviceName: _tag,
          );
        }
        return false;
      }
    } catch (error) {
      if (context.mounted) {
        ErrorHandler.handle(context, error, serviceName: _tag);
      }
      return false;
    }
  }

  /// Submit the mood selected for a thought check-in prompt.
  ///
  /// [notificationId] – optional, from the push payload; marks that
  /// notification read when provided.
  /// [mood] – one of "positive" | "negative" | "neutral".
  Future<bool> submitCheckIn({
    required BuildContext context,
    String? notificationId,
    required String mood,
  }) async {
    try {
      final data = {
        if (notificationId != null) 'notificationId': notificationId,
        'mood': mood,
      };

      final response = await _repository.checkIn(data: data);

      if (response['success'] == true) {
        return true;
      } else {
        if (context.mounted) {
          ErrorHandler.handle(
            context,
            response['message'] ?? 'Failed to submit check-in',
            serviceName: _tag,
          );
        }
        return false;
      }
    } catch (error) {
      if (context.mounted) {
        ErrorHandler.handle(context, error, serviceName: _tag);
      }
      return false;
    }
  }

  /// Fetch today's recorded check-ins.
  ///
  /// Returns `null` on failure (fails silently).
  Future<TodayCheckInsData?> getTodayCheckIns({
    required BuildContext context,
  }) async {
    try {
      final response = await _repository.getTodayCheckIns();
      final model = TodayCheckInsModel.fromJson(response);
      return model.data?.first;
    } catch (e) {
      debugPrint('[$_tag] ⚠️ getTodayCheckIns failed silently: $e');
      return null;
    }
  }
}
