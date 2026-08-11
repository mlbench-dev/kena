import 'package:flutter/material.dart';
import 'package:kena_emotional_journey/app/utils/service_error_handler.dart';
import 'package:kena_emotional_journey/model/notifications/notification_model.dart';
import 'package:kena_emotional_journey/repository/user_home_repo.dart';

class NotificationsService {
  static const String tag = '[NotificationsService]';
  final UserHomeRepository _userHomeRepo = UserHomeRepository();

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
