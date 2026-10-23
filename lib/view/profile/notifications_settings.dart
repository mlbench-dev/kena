import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kena_emotional_journey/app/components/banner_ads_widget.dart';
import 'package:kena_emotional_journey/app/components/my_scaffold.dart';
import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';
import 'package:kena_emotional_journey/services/common/notifications_service.dart';

class NotificationsSettings extends StatefulWidget {
  const NotificationsSettings({super.key});

  @override
  State<NotificationsSettings> createState() => _NotificationsSettingsState();
}

class _NotificationsSettingsState extends State<NotificationsSettings> {
  bool autoDetele = false;
  final _notificationsService = NotificationsService();
  bool _notificationsEnabled = true;
  bool _isUpdatingNotifications = false;
  bool _isUpdatingAutoDelete = false;

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
    _loadAutoDeleteSetting();
  }

  Future<void> _loadAutoDeleteSetting() async {
    final enabled = await _notificationsService.getAutoDeleteSetting(
      context: context,
    );
    if (!mounted || enabled == null) return;
    setState(() => autoDetele = enabled);
  }

  Future<void> _onAutoDeleteToggled(bool value) async {
    final previousValue = autoDetele;
    setState(() {
      autoDetele = value;
      _isUpdatingAutoDelete = true;
    });

    final success = await _notificationsService.updateAutoDeleteSetting(
      context: context,
      autoDeleteNotifications: value,
    );

    if (!mounted) return;
    setState(() {
      _isUpdatingAutoDelete = false;
      if (!success) autoDetele = previousValue;
    });
  }

  Future<void> _loadNotificationSettings() async {
    final enabled = await _notificationsService.getNotificationSettings(
      context: context,
    );
    if (!mounted || enabled == null) return;
    setState(() => _notificationsEnabled = enabled);
  }

  Future<void> _onNotificationsToggled(bool value) async {
    final previousValue = _notificationsEnabled;
    setState(() {
      _notificationsEnabled = value;
      _isUpdatingNotifications = true;
    });

    final success = await _notificationsService.updateNotificationSettings(
      context: context,
      notificationsEnabled: value,
    );

    if (!mounted) return;
    setState(() {
      _isUpdatingNotifications = false;
      if (!success) _notificationsEnabled = previousValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      appBar: AppBar(
        title: Text(
          "Notifications",
          style: context.typography.title.copyWith(
            color: context.colors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 20.sp,
            fontFamily: 'sfpro',
          ),
        ),
        backgroundColor: context.colors.background,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            NotificationsTile(
              context,
              // "Mute" is ON when notifications are disabled
              !_notificationsEnabled,
              "Mute Notifications",
              onChanged: _isUpdatingNotifications
                  ? null
                  : (muted) => _onNotificationsToggled(!muted),
            ),
            SizedBox(height: 10.h),
            NotificationsTile(
              context,
              autoDetele,
              "Auto Delete After one day",
              onChanged: _isUpdatingAutoDelete ? null : _onAutoDeleteToggled,
            ),
            Spacer(),
            const BannerAdWidget(),
          ],
        ),
      ),
    );
  }

  Container NotificationsTile(
    BuildContext context,
    bool notificationValue,
    String title, {
    required ValueChanged<bool>? onChanged,
  }) {
    return Container(
      width: double.infinity,
      height: 50.h,
      decoration: BoxDecoration(
        // color: context.colors.textSecondary.withValues(alpha: 0.2),
        color: Color(0xFFECEEF0),
        borderRadius: BorderRadius.circular(15.r),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: context.typography.body.copyWith(
              color: context.colors.textPrimary,
              fontWeight: FontWeight.w400,
              fontSize: 16.sp,
              fontFamily: 'sfpro',
            ),
          ),
          Switch(
            value: notificationValue,
            onChanged: onChanged,

            // Active State (Top Switch)
            activeThumbColor: context.colors.background, // Active thumb color
            activeTrackColor:
                context.colors.primary, // Or use const Color(0xFFE5614D)
            // Inactive State (Bottom Switch)
            inactiveThumbColor:
                context.colors.background, // Inactive thumb color
            inactiveTrackColor: const Color(0xFF868686), // Grey track color
            // Removes the default Material 3 border outline
            trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
          ),
        ],
      ),
    );
  }
}
