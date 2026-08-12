class TourSections {
  static const onboarding = 'onboarding';
  static const emotionTracking = 'emotion_tracking';
  static const forecast = 'forecast';
  static const forecastResult = 'forecast_result';
  static const activities = 'activities';
  static const planAndActivities = 'activities_plan';
}

class TourStep {
  final String title;
  final String description;

  const TourStep({required this.title, required this.description});
}

class TourContent {
  static const Map<String, List<TourStep>> _content = {
    TourSections.onboarding: [
      TourStep(
        title: 'Aspire',
        description:
            'We recommend you start here. Record you current core and aspirational emotions and the activities / actions you will take to support your journey.',
      ),
      TourStep(
        title: 'Daily Pulse',
        description:
            'At start of day complete an emotional forecast and plan. Engage your circle. End of day reflect on how it went.',
      ),
      TourStep(
        title: 'Activities',
        description:
            'Select or customise your activities including the frequency. See your progress weekly, monthly etc.',
      ),
      TourStep(
        title: 'Analytics',
        description:
            'remove the caps on weekly, monthly, all time and analytics.',
      ),
      TourStep(
        title: 'Circle',
        description:
            'Add 1-3 people to your support circle. See circles you are invited to and support them with comments or likes.',
      ),
    ],
    TourSections.planAndActivities: [
      TourStep(
        title: 'Activities',
        description:
            'Activities you set in the aspire page reflect here based on the frequency set. E.g. a jog every Tuesday show here on Tuesday only.  You can add/remove activities daily but these changes only reflect on the day.',
      ),
    ],
    TourSections.forecastResult: [
      TourStep(
        title: 'Share your daily forecast with people you trust',
        description:
            '• Select up to 3 people from your community.• They can see your emotions, plan and activities for the day.• Stay connected and supported on your emotional       journey.',
      ),
    ],
    TourSections.emotionTracking: [
      TourStep(
        title: 'Search Emotions',
        description:
            'You can search by emotion / body sensation e.g. sweaty palms.',
      ),
      TourStep(
        title: 'Choose Your Emotions',
        description:
            'We have organised emotions into six main categories. Tap any of the six to see additional emotions.',
      ),
      TourStep(
        title: 'Personalise Your Emotions',
        description:
            'Tap the upload icon to replace the emoji with your own image',
      ),
      TourStep(
        title: 'Activities',
        description:
            'Select or add custom activities that align with your emotional goals.',
      ),
    ],
    TourSections.forecast: [
      TourStep(
        title: 'Search Emotions',
        description:
            'You can search by emotion / body sensation e.g. sweaty palms.',
      ),
      TourStep(
        title: 'Choose Your Emotions',
        description:
            'We have organised emotions into six main categories. Tap any of the six to see additional emotions.',
      ),
      TourStep(
        title: 'Personalise Your Emotions:',
        description: 'Upload your image',
      ),
    ],
    TourSections.activities: [
      TourStep(
        title: 'Select Activities',
        description:
            'Choose activities that help you manage or navigate your emotions.',
      ),
    ],
  };

  static List<TourStep> stepsFor(String sectionKey) =>
      _content[sectionKey] ?? [];
}
