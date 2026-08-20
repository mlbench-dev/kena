import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:kena_emotional_journey/app/components/banner_ads_widget.dart';
import 'package:kena_emotional_journey/app/components/my_scaffold.dart';
import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';
import 'package:kena_emotional_journey/app/utils/extensions/flush_bar_extension.dart';
import 'package:kena_emotional_journey/app/utils/local_storage.dart';
import 'package:kena_emotional_journey/generated/assets/assets.gen.dart';
import 'package:kena_emotional_journey/model/notifications/notification_model.dart';
import 'package:kena_emotional_journey/provider/user_home_provider.dart';
import 'package:kena_emotional_journey/services/common/notifications_service.dart';
import 'package:kena_emotional_journey/services/user/thought_monitoring_service.dart';
import 'package:kena_emotional_journey/services/user/user_home_service.dart';
import 'package:kena_emotional_journey/view/notifications/empty_notifications.dart';
import 'package:kena_emotional_journey/view/notifications/notification_permission_screen.dart';
import 'package:kena_emotional_journey/view/notifications/widgets/notifications_chip.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _notificationsService = NotificationsService();
  final _thoughtMonitoringService = ThoughtMonitoringService();
  final _localStorage = LocalStorage();
  final UserHomeService _service = UserHomeService();
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;

  static const String _answeredCheckInsKey = 'thought_check_in_answered_ids';
  static const int _pageSize = 20;

  bool _hasPermission = true;
  bool _checkingPermission = true;
  bool _hasNavigatedToPermissionScreen = false;
  Set<String> _answeredCheckInIds = {};

  final _scrollController = ScrollController();
  final List<NotificationItem> _notifications = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _checkNotificationPermission();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_hasMore || _isLoadingMore || _isLoading) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreNotifications();
    }
  }

  Future<void> _loadAnsweredCheckInIds() async {
    final raw = await _localStorage.readValue(_answeredCheckInsKey);
    if (raw == null || raw.isEmpty) return;
    try {
      _answeredCheckInIds = (jsonDecode(raw) as List).cast<String>().toSet();
    } catch (_) {
      // Ignore corrupt/legacy cached value
    }
  }

  Future<void> _markCheckInAnswered(String notificationId) async {
    _answeredCheckInIds.add(notificationId);
    await _localStorage.setValue(
      _answeredCheckInsKey,
      jsonEncode(_answeredCheckInIds.toList()),
    );
  }

  Future<void> _fetchInitialNotifications() async {
    await _loadAnsweredCheckInIds();
    final notifications = await _notificationsService.getNotifications(
      context: context,
      limit: _pageSize,
      offset: 0,
    );
    if (!mounted) return;
    setState(() {
      _notifications
        ..clear()
        ..addAll(notifications);
      _hasMore = notifications.length == _pageSize;
      _isLoading = false;
    });
    await _notificationsService.markNotificationsRead(context: context);
    if (!mounted) return;
    context.read<UserHomeProvider>().resetUnreadNotificationCount();
  }

  Future<void> _loadMoreNotifications() async {
    setState(() => _isLoadingMore = true);
    final notifications = await _notificationsService.getNotifications(
      context: context,
      limit: _pageSize,
      offset: _notifications.length,
    );
    if (!mounted) return;
    setState(() {
      _notifications.addAll(notifications);
      _hasMore = notifications.length == _pageSize;
      _isLoadingMore = false;
    });
  }

  Future<void> _checkNotificationPermission() async {
    NotificationSettings settings = await _firebaseMessaging
        .getNotificationSettings();

    if (!mounted) return;

    final allowed =
        settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;

    if (allowed) {
      setState(() {
        _hasPermission = true;
        _checkingPermission = false;
      });
      _fetchInitialNotifications();
    } else {
      setState(() {
        _hasPermission = false;
        _checkingPermission = false;
      });
    }
  }

  Future<bool> _submitCheckIn(String? notificationId, String mood) async {
    final success = await _thoughtMonitoringService.submitCheckIn(
      context: context,
      notificationId: notificationId,
      mood: mood,
    );
    if (!mounted) return success;
    if (success) {
      context.flushBarSuccessMessage(message: 'Check-in recorded');
      if (notificationId != null) {
        await _markCheckInAnswered(notificationId);
      }
    }
    return success;
  }

  Future<void> deleteNotification(String? notificationId) async {
    if (notificationId == null) return;
    final success = await _service.deleteNotification(
      notificationId: notificationId,
      context: context,
    );
    if (!mounted) return;
    if (success) {
      setState(() {
        _notifications.removeWhere((n) => n.id == notificationId);
      });
      if (context.mounted) {
        context.flushBarSuccessMessage(
          message: "Your notification deleted sucessfully",
        );
      }
    }
  }

  Future<void> _handlePermissionResult() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NotificationPermissionScreen()),
    );

    if (result == true) {
      _checkNotificationPermission();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checkingPermission) {
      return Scaffold(
        body: Center(
          child: LoadingAnimationWidget.staggeredDotsWave(
            color: context.colors.primary,
            size: 25,
          ),
        ),
      );
    }

    if (!_hasPermission) {
      if (!_hasNavigatedToPermissionScreen) {
        _hasNavigatedToPermissionScreen = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _handlePermissionResult();
        });
      }
      return Scaffold(
        body: Center(
          child: LoadingAnimationWidget.staggeredDotsWave(
            color: context.colors.primary,
            size: 25,
          ),
        ),
      );
    }

    return MyScaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        leading: BackButton(color: context.colors.textPrimary),
        centerTitle: true,
        title: Text(
          'Notifications',
          style: context.typography.title.copyWith(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Builder(
          builder: (context) {
            // ── SHIMMER LOADING ──────────────────────────────────
            if (_isLoading) {
              return const _NotificationsShimmer();
            }

            // ── EMPTY ─────────────────────────────────────────────
            if (_notifications.isEmpty) {
              return const EmptyNotificationsScreen();
            }

            // ── DATA ──────────────────────────────────────────────
            return Column(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: context.colors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: ListView.separated(
                      controller: _scrollController,
                      itemCount:
                          _notifications.length + (_isLoadingMore ? 1 : 0),
                      separatorBuilder: (context, index) => Column(
                        children: [
                          SizedBox(height: 12.h),
                          Container(
                            height: 1.5.h,
                            decoration: BoxDecoration(
                              color: context.colors.textSecondary.withValues(
                                alpha: 0.3,
                              ),
                            ),
                          ),
                          SizedBox(height: 5.h),
                        ],
                      ),
                      itemBuilder: (context, index) {
                        if (index >= _notifications.length) {
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            child: Center(
                              child: LoadingAnimationWidget.staggeredDotsWave(
                                color: context.colors.primary,
                                size: 32.w,
                              ),
                            ),
                          );
                        }
                        final notification = _notifications[index];
                        return Slidable(
                          key: ValueKey(notification.id),
                          endActionPane: ActionPane(
                            motion: const DrawerMotion(),
                            extentRatio: 0.22,
                            children: [
                              CustomSlidableAction(
                                onPressed: (_) =>
                                    deleteNotification(notification.id),
                                backgroundColor: Colors
                                    .transparent, // no white pane behind it
                                foregroundColor: context.colors.background,
                                padding: EdgeInsets.zero,
                                child: Container(
                                  width: 50.w,
                                  height: 30
                                      .w, // same as width, so it's a true circle
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Assets.icons.trashBin.svg(
                                    color: context.colors.background,
                                    width: 25,
                                    height: 25,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          // endActionPane: ActionPane(
                          //   motion: const DrawerMotion(),
                          //   extentRatio: 0.22,
                          //   children: [
                          //     CustomSlidableAction(
                          //       onPressed: (_) {
                          //         context.flushBarSuccessMessage(
                          //           message:
                          //               "Your notification deleted sucessfully",
                          //         );
                          //       },
                          //       backgroundColor: Colors
                          //           .transparent, // no white pane behind it
                          //       foregroundColor: context.colors.background,
                          //       padding: EdgeInsets.zero,
                          //       child: Container(
                          //         width: 50.w,
                          //         height: 30
                          //             .w, // same as width, so it's a true circle
                          //         alignment: Alignment.center,
                          //         decoration: BoxDecoration(
                          //           color: context.colors.primary,
                          //           borderRadius: BorderRadius.circular(16),
                          //         ),
                          //         child: Icon(Icons.done_all, size: 22),
                          //       ),
                          //     ),
                          //   ],
                          // ),
                          child: NotificationsChip(
                            imageUrl: notification.actor?.avatarUrl,
                            title: notification.title ?? '',
                            description: notification.body ?? '',
                            type: notification.type,
                            createdAt: notification.createdAt,
                            notificationId: notification.id,
                            initiallySubmitted: _answeredCheckInIds.contains(
                              notification.id,
                            ),
                            onOptionSelected: (mood) =>
                                _submitCheckIn(notification.id, mood),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const BannerAdWidget(),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ── Shimmer Skeleton ──────────────────────────────────────────────────────────

class _NotificationsShimmer extends StatelessWidget {
  const _NotificationsShimmer();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: ListView.builder(
        itemCount: 6,
        itemBuilder: (_, _) => const _NotificationShimmerItem(),
      ),
    );
  }
}

class _NotificationShimmerItem extends StatelessWidget {
  const _NotificationShimmerItem();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar circle
          Container(
            width: 48.w,
            height: 48.w,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 12.w),
          // Text lines
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 4.h),
                // Title line
                Container(
                  height: 14.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                ),
                SizedBox(height: 8.h),
                // Description line 1
                Container(
                  height: 12.h,
                  width: 220.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                ),
                SizedBox(height: 6.h),
                // Description line 2 (shorter)
                Container(
                  height: 12.h,
                  width: 140.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
