import 'package:flutter/material.dart';
import 'package:kena_emotional_journey/app/routes/routes_name.dart';
import 'package:kena_emotional_journey/app/view/app.dart';
import 'package:kena_emotional_journey/services/user/user_home_service.dart';
import 'package:kena_emotional_journey/view/community/comments_screen.dart';

/// Single source of truth for mapping a notification's `type` to the route
/// it should open. Used by both the in-app notifications list
/// (NotificationsChip) and the FCM tap handler (PushNotificationsService) so
/// the two stay in sync.
class NotificationRouteResolver {
  NotificationRouteResolver._();

  /// Whether this notification carries enough payload data to deep-link
  /// straight into the circle feed for the entry it refers to, instead of
  /// falling back to the plain route from [routeForType].
  static bool hasFeedTarget(
    String? type, {
    String? entryOwnerId,
    String? communityId,
  }) {
    return (type == 'community_comment' || type == 'community_like') &&
        (entryOwnerId?.trim().isNotEmpty ?? false) &&
        (communityId?.trim().isNotEmpty ?? false);
  }

  /// Navigates to the circle feed for the entry the notification refers to.
  /// For `community_comment` this also opens that entry's comment sheet; for
  /// `community_like` it just lands on the feed — a like has no comment
  /// thread to jump into. Only call when [hasFeedTarget] is true.
  static Future<void> openFeedTarget(
    BuildContext context, {
    required String? type,
    required String entryOwnerId,
    required String communityId,
  }) async {
    final detail = await UserHomeService().getUserCommunityDetails(
      communityId: communityId,
      context: context,
    );
    final communityName = (detail?.data?.isNotEmpty ?? false)
        ? (detail!.data!.first.community?.name ?? '')
        : '';

    final navigator = App.navigatorKey.currentState;
    if (navigator == null) return;

    navigator.pushNamed(
      RoutesName.feedScreen,
      arguments: {'communityId': communityId, 'communityName': communityName},
    );

    if (type != 'community_comment') return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final sheetContext = App.navigatorKey.currentContext;
      if (sheetContext == null) return;
      CommentBottomSheet.show(
        sheetContext,
        entryOwnerId: entryOwnerId,
        communityId: communityId,
      );
    });
  }

  static String routeForType(String? type, {String? communityId}) {
    final hasCommunity = communityId?.trim().isNotEmpty == true;

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
        return hasCommunity
            ? RoutesName.myCommunity
            : RoutesName.emptyCommunity;
      case 'community_like':
      case 'community_comment':
        // Preferred path is openFeedTarget() (see hasFeedTarget), which
        // deep-links straight into the entry's feed (and its comment
        // thread, for community_comment). This is only the fallback when
        // the payload lacks entryOwnerId.
        return RoutesName.myCommunity;
      case 'share_comment':
        // share_comment has no feed-entry concept yet (it's keyed by
        // shareInviteToken for a shared-forecast view that doesn't exist
        // yet), so it always falls back to the community list for now.
        return RoutesName.myCommunity;
      default:
        return RoutesName.myCommunity;
    }
  }
}
