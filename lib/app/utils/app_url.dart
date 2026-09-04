class AppUrl {
  // Base URLs
  // static const String baseUrl = 'https://c4rv5zwz-3000.inc1.devtunnels.ms';
  // static const String baseUrl = 'https://kena-backend-phase2.vercel.app';
  static const String baseUrl = 'https://www.kena.life';

  // ========================
  // Authentication Endpoints
  // ========================

  // User Auth
  // static const String login = '$baseUrl/api/auth/login';
  static const String vendorSignup =
      '$baseUrl/auth/vendor/signup-otp'; //add info and send otp
  static const String userSignup =
      '$baseUrl/api/auth/signup'; //add info and send otp
  static const String userOAuth =
      '$baseUrl/api/auth/oauth'; //user google or apple auth
  static const String vendorOAuth =
      '$baseUrl/auth/vendor/oauth'; //vendor google or apple auth
  static const String verifyVendorOtp =
      '$baseUrl/auth/vendor/signup'; //verify otp to complete signup
  static const String verifyUserOtp =
      '$baseUrl/api/auth/verify-email'; //verify otp to complete signup
  static const String resendOtp = '$baseUrl/api/auth/resend-code';
  static const String forgotPassword = '$baseUrl/api/auth/password/forgot';
  static const String resetPassword = '$baseUrl/api/auth/password/reset';
  static const String changePassword = '$baseUrl/api/auth/password/change';

  static const String vendorLogin = '$baseUrl/auth/vendor/login';
  static const String userLogin = '$baseUrl/api/auth/login';
  static const String verifyOtp = '$baseUrl/api/auth/password/verify';

  static const String deleteVendorAccount =
      '$baseUrl/auth/vendor/delete-account';
  // Delete User Account
  static const String deleteUserAccount = '$baseUrl/api/auth/account';

  // ========================
  // Home Endpoints
  // ========================
  static const String getNearbyVendors = '$baseUrl/auth/user/nearby-vendors';

  // ========================
  // Subscription Endpoints
  // ========================
  static const String subscriptionConfig = '$baseUrl/api/subscription/config';
  static const String subscriptionPlans = '$baseUrl/api/subscription/plans';
  static const String subscriptionMe = '$baseUrl/api/subscription/me';
  static const String subscriptionSetupIntent =
      '$baseUrl/api/subscription/mobile/setup-intent';
  static const String subscriptionActivate =
      '$baseUrl/api/subscription/mobile/activate';
  static const String subscriptionSubscribe =
      '$baseUrl/api/subscription/mobile/subscribe';
  static const String appleVerify = '$baseUrl/api/subscription/apple/verify';
  static const String subscriptionCancel = '$baseUrl/api/subscription/cancel';
  static const String subscriptionRenew = '$baseUrl/api/subscription/renew';
  static const String subscriptionChange = '$baseUrl/api/subscription/change';
  static const String subscriptionActivities =
      '$baseUrl/api/subscription/activities';
  // Freemium plan selection — notifies backend the user chose the free tier
  static const String subscriptionFreemium =
      '$baseUrl/api/subscription/freemium';

  static String getVendorDetails(String vendorId) =>
      '$baseUrl/auth/vendor/$vendorId/details';
  static String getVendorReviewsById(String vendorId) =>
      '$baseUrl/auth/reviews/$vendorId';

  static const String getUserReviews = '$baseUrl/auth/user/ratings';

  static const String addCoreEmotions = '$baseUrl/api/onboarding/core-emotions';
  static const String deleteCoreEmotions = '$baseUrl/api/journal/daily/core';
  static const String addAspirationalEmotions =
      '$baseUrl/api/onboarding/aspiration-emotions';
  static const String deleteAspirationalEmotions =
      '$baseUrl/api/journal/daily/aspiration';
  static const String forecast = '$baseUrl/api/journal/forecast';
  // static const String getForecast = '$baseUrl/api/journal/forecast';
  static const String endOfDay = '$baseUrl/api/journal/reflection';
  static const String addActivities = '$baseUrl/api/activities/selections';
  static const String addTodayActivities = '$baseUrl/api/activities/selections';
  static const String updateTodayActivities =
      '$baseUrl/api/activities/selections/edit';
  static const String updatePlannedActivities =
      '$baseUrl/api/activities/planned/edit';
  static const String addPlannedActivity =
      '$baseUrl/api/activities/planned/add';
  static const String getForecastPlanActivities =
      '$baseUrl/api/activities/forecast';
  static const String addForecastPlanActivities =
      '$baseUrl/api/activities/forecast';
  static const String saveForecastPlanActivities =
      '$baseUrl/api/activities/forecast/save';
  static const String addAspireNotes = '$baseUrl/api/journal/selection/notes';
  static const String addForecastNotes =
      '$baseUrl/api/activities/forecast/notes';
  static const String getForecastNotes =
      '$baseUrl/api/activities/forecast/notes';
  static const String getAspireNotes = '$baseUrl/api/journal/selection/notes';
  static const String getYesterdayForecasts =
      '$baseUrl/api/emotions/forecasts?dates=';

  static const String reviewDate = '$baseUrl/api/emotions/review-date';
  static const String createCommunity = '$baseUrl/api/community/create';
  static const String inviteUsername = '$baseUrl/api/community/invite/username';
  static const String inviteEmail = '$baseUrl/api/community/invite/email';
  static const String sendInviteToMembers =
      '$baseUrl/api/journal/share/members';
  static const String getStopSharingMembers =
      '$baseUrl/api/journal/forecast/shared-users';
  static const String stopSharingForecast =
      '$baseUrl/api/journal/forecast/stop-sharing';
  static const String shareWeeklyForecast = '$baseUrl/api/journal/share/weekly';
  static const String stopSharingWeeklyForecast =
      '$baseUrl/api/journal/forecast/stop-sharing-weekly';
  static const String inviteLink = '$baseUrl/api/community/invite-link';
  static const String getCommunities = '$baseUrl/api/community/communities';
  static String getCommunityDetails(String communityId) =>
      '$baseUrl/api/community/overview?communityId=$communityId';

  // ========================
  // Profile Endpoints
  // ========================
  static const String getVendorProfile = '$baseUrl/auth/vendor/profile';
  static const String getUserCommunity = '$baseUrl/api/community/overview';
  static String getCommunityFeed(String communityId) =>
      '$baseUrl/api/community/feed/uploaded-images?communityId=$communityId';
  // static String getCommunityFeed(String communityId) =>
  //     '$baseUrl/api/community/feed?communityId=$communityId';

  // Feed Likes
  static String getFeedLikes(String feedId, String communityId) =>
      '$baseUrl/api/community/feed/today/$feedId/likes?communityId=$communityId';

  // ========================
  // Community Feed Endpoints
  // ========================
  static String getDailyFeed(
    String communityId, {
    String scope = 'me',
    String? date,
  }) =>
      '$baseUrl/api/community/$communityId/feed/daily?scope=$scope${date != null ? '&date=$date' : ''}';

  static String getWeeklyFeed(
    String communityId, {
    String scope = 'me',
    String? date,
  }) =>
      '$baseUrl/api/community/$communityId/feed/weekly?scope=$scope${date != null ? '&date=$date' : ''}';

  static String toggleFeedLike(String feedId) =>
      '$baseUrl/api/community/feed/today/$feedId/like';

  // Feed Comments
  static String getFeedComments(String entryOwnerId, String communityId) =>
      '$baseUrl/api/community/feed/today/$entryOwnerId/comments?communityId=$communityId';
  static String postFeedComment(String entryOwnerId) =>
      '$baseUrl/api/community/feed/today/$entryOwnerId/comments';

  // Remove Community Members
  static String removeCommunityMember(String memberId) =>
      '$baseUrl/api/community/members/$memberId';

  // Delete Notification
  static String deleteNotification(String notificationId) =>
      '$baseUrl/api/notifications/$notificationId';

  // Accept / Decline Invitation
  static String acceptInvite(String inviteId) =>
      '$baseUrl/api/community/invitations/$inviteId/accept';
  static String declineInvite(String inviteId) =>
      '$baseUrl/api/community/invitations/$inviteId/decline';

  // Get Community Members
  static String getCommunityMembers(String communityId) =>
      '$baseUrl/api/community/members?communityId=$communityId&status=active';

  static String updateCommunity(String communityId) =>
      '$baseUrl/api/community/$communityId';

  static const String getProfile = '$baseUrl/api/auth/profile';
  static const String updateNotesOfTheDay =
      '$baseUrl/api/journal/forecast/notes';
  static const String getWeeklyActivities = '$baseUrl/api/activities/weekly';
  static const String getMonthlyActivities = '$baseUrl/api/activities/monthly';
  static const String getAlltimeActivities = '$baseUrl/api/activities/all-time';
  static const String getOverallWeekly = '$baseUrl/api/analytics/weekly';
  static const String getOverallMonthly = '$baseUrl/api/analytics/monthly';
  static const String getOverallAlltime = '$baseUrl/api/analytics/all-time';
  static const String getUserProfile = '$baseUrl/auth/user/profile';
  static const String getForecastCommunityMembers =
      '$baseUrl/api/journal/share/members';
  static const String getCommunityInvites =
      '$baseUrl/api/community/invitations/me';
  static const String getUserDetails = '$baseUrl/api/home';
  static const String shareForecast = '$baseUrl/api/journal/share/email';
  static const String getUserEmotions = '$baseUrl/api/emotions';
  static const String getJournalSelection = '$baseUrl/api/journal/selection';
  static const String updateEndDay = '$baseUrl/api/journal/reflection';
  static const String updateForecast = '$baseUrl/api/journal/forecast';
  static const String deleteForecastEmotions =
      '$baseUrl/api/journal/forecast/emotions';
  static const String deleteReflectionEmotion =
      '$baseUrl/api/emotions/reflection';
  static const String updateForecastImages =
      '$baseUrl/api/journal/forecast/images';
  static const String updateCoreImages =
      '$baseUrl/api/journal/daily/core/images';
  static const String updateAspirationImages =
      '$baseUrl/api/journal/daily/aspiration/images';
  static const String updateCoreEmotions = '$baseUrl/api/journal/daily/core';
  static const String updateAspirationEmotions =
      '$baseUrl/api/journal/daily/aspiration';
  static const String updateEndDayImages =
      '$baseUrl/api/journal/reflection/images';
  static const String getForecast = '$baseUrl/api/journal/forecast';
  static const String thoughtMonitoringSettings =
      '$baseUrl/api/thought-monitoring/settings';
  static const String thoughtMonitoringCheckIn =
      '$baseUrl/api/thought-monitoring/check-in';
  static const String thoughtMonitoringCheckInsToday =
      '$baseUrl/api/thought-monitoring/check-ins/today';
  static const String saveCopiedForecast =
      '$baseUrl/api/journal/forecast/save-copied';
  static const String appUsageTime = '$baseUrl/api/app-usage/heartbeat';
  static const String getEndDay = '$baseUrl/api/journal/end-day';
  static const String getComparison = '$baseUrl/api/journal/comparison';
  static const String getAnalytics = '$baseUrl/api/analytics/overview';
  static const String getAnalyticsCalendar = '$baseUrl/api/analytics/calendar';
  static const String getCalendarMonthAnalytics =
      '$baseUrl/api/analytics/calendar/month';
  static const String getActivities = '$baseUrl/api/activities/selections';
  static const String getTodayActivities = '$baseUrl/api/activities/selections';
  static const String getPlannedActivities = '$baseUrl/api/activities/planned';
  static const String getForecastActivities =
      '$baseUrl/api/activities/forecast';
  static const String removeActivities = '$baseUrl/api/activities/selections';
  static const String deleteTodayActivity =
      '$baseUrl/api/activities/selections';
  static const String vendorProfileUpdate = '$baseUrl/auth/vendor/edit-profile';
  static const String profileUpdate = '$baseUrl/api/auth/profile';
  static const String vendorHoursUpdate = '$baseUrl/auth/vendor/hours';
  static const String uploadProduct = '$baseUrl/auth/vendor/menu/upload';
  static const String deleteProduct = '$baseUrl/auth/vendor/menu';
  static const String getVendorReviews = '$baseUrl/auth/vendor/reviews';
  static const String updateActivity = '$baseUrl/api/activities/selections';
  static const String forecastAsYesterday =
      '$baseUrl/api/journal/forecast/copy-yesterday';
  static const String addUserReview = '$baseUrl/auth/reviews';
  static const String addVendorReview = '$baseUrl/auth/user/rating';
  static const String searchVendors = '$baseUrl/auth/vendors/search';
  static const String getNotifications = '$baseUrl/api/notifications';
  static const String markNotificationsRead = '$baseUrl/api/notifications/read';
  static const String editProduct =
      '$baseUrl/auth/vendor/menu/edit/'; // $baseUrl/auth/vendor/menu/edit/productId

  static const String removeFromFavorites = '$baseUrl/auth/remove-favorite';

  // ========================
  // Upload Endpoints
  // ========================
  static const String uploadImage = '$baseUrl/api/uploads/emotion-image';

  // ====================
  // Notifications Endpoints //TODO: Update endpoints
  // ====================
  // static const String saveTokenVendor = '$baseUrl/api/auth/vendor/save-token';
  static const String saveTokenUser = '$baseUrl/api/auth/user/save-token';
  static const String pushNotificationUser =
      '$baseUrl/api/auth/user/push-notification';
  static const String registerFcmToken =
      '$baseUrl/api/notifications/fcm-token/register';
  static const String notificationSettings =
      '$baseUrl/api/notifications/settings';
  // static const String pushNotificationVendor =
  //     '$baseUrl/auth/vendor/push-notification'; //Not implemented on backend
}
