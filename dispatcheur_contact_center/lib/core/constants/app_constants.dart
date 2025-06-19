class AppConstants {
  static const String appName = 'DispatcheurCC';
  static const String appVersion = '1.0.0';

  // Storage Keys
  static const String userStorageKey = 'user';
  static const String credentialsStorageKey = 'voip_credentials';
  static const String settingsStorageKey = 'app_settings';
  static const String microphoneStorageKey = 'voip-selected-microphone';
  static const String speakerStorageKey = 'voip-selected-speaker';
  static const String callHistoryStorageKey = 'voip-call-history';
  static const String quickNotesStorageKey = 'voip-quick-notes';

  // Call Limits
  static const int maxConcurrentCalls = 10;
  static const int maxCallHistoryItems = 50;
  static const int maxQuickNotes = 100;

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration callTimeout = Duration(seconds: 60);
  static const Duration retryDelay = Duration(seconds: 2);

  // Audio
  static const Duration maxRingtoneTime = Duration(minutes: 1);
  static const Duration dtmfToneDuration = Duration(milliseconds: 100);

  // UI
  static const double fabSize = 56.0;
  static const double cardBorderRadius = 16.0;
  static const double dialogBorderRadius = 20.0;

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
}
