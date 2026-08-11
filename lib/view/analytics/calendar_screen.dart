import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';
import 'package:kena_emotional_journey/model/analytics/analytics_calendar_model.dart';
import 'package:kena_emotional_journey/model/analytics/month_data_model.dart';
import 'package:kena_emotional_journey/model/forecast/forecast_model.dart'
    as fm;
import 'package:kena_emotional_journey/services/user/user_home_service.dart';
import 'package:kena_emotional_journey/view/forecast/widgets/emotion_tile.dart';
import 'package:kena_emotional_journey/view/forecast/widgets/emotions_section_card.dart';
import 'package:kena_emotional_journey/view/forecast/widgets/info_card_widget.dart';
import 'package:kena_emotional_journey/view/forecast/widgets/previous_forecast_calendar.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _selectedDate;
  DateTime? _loadedMonth;
  AnalyticsCalendarModel? _calendarData;
  Map<String, MonthDay> _monthDaysMap = {};
  bool _isLoading = true;
  bool _isDayLoading = false;

  bool _isPlanExpanded = false;
  final UserHomeService _service = UserHomeService();

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _loadMonthData(DateTime(_selectedDate.year, _selectedDate.month));
    _loadDayData();
  }

  Future<void> _loadMonthData(DateTime month) async {
    _loadedMonth = DateTime(month.year, month.month);
    final monthStr = DateFormat('yyyy-MM').format(month);
    final result = await _service.getCalendarMonthAnalytics(
      month: monthStr,
      context: context,
    );
    if (!mounted) return;

    final Map<String, MonthDay> newMap = {};
    if (result?.data != null && result!.data!.isNotEmpty) {
      final days = result.data!.first.days ?? [];
      for (final d in days) {
        if (d.day != null) {
          newMap[d.day!] = d;
        }
      }
    }

    setState(() {
      _monthDaysMap = newMap;
    });
  }

  Future<void> _loadDayData() async {
    final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final result = await _service.getAnalyticsCalendar(
      day: formattedDate,
      context: context,
    );
    if (!mounted) return;

    setState(() {
      _calendarData = result;
      _isLoading = false;
      _isDayLoading = false;
    });
  }

  List<DateTime> get _datesWithData {
    if (_calendarData?.data == null) return [];
    return _calendarData!.data!
        .map((d) => d.day != null ? DateTime.tryParse(d.day!) : null)
        .whereType<DateTime>()
        .toList();
  }

  void _loadForecastByDate(DateTime date) {
    setState(() {
      _selectedDate = date;
      _isDayLoading = true;
    });

    if (_loadedMonth == null ||
        _loadedMonth!.year != date.year ||
        _loadedMonth!.month != date.month) {
      _loadMonthData(DateTime(date.year, date.month));
    }
    _loadDayData();
  }

  Data? get _selectedDayData {
    if (_calendarData?.data == null) return null;
    final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
    return _calendarData!.data!.firstWhere(
      (d) => d.day == formattedDate,
      orElse: () => Data(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 250.h),
          Center(
            child: LoadingAnimationWidget.staggeredDotsWave(
              color: context.colors.primary,
              size: 45,
            ),
          ),
        ],
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Embedded clean visual container wrapper framework
          PreviousForecastCalendar(
            initialDate: _selectedDate,
            datesWithData: _datesWithData,
            monthDaysData: _monthDaysMap,
            isAnalytics: true,
            onMonthChanged: (month) {
              if (_loadedMonth == null ||
                  _loadedMonth!.year != month.year ||
                  _loadedMonth!.month != month.month) {
                _loadMonthData(month);
              }
            },
            onDateSelected: (date) {
              _loadForecastByDate(date);
            },
          ),
          SizedBox(height: 5),
          Text(
            "Summary",
            style: context.typography.body.copyWith(
              color: context.colors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 16.sp,
            ),
          ),
          SizedBox(height: 5),
          if (_isDayLoading)
            _buildSummaryLoading()
          else ...[
            _coreEmotionBox(context),
            SizedBox(height: 16.h),
            _aspireEmotionBox(context),
            SizedBox(height: 16.h),
            _forecastEmotionBox(context),
            SizedBox(height: 16.h),
            _actualEmotionBox(context),
            SizedBox(height: 16.h),
            _buildPlanSection(),
            SizedBox(height: 16.h),
            Text(
              "Notes",
              style: context.typography.body.copyWith(
                color: context.colors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 14.sp,
                fontFamily: 'sfpro',
              ),
            ),
            SizedBox(height: 16.h),

            // --- SHOWING THE NOTES LIST HERE ---
            _buildForecastNotesList(),
            SizedBox(height: 16.h),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryLoading() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 40.h),
      child: Center(
        child: LoadingAnimationWidget.staggeredDotsWave(
          color: context.colors.primary,
          size: 40,
        ),
      ),
    );
  }

  Widget _coreEmotionBox(BuildContext context) {
    final coreEmotions = _selectedDayData?.coreEmotions ?? [];
    return EmotionsSectionCard(
      title: "Core Emotions",
      titleColor: context.colors.textPrimary,
      titleFontSize: 16.sp,
      showEmptyState: true,
      emptyText: "No emotions recorded",
      tiles: coreEmotions.map((emotion) {
        return EmotionTile(
          isEditMode: false,
          emotion: fm.Emotion(
            key: emotion.key,
            intensity: emotion.intensity,
            imageUrl: emotion.imageUrl,
          ),
          showImage: true,
          onEditImageTap: () {},
        );
      }).toList(),
    );
  }

  Widget _aspireEmotionBox(BuildContext context) {
    final aspirationalEmotions = _selectedDayData?.aspirationalEmotions ?? [];
    return EmotionsSectionCard(
      title: "Aspirational Emotions",
      titleColor: const Color(0xFFD108A5),
      titleFontSize: 16.sp,
      showEmptyState: true,
      emptyText: "No emotions recorded",
      tiles: aspirationalEmotions.map((emotion) {
        return EmotionTile(
          isEditMode: false,
          emotion: fm.Emotion(
            key: emotion.key,
            intensity: emotion.intensity,
            imageUrl: emotion.imageUrl,
          ),
          showImage: true,
          onEditImageTap: () {},
        );
      }).toList(),
    );
  }

  Widget _forecastEmotionBox(BuildContext context) {
    final forecastEmotions = _selectedDayData?.forecast ?? [];
    return EmotionsSectionCard(
      title: "Forecast",
      titleColor: context.colors.textPrimary,
      titleFontSize: 16.sp,
      showEmptyState: true,
      emptyText: "No emotions recorded",
      tiles: forecastEmotions.map((emotion) {
        return EmotionTile(
          isEditMode: false,
          emotion: fm.Emotion(
            key: emotion.key,
            intensity: emotion.intensity,
            imageUrl: emotion.imageUrl,
          ),
          showImage: true,
          onEditImageTap: () {},
        );
      }).toList(),
    );
  }

  Widget _actualEmotionBox(BuildContext context) {
    final actualEmotions = _selectedDayData?.actual ?? [];
    return EmotionsSectionCard(
      title: "Actual",
      titleColor: const Color(0xFFD108A5),
      titleFontSize: 16.sp,
      showEmptyState: true,
      emptyText: "No emotions recorded",
      tiles: actualEmotions.map((emotion) {
        final emotionMap = emotion as Map<String, dynamic>;
        return EmotionTile(
          isEditMode: false,
          emotion: fm.Emotion(
            key: emotionMap['key'] as String?,
            intensity: emotionMap['intensity'] as int?,
            imageUrl: emotionMap['imageUrl'] as String?,
          ),
          showImage: true,
          onEditImageTap: () {},
        );
      }).toList(),
    );
  }

  Widget _buildPlanSection() {
    final planText = _selectedDayData?.plan?.text ?? 'No plan recorded.';
    return InfoCardWidget(
      showEditIcon: false,
      title: 'Your Plan',
      text: planText,
      expanded: _isPlanExpanded,
      onToggle: () {
        setState(() {
          _isPlanExpanded = !_isPlanExpanded;
        });
      },
    );
  }

  Widget _buildForecastNotesList() {
    final notes = _selectedDayData?.notes ?? [];

    if (notes.isEmpty) {
      return Text(
        'No notes recorded',
        style: TextStyle(fontSize: 13.sp, color: context.colors.textSecondary),
      );
    }

    final noteCards = <Widget>[];
    for (final note in notes) {
      final content = note.content?.trim();
      if (content == null || content.isEmpty) continue;

      noteCards.add(
        Padding(
          padding: EdgeInsets.only(bottom: 10.h),
          child: NotesCard(note: content, day: note.day ?? ''),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: noteCards,
    );
  }
}

class NotesCard extends StatelessWidget {
  const NotesCard({super.key, required this.note, required this.day});

  final String note;
  final String day;

  String get _displayDay {
    final parsed = DateTime.tryParse(day);
    return parsed != null ? DateFormat('dd MMM').format(parsed) : day;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF3F1),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: context.colors.textSecondary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Posted on $_displayDay',
            style: context.typography.body.copyWith(
              color: context.colors.textPrimary,
              fontFamily: 'sfpro',
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 5.h),
          Text(
            note,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: context.typography.body.copyWith(
              color: context.colors.textPrimary,
              fontFamily: 'sfpro',
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
