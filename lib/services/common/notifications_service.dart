import 'package:flutter/material.dart';
import 'package:kena_emotional_journey/app/utils/service_error_handler.dart';
import 'package:kena_emotional_journey/model/notifications/notification_model.dart';
import 'package:kena_emotional_journey/repository/user/user_notifications_repo.dart';
import 'package:kena_emotional_journey/repository/user_home_repo.dart';

class NotificationsService {
  static const String tag = '[NotificationsService]';
  final UserHomeRepository _userHomeRepo = UserHomeRepository();
  final UserNotificationsRepository _userNotificationsRepo =
      UserNotificationsRepository();

  ///
  ///Get Notifications
  ///
  Future<List<NotificationItem>> getNotifications({
    required BuildContext context,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _userHomeRepo.getNotifications(
        limit: limit,
        offset: offset,
      );

      debugPrint("🔔 Notifications Response $response");

      final model = NotificationModel.fromJson(response);

      return model.data?.first.items ?? [];
    } catch (e) {
      // Silently fail for background polling — don't show flashbar to user
      debugPrint('[$tag] ⚠️ getNotifications failed silently: $e');
      return [];
    }
  }

  Future<int> getUnreadNotificationCount() async {
    try {
      final response = await _userHomeRepo.getNotifications();
      final model = NotificationModel.fromJson(response);
      return model.data?.first.unreadCount ?? 0;
    } catch (e) {
      // Silently fail for background polling — don't show flashbar to user
      debugPrint('[$tag] ⚠️ getUnreadNotificationCount failed silently: $e');
      return 0;
    }
  }

  /// Reads a boolean setting from the usual `data[0]` envelope, falling back
  /// to the top level of the response.
  bool? _readSettingFlag(Map<String, dynamic> response, String key) {
    final data = response['data'];
    final source = data is List && data.isNotEmpty && data[0] is Map
        ? data[0] as Map
        : response;
    return source[key] as bool?;
  }

  ///
  ///Get Notification Settings
  ///
  Future<bool?> getNotificationSettings({required BuildContext context}) async {
    try {
      final response = await _userNotificationsRepo.getSettings();
      return _readSettingFlag(response, 'notificationsEnabled');
    } catch (e) {
      // Fail silently — used to prefill UI toggle state
      debugPrint('[$tag] ⚠️ getNotificationSettings failed silently: $e');
      return null;
    }
  }

  ///
  ///Update Notification Settings
  ///
  Future<bool> updateNotificationSettings({
    required BuildContext context,
    required bool notificationsEnabled,
  }) async {
    try {
      await _userNotificationsRepo.updateSettings(
        notificationsEnabled: notificationsEnabled,
      );
      return true;
    } catch (e) {
      if (context.mounted) {
        ErrorHandler.handle(context, e, serviceName: tag);
      }
      return false;
    }
  }

  ///
  ///Get Auto Delete Setting
  ///
  Future<bool?> getAutoDeleteSetting({required BuildContext context}) async {
    try {
      final response = await _userNotificationsRepo.getAutoDelete();
      return _readSettingFlag(response, 'autoDeleteNotifications');
    } catch (e) {
      // Fail silently — used to prefill UI toggle state
      debugPrint('[$tag] ⚠️ getAutoDeleteSetting failed silently: $e');
      return null;
    }
  }

  ///
  ///Update Auto Delete Setting
  ///
  Future<bool> updateAutoDeleteSetting({
    required BuildContext context,
    required bool autoDeleteNotifications,
  }) async {
    try {
      await _userNotificationsRepo.updateAutoDelete(
        autoDeleteNotifications: autoDeleteNotifications,
      );
      return true;
    } catch (e) {
      if (context.mounted) {
        ErrorHandler.handle(context, e, serviceName: tag);
      }
      return false;
    }
  }

  /// Parses a 24h "HH:mm" string into a [TimeOfDay].
  TimeOfDay? _parseTime(Object? value) {
    if (value is! String) return null;
    final parts = value.split(':');
    if (parts.length < 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    return TimeOfDay(hour: hour, minute: minute);
  }

  ///
  ///Get Reminder Times
  ///
  /// Returns null when no times have been set yet or the request fails.
  Future<({TimeOfDay dailyPulseTime, TimeOfDay eodTime})?> getReminderTimes({
    required BuildContext context,
  }) async {
    try {
      final response = await _userNotificationsRepo.getReminderTimes();
      debugPrint("🔔 Get Reminder Times Response $response");
      final data = response['data'];
      final source = data is List && data.isNotEmpty && data[0] is Map
          ? data[0] as Map
          : response;
      final dailyPulseTime = _parseTime(source['dailyPulseTime']);
      final eodTime = _parseTime(source['eodTime']);
      if (dailyPulseTime == null || eodTime == null) return null;
      return (dailyPulseTime: dailyPulseTime, eodTime: eodTime);
    } catch (e) {
      // Fail silently — used to prefill the time pickers
      debugPrint('[$tag] ⚠️ getReminderTimes failed silently: $e');
      return null;
    }
  }

  ///
  ///Update Reminder Times
  ///
  Future<bool> updateReminderTimes({
    required BuildContext context,
    required TimeOfDay dailyPulseTime,
    required TimeOfDay eodTime,
  }) async {
    String format(TimeOfDay time) =>
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

    try {
      final response = await _userNotificationsRepo.updateReminderTimes(
        dailyPulseTime: format(dailyPulseTime),
        eodTime: format(eodTime),
      );
      debugPrint("🔔 Update Reminder Times Response $response");
      return true;
    } catch (e) {
      if (context.mounted) {
        ErrorHandler.handle(context, e, serviceName: tag);
      }
      return false;
    }
  }

  Future<bool> markNotificationsRead({required BuildContext context}) async {
    try {
      final response = await _userHomeRepo.markNotificationsRead();
      debugPrint("🔔 Mark Notifications Read Response $response");
      return response['success'] == true;
    } catch (e) {
      if (context.mounted) {
        ErrorHandler.handle(context, e, serviceName: tag);
      }
      return false;
    }
  }
}
