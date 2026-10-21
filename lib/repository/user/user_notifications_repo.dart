import 'package:flutter/material.dart';
import 'package:kena_emotional_journey/app/network/base_api_services.dart';
import 'package:kena_emotional_journey/app/network/network_api_services.dart';
import 'package:kena_emotional_journey/app/utils/app_url.dart';

class UserNotificationsRepository {
  final BaseApiServices api = NetworkApiService();

  //sendToken
  Future<Map<String, dynamic>> sendToken({
    required String userId,
    required String token,
    double? userLat,
    double? userLng,
  }) async {
    final data = {
      'userId': userId,
      'token': token,
      // Only add these keys if BOTH are not null
      if (userLat != null && userLng != null) ...{
        'userLat': userLat,
        'userLng': userLng,
      },
    };

    debugPrint('😀😀😀😀😀😀');
    debugPrint('DATA FOR TOKEN: $data');
    debugPrint('😀😀😀😀😀😀');

    return api.post(url: AppUrl.saveTokenUser, data: data);
  }

  //registerFcmToken (thought-monitoring push notifications prerequisite)
  Future<Map<String, dynamic>> registerFcmToken({required String token}) async {
    return api.post(
      url: AppUrl.registerFcmToken,
      data: {'token': token},
    );
  }

  //getNotificationSettings
  Future<Map<String, dynamic>> getSettings() async {
    return api.get(url: AppUrl.notificationSettings);
  }

  //updateNotificationSettings
  Future<Map<String, dynamic>> updateSettings({
    required bool notificationsEnabled,
  }) async {
    return api.patch(
      url: AppUrl.notificationSettings,
      data: {'notificationsEnabled': notificationsEnabled},
    );
  }

  //getAutoDeleteSetting
  Future<Map<String, dynamic>> getAutoDelete() async {
    return api.get(url: AppUrl.notificationAutoDelete);
  }

  //updateAutoDeleteSetting
  Future<Map<String, dynamic>> updateAutoDelete({
    required bool autoDeleteNotifications,
  }) async {
    return api.post(
      url: AppUrl.notificationAutoDelete,
      data: {'autoDeleteNotifications': autoDeleteNotifications},
    );
  }

  //getReminderTimes
  Future<Map<String, dynamic>> getReminderTimes() async {
    return api.get(url: AppUrl.reminderSet);
  }

  //updateReminderTimes (times are 12h "h:mm AM")
  Future<Map<String, dynamic>> updateReminderTimes({
    required String dailyPulseTime,
    required String eodTime,
    required int timezoneOffsetMinutes,
  }) async {
    return api.put(
      url: AppUrl.reminderSet,
      data: {
        'dailyPulseTime': dailyPulseTime,
        'eodTime': eodTime,
        'timezoneOffsetMinutes': timezoneOffsetMinutes,
      },
    );
  }

  //sendNotification
  Future<Map<String, dynamic>> sendNotification({
    required String receiverId, //to which receiver notification is sent
    required String title,
    required String message,
  }) async {
    return api.post(
      url: AppUrl.pushNotificationUser,
      data: {'title': title, 'message': message, 'receiverId': receiverId},
    );
  }
}
