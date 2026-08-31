import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:kena_emotional_journey/app/routes/notification_route_resolver.dart';
import 'package:kena_emotional_journey/app/routes/routes_name.dart';
import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';
import 'package:kena_emotional_journey/app/utils/extensions/flush_bar_extension.dart';
import 'package:kena_emotional_journey/generated/assets/assets.gen.dart';
import 'package:kena_emotional_journey/provider/navigation_actions_provider.dart';
import 'package:kena_emotional_journey/services/common/session_manager/session_controller.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

class NotificationStyleConfig {
  final Widget icon;
  final Color accentColor;
  final String badgeLabel;
  final String route;

  const NotificationStyleConfig({
    required this.icon,
    required this.accentColor,
    required this.badgeLabel,
    required this.route,
  });
}

class NotificationsChip extends StatefulWidget {
  final String? imageUrl;
  final String title;
  final String description;
  final String? type;
  final String? createdAt;
  final String? notificationId;
  final bool initiallySubmitted;
  final Future<bool> Function(String option)? onOptionSelected;

  const NotificationsChip({
    super.key,
    this.imageUrl,
    required this.title,
    required this.description,
    this.type,
    this.createdAt,
    this.notificationId,
    this.initiallySubmitted = false,
    this.onOptionSelected,
  });

  @override
  State<NotificationsChip> createState() => _NotificationsChipState();
}

class _NotificationsChipState extends State<NotificationsChip> {
  bool _isSubmitting = false;
  bool _isCheckingForecast = false;
  late bool _isSubmitted = widget.initiallySubmitted;
  // bool isQuickCheckIn = false;

  Future<void> _selectOption(String mood) async {
    // isQuickCheckIn = false;
    if (_isSubmitting || _isSubmitted) return;
    setState(() => _isSubmitting = true);

    final success = await widget.onOptionSelected?.call(mood) ?? false;

    if (!mounted) return;
    setState(() {
      _isSubmitting = false;
      _isSubmitted = success;
    });
  }

  String _formatTime(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final dt = DateTime.parse(dateStr).toLocal();
      final now = DateTime.now();
      if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
        return DateFormat('h:mm').format(dt);
      }
      return DateFormat('MMM d, h:mm').format(dt);
    } catch (_) {
      return '';
    }
  }

  NotificationStyleConfig _getStyleConfig(BuildContext context) {
    final primaryColor = context.colors.primary;
    final bellIcon = Assets.icons.bell.svg(height: 18.w, width: 18.w);
    final route = NotificationRouteResolver.routeForType(
      widget.type,
      communityId: SessionController().communityId,
    );

    final String badgeLabel;
    switch (widget.type) {
      case 'reassessment_reminder':
        badgeLabel = 'Reminder';
        break;
      case 'morning_forecast':
        badgeLabel = 'Forecast';
        break;
      case 'evening_reflection':
        badgeLabel = 'Reflection';
        break;
      case 'midday_checkin':
        badgeLabel = 'Check-in';
        break;
      case 'thought_check_in':
        badgeLabel = 'Thoughts';
        break;
      case 'weekly_summary':
        badgeLabel = 'Summary';
        break;
      case 'daily_pulse_nudge':
        badgeLabel = 'Daily Pulse';
        break;
      case 'core_emotions_nudge':
        badgeLabel = 'Core';
        break;
      case 'aspire_nudge':
        badgeLabel = 'Aspire';
        break;
      case 'community_invite_received':
        badgeLabel = 'Circle Invite';
        break;
      case 'community_invite_accepted':
        badgeLabel = 'Invite Accepted';
        break;
      case 'community_like':
        badgeLabel = 'Like';
        break;
      case 'community_comment':
        badgeLabel = 'Comment';
        break;
      case 'share_comment':
        badgeLabel = 'Share Comment';
        break;
      default:
        badgeLabel = 'Notification';
    }

    return NotificationStyleConfig(
      icon: bellIcon,
      accentColor: primaryColor,
      badgeLabel: badgeLabel,
      route: route,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool hasImage =
        widget.imageUrl != null && widget.imageUrl!.isNotEmpty;
    final config = _getStyleConfig(context);
    final String timeText = _formatTime(widget.createdAt);
    final bool isQuickCheckIn =
        widget.type == 'thought_check_in' ||
        widget.description.toLowerCase().contains('thought');
    final actions = context.watch<NavigationActionsController>();
    final bool isForecastLoading =
        widget.type == 'morning_forecast' && actions.forecastLoading;
    final bool endDayReflectionLoading =
        widget.type == 'evening_reflection' && actions.endDayReflectionLoading;
    final bool isForecastCheckLoading =
        (widget.type == 'midday_checkin' ||
            widget.type == 'daily_pulse_nudge') &&
        _isCheckingForecast;

    return GestureDetector(
      onTap: () async {
        if (widget.type == 'morning_forecast') {
          if (isForecastLoading) return;
          actions.onForecastTap(context);
        } else if (widget.type == 'evening_reflection') {
          if (endDayReflectionLoading) return;
          actions.onEndDayReflectionTap(context);
        } else if (widget.type == 'midday_checkin') {
          if (_isCheckingForecast) return;
          setState(() => _isCheckingForecast = true);
          final hasForecast = await actions.hasForecast(context);
          if (!mounted) return;
          setState(() => _isCheckingForecast = false);
          if (!context.mounted) return;
          if (hasForecast) {
            Navigator.pushNamed(context, RoutesName.forecastResultScreen);
          } else {
            context.flushBarErrorMessage(
              message: "You haven't completed your forecast yet",
            );
          }
        } else if (widget.type == 'daily_pulse_nudge') {
          if (_isCheckingForecast) return;
          setState(() => _isCheckingForecast = true);
          final hasForecast = await actions.hasForecast(context);
          if (!mounted) return;
          setState(() => _isCheckingForecast = false);
          if (!context.mounted) return;
          if (hasForecast) {
            Navigator.pushNamed(context, RoutesName.forecastResultScreen);
          } else {
            Navigator.pushNamed(
              context,
              RoutesName.forecastScreen,
              arguments: {'isFromHome': true},
            );
          }
        } else {
          Navigator.pushNamed(context, config.route);
        }
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 Avatar or Type Icon
          Stack(
            children: [
              CircleAvatar(
                radius: 22.r,
                backgroundColor: config.accentColor.withValues(alpha: 0.2),
                child: CircleAvatar(
                  radius: 20.r,
                  backgroundColor: config.accentColor,
                  backgroundImage: hasImage
                      ? NetworkImage(widget.imageUrl!)
                      : null,
                  onBackgroundImageError: hasImage ? (_, _) {} : null,
                  child: hasImage
                      ? null
                      : (isForecastLoading ||
                            endDayReflectionLoading ||
                            isForecastCheckLoading)
                      ? SizedBox(
                          width: 16.w,
                          height: 16.w,
                          child: LoadingAnimationWidget.staggeredDotsWave(
                            color: Colors.white,
                            size: 16.w,
                          ),
                        )
                      : config.icon,
                ),
              ),
              if (hasImage)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: EdgeInsets.all(2.r),
                    decoration: BoxDecoration(
                      color: config.accentColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: SizedBox(
                      width: 10.w,
                      height: 10.w,
                      child: FittedBox(child: config.icon),
                    ),
                  ),
                ),
            ],
          ),

          SizedBox(width: 12.w),

          // 🔹 Text & Actions Section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Time Row
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.typography.title.copyWith(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'sfpro',
                          color: context.colors.textPrimary,
                        ),
                      ),
                    ),
                    if (timeText.isNotEmpty) ...[
                      SizedBox(width: 6.w),
                      Text(
                        timeText,
                        style: context.typography.label.copyWith(
                          fontSize: 12.sp,
                          fontFamily: 'sfpro',
                          color: context.colors.textSecondary.withValues(
                            alpha: 0.6,
                          ),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ],
                ),

                SizedBox(height: 4.h),

                // Description
                Text(
                  isQuickCheckIn
                      ? 'What kind of thought are you having right now?'
                      : widget.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.typography.label.copyWith(
                    fontSize: 11.sp,
                    fontFamily: 'sfpro',
                    color: context.colors.textSecondary.withValues(alpha: 0.8),
                  ),
                ),

                // 🔹 Quick Check-in Options (Positive, Negative, Neutral)
                if (isQuickCheckIn && !_isSubmitted) ...[
                  if (_isSubmitting)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      child: Center(
                        child: LoadingAnimationWidget.staggeredDotsWave(
                          color: context.colors.primary,
                          size: 20.w,
                        ),
                      ),
                    )
                  else ...[
                    SizedBox(height: 12.h),
                    Row(
                      children: [
                        // Positive Option
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _selectOption('positive'),
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 6.h),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: context.colors.primary,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Text(
                                'Positive',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),

                        // Negative Option
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _selectOption('negative'),
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 4.h),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(8.r),
                                border: Border.all(
                                  color: Colors.red,
                                  width: 1.2.w,
                                ),
                              ),
                              child: Text(
                                'Negative',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),

                        // Neutral Option
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _selectOption('neutral'),
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 4.h),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(8.r),
                                border: Border.all(
                                  color: context.colors.primary,
                                  width: 1.2.w,
                                ),
                              ),
                              child: Text(
                                'Neutral',
                                style: TextStyle(
                                  color: context.colors.primary,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
