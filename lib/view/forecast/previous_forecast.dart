import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:kena_emotional_journey/app/components/expandable_text.dart';
import 'package:kena_emotional_journey/app/components/my_button.dart';
import 'package:kena_emotional_journey/app/components/my_drawer.dart';
import 'package:kena_emotional_journey/app/components/my_scaffold.dart';
import 'package:kena_emotional_journey/app/routes/routes_name.dart';
import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';
import 'package:kena_emotional_journey/generated/assets/assets.gen.dart';
import 'package:kena_emotional_journey/model/analytics/month_data_model.dart';
import 'package:kena_emotional_journey/model/forecast/forecast_history_model.dart'
    as history;
import 'package:kena_emotional_journey/model/forecast/forecast_model.dart'
    as forecast;
import 'package:kena_emotional_journey/provider/navigation_actions_provider.dart';
import 'package:kena_emotional_journey/services/common/auth_service.dart';
import 'package:kena_emotional_journey/services/user/user_home_service.dart';
import 'package:kena_emotional_journey/view/forecast/widgets/emotion_tile.dart';
import 'package:kena_emotional_journey/view/forecast/widgets/emotions_section_card.dart';
import 'package:kena_emotional_journey/view/forecast/widgets/previous_forecast_calendar.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

class PreviousForecastScreen extends StatefulWidget {
  const PreviousForecastScreen({super.key, this.forecastData});
  final history.ForecastHistoryData? forecastData;

  @override
  State<PreviousForecastScreen> createState() => _PreviousForecastScreenState();
}

class _PreviousForecastScreenState extends State<PreviousForecastScreen> {
  DateTime? _loadedMonth;
  Map<String, MonthDay> _monthDaysMap = {};

  @override
  void initState() {
    super.initState();
    if (widget.forecastData != null) {
      _forecastData = widget.forecastData;
      _isLoading = false;
    }
    _loadMonthData(DateTime(_selectedDate.year, _selectedDate.month));
    _load();
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

  bool _isLoading = true;

  /// Data for the currently-selected date.
  history.ForecastHistoryData? _forecastData;
  history.ForecastHistoryForecast? get _forecast => _forecastData?.forecast;

  /// Every forecast entry fetched so far (used to drive calendar markers).
  final List<history.ForecastHistoryData> _allForecasts = [];

  DateTime _selectedDate = DateTime.now().subtract(const Duration(days: 1));
  bool isPlanExpanded = false;
  bool isNotesExpanded = false;

  List<history.Emotion> get _emotions => _forecast?.emotions ?? [];
  final UserHomeService _service = UserHomeService();

  List<DateTime> get _datesWithData {
    return _allForecasts
        .map((fd) {
          final raw = fd.day ?? fd.date;
          return raw != null ? DateTime.tryParse(raw) : null;
        })
        .whereType<DateTime>()
        .toList();
  }

  history.ForecastHistoryData? _findForecastForDate(DateTime date) {
    if (_allForecasts.isEmpty) return null;
    for (var fd in _allForecasts) {
      final raw = fd.day ?? fd.date;
      if (raw == null) continue;
      final fdDate = DateTime.tryParse(raw);
      if (fdDate == null) continue;
      if (fdDate.year == date.year &&
          fdDate.month == date.month &&
          fdDate.day == date.day) {
        return fd;
      }
    }
    return null;
  }

  String _formatDate(DateTime date) => date.toIso8601String().split('T').first;

  Future<void> _load() async {
    await _loadForecastByDate(_selectedDate);
  }

  Future<void> _loadForecastByDate(DateTime date) async {
    setState(() => _isLoading = true);

    final formattedDate = _formatDate(date);

    final result = await _service.getYestardayForecasts(
      date: formattedDate,
      context: context,
    );

    if (!mounted) return;

    final list = result?.data ?? [];

    setState(() {
      // Merge newly-fetched entries into the running list so calendar
      // markers accumulate across every date we've queried so far.
      for (final item in list) {
        final key = item.day ?? item.date;
        _allForecasts.removeWhere((e) => (e.day ?? e.date) == key);
      }
      _allForecasts.addAll(list);

      _forecastData = list.isNotEmpty ? list.first : _findForecastForDate(date);
      _selectedDate = date;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final actions = context.watch<NavigationActionsController>();
    final activities = _forecastData?.activities ?? [];
    final userNotes = _forecast?.userNotes ?? [];

    return MyScaffold(
      endDrawer: MyDrawer(
        items: [
          DrawerMenuItem(
            icon: Assets.icons.homeOutline.svg(),
            label: 'Home',
            isDisabled: actions.isAnyLoading,
            onTap: () {
              Navigator.pushNamed(context, RoutesName.homeScreen);
            },
          ),
          DrawerMenuItem(
            icon: Assets.icons.aspire.svg(),
            label: 'Aspire',
            isLoading: actions.aspireLoading,
            isDisabled: actions.isAnyLoading && !actions.aspireLoading,
            isAsync: true,
            onTap: () => actions.onAspireTap(context),
          ),
          DrawerMenuItem(
            icon: Assets.icons.dailyPuls.svg(),
            label: 'Daily Pulse',
            isLoading: actions.forecastLoading,
            isDisabled: actions.isAnyLoading && !actions.forecastLoading,
            isAsync: true,
            onTap: () => actions.onForecastTap(context),
          ),
          DrawerMenuItem(
            icon: Assets.icons.activity.svg(),
            label: 'Activities',
            isDisabled: actions.isAnyLoading,
            onTap: () => actions.onActivitiesTap(context),
          ),
          DrawerMenuItem(
            icon: Assets.icons.circle.svg(),
            label: 'Circle',
            isDisabled: actions.isAnyLoading,
            onTap: () => actions.onCommunityTap(context),
          ),
          DrawerMenuItem(
            icon: Assets.icons.bellIcon.svg(),
            label: 'Notifications',
            isDisabled: actions.isAnyLoading,
            onTap: () {
              Navigator.pushNamed(context, RoutesName.notificationScreen);
            },
          ),
          DrawerMenuItem(
            icon: const Icon(Icons.logout, color: Colors.black),
            label: 'Logout',
            isDisabled: actions.isAnyLoading,
            onTap: () => AuthService.logout(context),
          ),
        ],
      ),
      appBar: AppBar(
        title: Text(
          'Select a previous forecast',
          style: context.typography.body.copyWith(
            color: context.colors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 16,
            fontFamily: 'sfpro',
          ),
        ),
        leading: BackButton(color: context.colors.textPrimary),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 12.w),
            child: Builder(
              builder: (scaffoldContext) => GestureDetector(
                onTap: () => Scaffold.of(scaffoldContext).openEndDrawer(),
                child: Container(
                  color: Colors.transparent,
                  padding: EdgeInsets.all(6.w),
                  child: Icon(
                    Icons.menu,
                    color: context.colors.textPrimary,
                    size: 26.sp,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: LoadingAnimationWidget.staggeredDotsWave(
                color: context.colors.primary,
                size: 45,
              ),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PreviousForecastCalendar(
                    initialDate: _selectedDate,
                    datesWithData: _datesWithData,
                    monthDaysData: _monthDaysMap,
                    onMonthChanged: (month) {
                      if (_loadedMonth == null ||
                          _loadedMonth!.year != month.year ||
                          _loadedMonth!.month != month.month) {
                        _loadMonthData(month);
                      }
                    },
                    onDateSelected: (date) {
                      if (_loadedMonth == null ||
                          _loadedMonth!.year != date.year ||
                          _loadedMonth!.month != date.month) {
                        _loadMonthData(DateTime(date.year, date.month));
                      }
                      final existing = _findForecastForDate(date);
                      if (existing != null) {
                        setState(() {
                          _selectedDate = date;
                          _forecastData = existing;
                        });
                      } else {
                        _loadForecastByDate(date);
                      }
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildForecastSection(),
                        SizedBox(height: 15.h),
                        _infoCard(
                          context,
                          showEdit: false,
                          onEdit: null,
                          title: "Your Plan",
                          subtitle: ExpandableText(
                            text: _forecast?.plan?.isNotEmpty == true
                                ? _forecast!.plan!
                                : "No Plan recorded",
                            expanded: isPlanExpanded,
                            onToggle: () {
                              setState(() {
                                isPlanExpanded = !isPlanExpanded;
                                if (isPlanExpanded) isNotesExpanded = false;
                              });
                            },
                          ),
                        ),
                        SizedBox(height: 15.h),
                        _buildEndDaySection(),
                        SizedBox(height: 10.h),

                        // TODO: `Reflection` currently only exposes
                        // `emotions`, with no question/answer text fields.
                        // Wire these up once the backend/model provides them.
                        if (_forecast?.notes?.isNotEmpty == true)
                          QuestionsCard(
                            question: "Notes",
                            answer: _forecast!.notes!,
                          ),

                        SizedBox(height: 10.h),
                        Text(
                          'Activities',
                          style: context.typography.body.copyWith(
                            color: context.colors.textPrimary,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            fontFamily: "sfpro",
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: context.colors.textSecondary.withValues(
                                alpha: 0.3,
                              ),
                            ),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: activities.isEmpty
                              ? Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8.h),
                                  child: Text(
                                    "No activities recorded",
                                    style: context.typography.body.copyWith(
                                      color: context.colors.textSecondary,
                                      fontSize: 13.sp,
                                      fontFamily: 'sfpro',
                                    ),
                                  ),
                                )
                              : Column(
                                  children: [
                                    for (
                                      int i = 0;
                                      i < activities.length;
                                      i++
                                    ) ...[
                                      _buildActivitiesSection(
                                        context,
                                        activities[i].completed ?? false,
                                        activities[i].name ?? '',
                                        // Read-only: this is historical data.
                                        onChanged: null,
                                      ),
                                      if (i != activities.length - 1)
                                        SizedBox(height: 10.h),
                                    ],
                                  ],
                                ),
                        ),

                        SizedBox(height: 10.h),
                        if (userNotes.isEmpty)
                          Text(
                            "No notes recorded",
                            style: context.typography.body.copyWith(
                              color: context.colors.textSecondary,
                              fontSize: 13.sp,
                              fontFamily: 'sfpro',
                            ),
                          )
                        else
                          for (int i = 0; i < userNotes.length; i++) ...[
                            NotesCard(note: userNotes[i]),
                            if (i != userNotes.length - 1)
                              SizedBox(height: 10.h),
                          ],

                        SizedBox(height: 50.h),
                        MyButton(
                          onPressed: _forecastData == null || _emotions.isEmpty
                              ? null
                              : () {
                                  Navigator.pushNamed(
                                    context,
                                    RoutesName.selectTodayForecast,
                                    arguments: {'date': _selectedDate},
                                  );
                                },
                          label: "Select as Today’s Forecast",
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildForecastSection() {
    final emotionsToShow = _emotions.take(3).toList();

    return EmotionsSectionCard(
      title: 'Forecast',
      isEditMode: false,
      onToggleEdit: null,
      tiles: emotionsToShow.map((emotion) {
        return EmotionTile(
          isEditMode: false,
          emotion: forecast.Emotion(
            key: emotion.key,
            intensity: emotion.intensity,
            imageUrl: emotion.imageUrl,
            title: emotion.title,
          ),
          showImage: true,
          onEditImageTap: () {},
        );
      }).toList(),
    );
  }

  Widget _buildActivitiesSection(
    BuildContext context,
    bool isChecked,
    String title, {
    ValueChanged<bool?>? onChanged,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Checkbox(
          value: isChecked,
          onChanged: onChanged,
          checkColor: context.colors.background,
          activeColor: context.colors.tertiary,
          fillColor: WidgetStateProperty.all(context.colors.tertiary),
          side: BorderSide(color: context.colors.tertiary),
          shape: const CircleBorder(),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
        ),
        SizedBox(width: 5.w),
        Text(
          title,
          style: context.typography.body.copyWith(
            color: context.colors.tertiary,
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            fontFamily: 'sfpro',
          ),
        ),
      ],
    );
  }

  Widget _buildEndDaySection() {
    final emotionsToShow =
        _forecastData?.reflection?.emotions?.take(3).toList() ?? [];
    return EmotionsSectionCard(
      title: 'End Day Reflection',
      isEditMode: false,
      onToggleEdit: null,
      tiles: emotionsToShow.map((emotion) {
        return EmotionTile(
          isEditMode: false,
          emotion: forecast.Emotion(
            key: emotion.key,
            intensity: emotion.intensity,
            imageUrl: emotion.imageUrl,
            title: emotion.title,
          ),
          showImage: true,
          onEditImageTap: () {},
        );
      }).toList(),
    );
  }
}

class QuestionsCard extends StatelessWidget {
  final String question;
  final String answer;

  const QuestionsCard({
    super.key,
    required this.question,
    required this.answer,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: context.typography.body.copyWith(
            color: context.colors.textPrimary,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            fontFamily: 'sfpro',
          ),
        ),
        SizedBox(height: 10.h),
        Text(
          answer,
          style: context.typography.body.copyWith(
            color: context.colors.textPrimary,
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            fontFamily: 'sfpro',
          ),
        ),
      ],
    );
  }
}

Widget _infoCard(
  BuildContext context, {
  required String title,
  required Widget subtitle,
  required bool showEdit,
  VoidCallback? onEdit,
}) {
  return Container(
    padding: EdgeInsets.all(10.w),
    width: double.infinity,
    decoration: BoxDecoration(
      color: context.colors.background,
      borderRadius: BorderRadius.circular(12.r),
      border: Border.all(
        color: context.colors.textSecondary.withValues(alpha: 0.2),
      ),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title.isNotEmpty)
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: context.colors.textPrimary,
                  ),
                ),
              if (title.isNotEmpty) SizedBox(height: 10.h),
              subtitle,
            ],
          ),
        ),
        if (showEdit)
          GestureDetector(onTap: onEdit, child: Assets.icons.pen2.svg()),
      ],
    ),
  );
}

class NotesCard extends StatelessWidget {
  final history.UserNote note;

  const NotesCard({super.key, required this.note});

  String _formatPosted(String? iso) {
    if (iso == null) return '';
    final date = DateTime.tryParse(iso);
    if (date == null) return iso;
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return 'Posted on ${date.day} ${months[date.month - 1]}';
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
            _formatPosted(note.createdAt),
            style: context.typography.body.copyWith(
              color: context.colors.textPrimary,
              fontFamily: 'sfpro',
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 5.h),
          Text(
            note.content ?? '',
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
