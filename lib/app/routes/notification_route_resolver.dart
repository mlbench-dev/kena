import 'package:kena_emotional_journey/app/routes/routes_name.dart';

/// Single source of truth for mapping a notification's `type` to the route
/// it should open. Used by both the in-app notifications list
/// (NotificationsChip) and the FCM tap handler (PushNotificationsService) so
/// the two stay in sync.
class NotificationRouteResolver {
  NotificationRouteResolver._();

  static String routeForType(String? type) {
    switch (type) {
      case 'reassessment_reminder':
        return RoutesName.selectedEmotionsScreen;
      case 'morning_forecast':
        return RoutesName.forecastScreen;
      case 'evening_reflection':
        return RoutesName.endDayReflection;
      case 'midday_checkin':
        return RoutesName.forecastScreen;
      case 'thought_check_in':
        return RoutesName.notificationsScreen;
      case 'weekly_summary':
        return RoutesName.analyticsScreen;
      case 'daily_pulse_nudge':
        return RoutesName.forecastScreen;
      case 'core_emotions_nudge':
        return RoutesName.coreEmotions;
      case 'aspire_nudge':
        return RoutesName.aspirationalEmotions;
      case 'community_invite_received':
      case 'community_invite_accepted':
        return RoutesName.myCommunity;
      case 'community_like':
      case 'community_comment':
      case 'share_comment':
        // These need a communityId/communityName (or post) that isn't
        // available from the notification payload, so send the user to
        // their communities list rather than a route that requires
        // arguments it doesn't have.
        return RoutesName.myCommunity;
      default:
        return RoutesName.myCommunity;
    }
  }
}
