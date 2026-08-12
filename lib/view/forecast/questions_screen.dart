import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kena_emotional_journey/app/components/my_button.dart';
import 'package:kena_emotional_journey/app/components/my_drawer.dart';
import 'package:kena_emotional_journey/app/components/my_scaffold.dart';
import 'package:kena_emotional_journey/app/routes/routes_name.dart';
import 'package:kena_emotional_journey/app/utils/extensions/context_extensions.dart';
import 'package:kena_emotional_journey/app/utils/extensions/flush_bar_extension.dart';
import 'package:kena_emotional_journey/generated/assets/assets.gen.dart';
import 'package:kena_emotional_journey/provider/navigation_actions_provider.dart';
import 'package:kena_emotional_journey/services/common/ad_mob_service.dart';
import 'package:kena_emotional_journey/services/user/user_home_service.dart';
import 'package:provider/provider.dart';

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

bool? _goAsForecast;
bool? _isPlanUseful;

class _QuestionsScreenState extends State<QuestionsScreen> {
  int _localIntensity = 3;
  final UserHomeService _userHomeService = UserHomeService();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    AdMobService.loadInterstitialAd();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Extract arguments from navigation
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
                    onChanged: (val) => setState(() => _goAsForecast = val),
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
                    fillColor: WidgetStatePropertyAll(context.colors.primary),
                    activeColor: Colors.white,
                  ),
                ),
                Expanded(
                  child: RadioListTile<bool>(
                    value: false,
                    groupValue: _goAsForecast,
                    onChanged: (val) => setState(() => _goAsForecast = val),
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
                    fillColor: WidgetStatePropertyAll(context.colors.primary),
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
                    onChanged: (val) => setState(() => _isPlanUseful = val),
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
                    fillColor: WidgetStatePropertyAll(context.colors.primary),
                    activeColor: Colors.white,
                  ),
                ),
                Expanded(
                  child: RadioListTile<bool>(
                    value: false,
                    groupValue: _isPlanUseful,
                    onChanged: (val) => setState(() => _isPlanUseful = val),
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
                    fillColor: WidgetStatePropertyAll(context.colors.primary),
                    activeColor: Colors.white,
                  ),
                ),
              ],
            ),
            SizedBox(height: 15.h),
            Text(
              'How did it go?',
              style: context.typography.body.copyWith(
                color: context.colors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'sfpro',
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'On a scale of 1 to 5, how did your day compare to the forecast?',
              style: context.typography.body.copyWith(
                color: context.colors.textSecondary,
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                fontFamily: 'sfpro',
              ),
            ),
            SizedBox(height: 15.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(5, (index) {
                int currentNumber = index + 1;
                return NumberCircle(
                  number: currentNumber,
                  isSelected: _localIntensity == currentNumber,
                  onTap: () {
                    setState(() {
                      _localIntensity = currentNumber;
                    });
                  },
                );
              }),
            ),
            SizedBox(height: 10.h),
            _buildLabelRow(context),
            Spacer(),
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
            ? const Color(0xFFfbbf23)
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
