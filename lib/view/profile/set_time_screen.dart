import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kena_emotional_journey/app/components/banner_ads_widget.dart';
import 'package:kena_emotional_journey/app/components/loading_widget.dart';
import 'package:kena_emotional_journey/app/components/my_button.dart';
import 'package:kena_emotional_journey/app/components/my_scaffold.dart';
import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';
import 'package:kena_emotional_journey/app/utils/extensions/flush_bar_extension.dart';
import 'package:kena_emotional_journey/services/common/notifications_service.dart';

const _fieldBackgroundColor = Color(0xFFECEEF0);
const _inactiveTextColor = Color(0xFF868686);
const _fontFamily = 'sfpro';

class SetTimeScreen extends StatefulWidget {
  const SetTimeScreen({super.key});

  @override
  State<SetTimeScreen> createState() => _SetTimeScreenState();
}

class _SetTimeScreenState extends State<SetTimeScreen> {
  TimeOfDay _dailyPulseTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _eodTime = const TimeOfDay(hour: 20, minute: 0);
  bool _isSaving = false;
  bool _isLoading = true;
  bool _hasSavedTimes = false;

  final NotificationsService _notificationsService = NotificationsService();

  @override
  void initState() {
    super.initState();
    _loadReminderTimes();
  }

  Future<void> _loadReminderTimes() async {
    final times = await _notificationsService.getReminderTimes(
      context: context,
    );

    if (!mounted) return;
    setState(() {
      if (times != null) {
        _dailyPulseTime = times.dailyPulseTime;
        _eodTime = times.eodTime;
        _hasSavedTimes = true;
      }
      _isLoading = false;
    });
  }

  Future<void> _saveReminderTimes() async {
    setState(() => _isSaving = true);

    final success = await _notificationsService.updateReminderTimes(
      context: context,
      dailyPulseTime: _dailyPulseTime,
      eodTime: _eodTime,
    );

    if (!mounted) return;
    setState(() {
      _isSaving = false;
      if (success) _hasSavedTimes = true;
    });
    if (success) {
      context.flushBarSuccessMessage(message: "Reminder times updated");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      appBar: AppBar(
        title: Text(
          "Set Time",
          style: context.typography.title.copyWith(
            color: context.colors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 20.sp,
            fontFamily: _fontFamily,
          ),
        ),
        backgroundColor: context.colors.background,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _isLoading
          ? const LoadingWidget()
          : Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TimeField(
                    label: "Daily Pulse Time:",
                    time: _dailyPulseTime,
                    onChanged: (time) => setState(() => _dailyPulseTime = time),
                  ),
                  SizedBox(height: 20.h),
                  _TimeField(
                    label: "EOD Time:",
                    time: _eodTime,
                    onChanged: (time) => setState(() => _eodTime = time),
                  ),
                  const Spacer(),
                  const BannerAdWidget(),
                  SizedBox(height: 10),
                  MyButton(
                    label: _hasSavedTimes ? "Update Time" : "Save",
                    isLoading: _isSaving,
                    onPressed: _saveReminderTimes,
                  ),
                ],
              ),
            ),
    );
  }
}

/// Labelled time input: tap the time to open a picker, tap AM/PM to switch period.
class _TimeField extends StatelessWidget {
  const _TimeField({
    required this.label,
    required this.time,
    required this.onChanged,
  });

  final String label;
  final TimeOfDay time;
  final ValueChanged<TimeOfDay> onChanged;

  bool get _isAm => time.period == DayPeriod.am;

  String get _formattedTime {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    return "$hour:$minute";
  }

  void _setPeriod(DayPeriod period) {
    if (time.period == period) return;
    final hourShift = period == DayPeriod.am ? -12 : 12;
    onChanged(time.replacing(hour: time.hour + hourShift));
  }

  Future<void> _openPicker(BuildContext context) async {
    final picked = await showCupertinoModalPopup<TimeOfDay>(
      context: context,
      builder: (_) => _TimePickerSheet(initialTime: time),
    );
    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.typography.title.copyWith(
            color: context.colors.textPrimary,
            fontWeight: FontWeight.w500,
            fontSize: 15.sp,
            fontFamily: _fontFamily,
          ),
        ),
        SizedBox(height: 10.h),
        Container(
          height: 50.h,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            color: _fieldBackgroundColor,
            borderRadius: BorderRadius.circular(15.r),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _openPicker(context),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _formattedTime,
                      style: context.typography.body.copyWith(
                        color: context.colors.textPrimary,
                        fontSize: 16.sp,
                        fontFamily: _fontFamily,
                      ),
                    ),
                  ),
                ),
              ),
              _PeriodOption(
                label: "AM",
                isSelected: _isAm,
                onTap: () => _setPeriod(DayPeriod.am),
              ),
              SizedBox(width: 6.w),
              _PeriodOption(
                label: "PM",
                isSelected: !_isAm,
                onTap: () => _setPeriod(DayPeriod.pm),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PeriodOption extends StatelessWidget {
  const _PeriodOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 8.h),
        child: Text(
          label,
          style: context.typography.body.copyWith(
            color: isSelected ? context.colors.primary : _inactiveTextColor,
            fontSize: 16.sp,
            fontFamily: _fontFamily,
          ),
        ),
      ),
    );
  }
}

/// Bottom sheet with an iOS-style time wheel. Pops with the chosen time on "Done".
class _TimePickerSheet extends StatefulWidget {
  const _TimePickerSheet({required this.initialTime});

  final TimeOfDay initialTime;

  @override
  State<_TimePickerSheet> createState() => _TimePickerSheetState();
}

class _TimePickerSheetState extends State<_TimePickerSheet> {
  late TimeOfDay _selectedTime = widget.initialTime;

  DateTime get _initialDateTime {
    final now = DateTime.now();
    return DateTime(
      now.year,
      now.month,
      now.day,
      widget.initialTime.hour,
      widget.initialTime.minute,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300.h,
      color: context.colors.background,
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: CupertinoButton(
                onPressed: () => Navigator.of(context).pop(_selectedTime),
                child: Text(
                  "Done",
                  style: TextStyle(
                    color: context.colors.primary,
                    fontWeight: FontWeight.w600,
                    fontFamily: _fontFamily,
                  ),
                ),
              ),
            ),
            Expanded(
              // The picker ignores app colors, so set its text style explicitly.
              child: CupertinoTheme(
                data: CupertinoThemeData(
                  textTheme: CupertinoTextThemeData(
                    dateTimePickerTextStyle: TextStyle(
                      color: context.colors.textPrimary,
                      fontSize: 21.sp,
                      fontFamily: _fontFamily,
                    ),
                  ),
                ),
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  use24hFormat: false,
                  initialDateTime: _initialDateTime,
                  onDateTimeChanged: (dateTime) =>
                      _selectedTime = TimeOfDay.fromDateTime(dateTime),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
