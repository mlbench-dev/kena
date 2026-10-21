/// Features that are locked for Freemium users.
///
/// Every Freemium restriction in the app is listed here, so changing what
/// Freemium includes only means changing [SubscriptionProvider.canUse].
enum PremiumFeature {
  /// Finding emotions by body sensation / keyword (search by name stays free).
  bodySensationSearch,

  /// Having more than [FreemiumLimits.maxActivities] activities.
  unlimitedActivities,

  /// The "All Time" tab in Analytics (overall and activities).
  allTimeAnalytics,

  /// Browsing the Analytics calendar beyond the current month.
  fullCalendarHistory,

  /// Sharing your own daily forecast with your circle.
  shareDailyForecast,

  /// Sharing your own weekly forecast with your circle.
  shareWeeklyForecast,

  /// Viewing friends' weekly forecasts in the community feed.
  viewFriendsWeeklyForecast,
}

class FreemiumLimits {
  FreemiumLimits._();

  /// Today and Planned activities combined.
  static const int maxActivities = 10;
}
