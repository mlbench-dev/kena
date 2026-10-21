import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kena_emotional_journey/app/components/my_button.dart';
import 'package:kena_emotional_journey/app/components/my_dialog.dart';
import 'package:kena_emotional_journey/app/components/my_drawer.dart';
import 'package:kena_emotional_journey/app/components/my_scaffold.dart';
import 'package:kena_emotional_journey/app/components/my_text_field.dart';
import 'package:kena_emotional_journey/app/routes/routes_name.dart';
import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';
import 'package:kena_emotional_journey/app/utils/extensions/flush_bar_extension.dart';
import 'package:kena_emotional_journey/generated/assets/assets.gen.dart';
import 'package:kena_emotional_journey/provider/navigation_actions_provider.dart';
import 'package:kena_emotional_journey/services/common/ad_mob_service.dart';
import 'package:kena_emotional_journey/services/common/auth_service.dart';
import 'package:kena_emotional_journey/services/user/user_home_service.dart';
import 'package:kena_emotional_journey/view/pro_tip/widget/pro_tips_dialog_box.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuestionsScreen extends StatefulWidget {
  final List<Map<String, dynamic>> selectedEmotions;
  final String? notes;
  const QuestionsScreen({
    super.key,
    required this.selectedEmotions,
    this.notes,
  });

  @override
  State<QuestionsScreen> createState() => _QuestionsScreenState();
}

class _QuestionsScreenState extends State<QuestionsScreen> {
  bool? _goAsForecast;
  bool? _isPlanUseful;
  bool? _isFullCheckIn;
  bool _didReadArgs = false;
  final int _localIntensity = 3;
  final UserHomeService _userHomeService = UserHomeService();
  bool _isSubmitting = false;

  final _wentWellController = TextEditingController();
  final _heavyController = TextEditingController();
  final _selfTreatmentController = TextEditingController();
  final _handOverController = TextEditingController();
  final _dayAsStoryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    AdMobService.loadInterstitialAd();
    // Delay to allow ad to load before showing; the closing note follows the
    // ad, or shows straight away when no ad is shown.
    Future.delayed(const Duration(seconds: 2), () async {
      if (!mounted) return;
      final adShown = await AdMobService.showInterstitialAd(
        onClosed: _showClosingNote,
      );
      if (!adShown) _showClosingNote();
    });
  }

  final List<String> quotes = [
    "Tomorrow will bring its own energy. The present moment is solely for recovery and quiet.",

    "There is a virtue in work and there is a virtue in rest. Use both and overlook neither. — Alan Cohen",

    "Finish each day and be done with it. You have done what you could. — Ralph Waldo Emerson",

    "You treated yourself to a moment of awareness today, and that is a beautiful victory in itself.",

    "Close your eyes knowing you are enough, you are worthy, and you did your best.",

    "Exhale the day. Inhale the quiet.",

    "May your sleep be deep, your dreams be gentle, and your mind be completely still.",

    "Be proud of the quiet effort you put into today, even the parts no one else saw.",

    "Sometimes the most productive thing you can do is relax. — Mark Black",

    "Be proud of the energy you gave today. Now, it is time to refill your own cup.",

    "Put the day down. You can always pick it back up tomorrow if you choose to.",

    "Exhale the momentum of the day. Slow down your thoughts to match the evening light.",

    "You are officially off the clock. Let your mind wander to things that bring you simple joy.",

    "Be proud of the small wins and the quiet strength you showed today.",

    "Today is complete. Give yourself permission to enjoy the quiet space between now and tomorrow.",

    "Well done! An unexamined life is a missed opportunity, but a gently examined day is a gift to yourself. — Unknown",

    "Well done! To look honestly at your day takes courage. To look at it with kindness takes grace. — Unknown",

    "Well done! Honest reflection is the bridge between who you were today and who you can choose to be tomorrow. — Unknown",

    "Well done! Pausing to notice how you feel is the simplest, most profound act of self-respect. — Unknown",

    "Well done! Becoming aware of your own patterns is not a critique; it is your superpower growing. — Unknown",

    "Well done! You are not just tracking your days; you are learning the language of your own inner world. — Unknown",

    "Well done! Noticing how you treat yourself is the first step toward treating yourself better. — Unknown",

    "Well done! Emotional awareness is the art of giving your feelings a seat at the table without letting them drive the car. — Unknown",

    "Well done! True self-care isn't just escaping from life; it's gently looking at your life so you don't feel the need to escape. — Unknown",

    "Well done! By taking five minutes to look inward, you are telling yourself: 'My peace matters.' — Unknown",

    "Well done! You took care of your responsibilities all day. This moment of reflection is how you take care of you.",
  ];

  /// Picks a random quote once per day and keeps it for the rest of that day.
  Future<String> getQuoteOfTheDay() async {
    final prefs = await SharedPreferences.getInstance();

    final today = DateTime.now();
    final todayKey = '${today.year}-${today.month}-${today.day}';

    final savedDate = prefs.getString('quote_date');
    var quoteIndex = prefs.getInt('quote_index');

    // Also re-pick if the saved index no longer fits (e.g. the list shrank).
    if (savedDate != todayKey ||
        quoteIndex == null ||
        quoteIndex >= quotes.length) {
      quoteIndex = Random().nextInt(quotes.length);

      await prefs.setString('quote_date', todayKey);
      await prefs.setInt('quote_index', quoteIndex);
    }

    return quotes[quoteIndex];
  }

  bool _closingNoteShown = false;

  Future<void> _showClosingNote() async {
    if (!mounted || _closingNoteShown) return;
    _closingNoteShown = true;
    final quote = await getQuoteOfTheDay();
    if (!mounted) return;
    MyDialogBox.show(
      context,
      child: ProTipsDialogBox(
        title: 'Closing Note',
        description: quote,
        icon: Assets.images.bulb.image(),
        buttonLabel: 'Got it',
        onButtonPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  @override
  void dispose() {
    _wentWellController.dispose();
    _heavyController.dispose();
    _selfTreatmentController.dispose();
    _handOverController.dispose();
    _dayAsStoryController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Runs again on keyboard open / MediaQuery changes, so only prefill once —
    // otherwise the user's Yes/No answers get reset.
    if (_didReadArgs) return;
    _didReadArgs = true;
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      _goAsForecast = args['wentAsForecast'] as bool?;
      _isPlanUseful = args['planUseful'] as bool?;
    }
  }

  @override
  Widget build(BuildContext context) {
    final actions = context.watch<NavigationActionsController>();
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
          'How did the day go?',
          style: context.typography.title.copyWith(
            color: context.colors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
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
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Did it go as forecast?',
                      style: context.typography.body.copyWith(
                        color: context.colors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'sfpro',
                      ),
                    ),
                    SizedBox(height: 5.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          child: RadioListTile<bool>(
                            value: true,
                            groupValue: _goAsForecast,
                            onChanged: (val) =>
                                setState(() => _goAsForecast = val),
                            title: Text(
                              'Yes',
                              style: context.typography.body.copyWith(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: context.colors.textPrimary,
                              ),
                            ),
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                            visualDensity: const VisualDensity(
                              horizontal: -4,
                              vertical: -4,
                            ), // reduces spacing
                            fillColor: WidgetStatePropertyAll(
                              context.colors.tertiary,
                            ),
                            activeColor: Colors.white,
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<bool>(
                            value: false,
                            groupValue: _goAsForecast,
                            onChanged: (val) =>
                                setState(() => _goAsForecast = val),
                            title: Text(
                              'No',
                              style: context.typography.body.copyWith(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: context.colors.textPrimary,
                              ),
                            ),
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                            visualDensity: const VisualDensity(
                              horizontal: -4,
                              vertical: -4,
                            ), // reduces spacing
                            fillColor: WidgetStatePropertyAll(
                              context.colors.tertiary,
                            ),
                            activeColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 15.h),
                    Text(
                      'Was the plan you set useful?',
                      style: context.typography.body.copyWith(
                        color: context.colors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'sfpro',
                      ),
                    ),
                    SizedBox(height: 5.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          child: RadioListTile<bool>(
                            value: true,
                            groupValue: _isPlanUseful,
                            onChanged: (val) =>
                                setState(() => _isPlanUseful = val),
                            title: Text(
                              'Yes',
                              style: context.typography.body.copyWith(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: context.colors.textPrimary,
                              ),
                            ),
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                            visualDensity: const VisualDensity(
                              horizontal: -4,
                              vertical: -4,
                            ), // reduces spacing
                            fillColor: WidgetStatePropertyAll(
                              context.colors.tertiary,
                            ),
                            activeColor: Colors.white,
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<bool>(
                            value: false,
                            groupValue: _isPlanUseful,
                            onChanged: (val) =>
                                setState(() => _isPlanUseful = val),
                            title: Text(
                              'No',
                              style: context.typography.body.copyWith(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: context.colors.textPrimary,
                              ),
                            ),
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                            visualDensity: const VisualDensity(
                              horizontal: -4,
                              vertical: -4,
                            ), // reduces spacing
                            fillColor: WidgetStatePropertyAll(
                              context.colors.tertiary,
                            ),
                            activeColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    // SizedBox(height: 15.h),
                    // Text(
                    //   'How did it go?',
                    //   style: context.typography.body.copyWith(
                    //     color: context.colors.textPrimary,
                    //     fontSize: 16,
                    //     fontWeight: FontWeight.w600,
                    //     fontFamily: 'sfpro',
                    //   ),
                    // ),
                    // SizedBox(height: 8.h),
                    // Text(
                    //   'On a scale of 1 to 5, how did your day compare to the forecast?',
                    //   style: context.typography.body.copyWith(
                    //     color: context.colors.textSecondary,
                    //     fontSize: 14.sp,
                    //     fontWeight: FontWeight.w400,
                    //     fontFamily: 'sfpro',
                    //   ),
                    // ),
                    // SizedBox(height: 15.h),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    //   children: List.generate(5, (index) {
                    //     int currentNumber = index + 1;
                    //     return NumberCircle(
                    //       number: currentNumber,
                    //       isSelected: _localIntensity == currentNumber,
                    //       onTap: () {
                    //         setState(() {
                    //           _localIntensity = currentNumber;
                    //         });
                    //       },
                    //     );
                    //   }),
                    // ),
                    // SizedBox(height: 10.h),
                    // _buildLabelRow(context),
                    SizedBox(height: 16.h),
                    Text(
                      'Choose Your Check-In',
                      style: context.typography.body.copyWith(
                        color: context.colors.textPrimary,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'sfpro',
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<bool>(
                            value: true,
                            groupValue: _isFullCheckIn,
                            onChanged: (val) =>
                                setState(() => _isFullCheckIn = val),
                            title: Text(
                              'Full',
                              style: context.typography.body.copyWith(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: context.colors.textPrimary,
                              ),
                            ),
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                            visualDensity: const VisualDensity(
                              horizontal: -4,
                              vertical: -4,
                            ), // reduces spacing
                            fillColor: WidgetStatePropertyAll(
                              context.colors.tertiary,
                            ),
                            activeColor: Colors.white,
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<bool>(
                            value: false,
                            groupValue: _isFullCheckIn,
                            onChanged: (val) =>
                                setState(() => _isFullCheckIn = val),
                            title: Text(
                              'Quick',
                              style: context.typography.body.copyWith(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: context.colors.textPrimary,
                              ),
                            ),
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                            visualDensity: const VisualDensity(
                              horizontal: -4,
                              vertical: -4,
                            ), // reduces spacing
                            fillColor: WidgetStatePropertyAll(
                              context.colors.tertiary,
                            ),
                            activeColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    if (_isFullCheckIn == true)
                      ..._buildFullCheckInFields(context),
                    if (_isFullCheckIn == false)
                      ..._buildQuickCheckInFields(context),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16.h),
            MyButton(
              label: 'Save',
              isLoading: _isSubmitting,
              backgroundColor: context.colors.primary,
              textColor: context.colors.background,
              onPressed: _isSubmitting
                  ? null
                  : () async {
                      if (_goAsForecast == null || _isPlanUseful == null) {
                        context.flushBarErrorMessage(
                          message: "Please answer all questions",
                        );
                        return;
                      }

                      setState(() => _isSubmitting = true);

                      final success = await _userHomeService.endOfDay(
                        context: context,
                        emotions: widget.selectedEmotions,
                        wentAsForecast: _goAsForecast!,
                        planUseful: _isPlanUseful!,
                        planFeedback: widget.notes ?? '',
                        compareToForecast: _localIntensity,
                        checkInType: _checkInType,
                        checkInAnswers: _checkInAnswers,
                      );

                      if (!mounted) return;
                      setState(() => _isSubmitting = false);

                      if (success) {
                        // Show at most once per session/cooldown — see
                        // AdMobService.showInterstitialAd for the rules.
                        await AdMobService.showInterstitialAd();
                        if (!mounted) return;

                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          RoutesName.endDayComparisonScreen,
                          (route) =>
                              route.settings.name == RoutesName.homeScreen ||
                              route.isFirst,
                        );
                        Future.microtask(() {
                          context.flushBarSuccessMessage(
                            message: "Emotions saved successfully",
                          );
                        });
                      }
                    },
            ),
          ],
        ),
      ),
    );
  }

  String? get _checkInType => switch (_isFullCheckIn) {
    true => 'full',
    false => 'quick',
    null => null,
  };

  Map<String, String>? get _checkInAnswers => switch (_isFullCheckIn) {
    true => {
      'wentWell': _wentWellController.text.trim(),
      'heavy': _heavyController.text.trim(),
      'selfObservation': _selfTreatmentController.text.trim(),
      'handover': _handOverController.text.trim(),
    },
    false => {'dayMetaphor': _dayAsStoryController.text.trim()},
    null => null,
  };

  List<Widget> _buildFullCheckInFields(BuildContext context) {
    const placeHint = 'It may be a person, an experience, place';
    const writeHint = 'Write here...';
    const taskHint = 'A task, conversation, expectation etc.';
    return [
      _buildWrittenQuestion(
        context,
        question: 'What was pleasant, cheerful or went well today?',
        hint: placeHint,
        controller: _wentWellController,
      ),
      _buildWrittenQuestion(
        context,
        question: 'What was heavy, unpleasant, draining etc. today?',
        hint: placeHint,
        controller: _heavyController,
      ),
      _buildWrittenQuestion(
        context,
        question: 'Any observation on how you treated yourself today',
        hint: writeHint,
        controller: _selfTreatmentController,
      ),
      _buildWrittenQuestion(
        context,
        question: 'What are you handing-over to tomorrow / another day?',
        hint: taskHint,
        controller: _handOverController,
      ),
    ];
  }

  List<Widget> _buildQuickCheckInFields(BuildContext context) {
    return [
      _buildWrittenQuestion(
        context,
        question: 'What would you like to note about today?',
        hint: 'Write here...',
        controller: _dayAsStoryController,
      ),
    ];
  }

  Widget _buildWrittenQuestion(
    BuildContext context, {
    required String question,
    required String hint,
    required TextEditingController controller,
  }) {
    return Padding(
      padding: EdgeInsets.only(top: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: context.typography.body.copyWith(
              color: context.colors.textPrimary,
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              fontFamily: 'sfpro',
            ),
          ),
          SizedBox(height: 10.h),
          MyTextField(
            maxLines: 2,
            controller: controller,
            hint: hint,
            fillColor: const Color(0xFFF3F4F6),
            borderColor: Colors.transparent,
            hintColor: context.colors.textSecondary,
            textInputAction: TextInputAction.next,
          ),
        ],
      ),
    );
  }

  Widget _buildLabelRow(BuildContext context) {
    final labels = ["Much Worse", "Worse", "Same", "Better", "Much Better"];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: labels
          .map(
            (label) => Text(
              label,
              style: context.typography.subtitle.copyWith(
                fontSize: 10.sp,
                color: context.colors.textSecondary,
              ),
            ),
          )
          .toList(),
    );
  }
}

class NumberCircle extends StatelessWidget {
  final int number;
  final bool isSelected; // New parameter
  final VoidCallback onTap;

  const NumberCircle({
    super.key,
    required this.number,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: 26.r,
        // Change color based on selection
        backgroundColor: isSelected
            ? context.colors.tertiary
            : const Color(0xFFF3F4F6),
        child: Text(
          "$number",
          style: context.typography.body.copyWith(
            // Change text color to white if selected
            color: isSelected ? Colors.white : const Color(0xFF6c7280),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
