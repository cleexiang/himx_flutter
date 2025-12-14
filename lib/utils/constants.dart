class AppConstants {
  // API Endpoints
  static const String loginEndpoint = '/auth/login/device';
  static const String loginWithAppleEndpoint = '/auth/login/apple';
  static const String userInfoEndpoint = '/rest/v1/user/info';
  static const String checkRevenuecatStatusEndpoint = '/rest/v1/order/revenuecat/checkstatus';
  static const String uploadImageEndpoint = '/rest/v1/ghostcamera/file/upload';
  static const String generateGhostImageEndpoint = '/rest/v1/ghostcamera/image/generate';
  static const String generateGhostVideoEndpoint = '/rest/v1/ghostcamera/video/generate';
  static const String galleryEndpoint = '/rest/v1/ghostcamera/my/gallerys';
  static const String videoStatusEndpoint = '/rest/v1/ghostcamera/video/status';

  // App Settings
  static const String appName = 'GhostSnap';
  static const String appVersion = '1.0.0';

  // Subscription Plans
  static const String monthlyPlanId = 'ghostsnap_monthly';
  static const String yearlyPlanId = 'ghostsnap_yearly';
  static const String lifetimePlanId = 'ghostsnap_lifetime';

  // Credits
  static const int freeUserInitialCredits = 20;
  static const int photoGenerationCost = 10;
  static const int videoGenerationCost = 30;
  static const int memberMonthlyCredits = 200;

  // Storage Keys
  static const String userTokenKey = 'user_token';
  static const String userKey = 'user_data';
  static const String userCreditsKey = 'user_credits';
  static const String userBirthdayKey = 'user_birthday';
  static const String isFirstLaunchKey = 'is_first_launch';
  static const String isMemberKey = 'is_member';

  // Horror Levels
  static const int minHorrorLevel = 1;
  static const int maxHorrorLevel = 3;
}
