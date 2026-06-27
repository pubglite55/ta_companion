class AppConstants {
  AppConstants._();

  static const String appName = 'TA';
  static const String defaultCompanionName = 'TA';
  static const String defaultCompanionPersonality = '温柔亲密';

  static const int maxRetryAttempts = 3;
  static const Duration retryDelay = Duration(seconds: 3);
  static const Duration cacheExpiry = Duration(days: 3);

  static const Map<int, String> notificationTimes = {
    7: '早安问候',
    12: '午间分享',
    18: '晚间聊天',
    21: '睡前关怀',
  };
}
