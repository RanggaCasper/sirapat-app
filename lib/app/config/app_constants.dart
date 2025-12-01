class AppConstants {
  static const String appName = 'Sirapat App';

  // API Configuration
  static const String host = '127.0.0.1'; // Default: '127.0.0.1'
  static const String port = '8000'; // Default: '8000'
  static const String apiVersion = 'v1';
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Storage Keys
  static const String storageKeyUser = 'user';
  static const String storageKeyToken = 'token';
  static const String storageKeyTheme = 'theme';

  // Pagination
  static const int defaultPageSize = 10;
  static const int maxPageSize = 100;

  // Durations
  static const Duration splashDuration = Duration(seconds: 2);
  static const Duration notificationDuration = Duration(seconds: 3);
  static const Duration shortDelay = Duration(seconds: 1);
  static const Duration mediumDelay = Duration(seconds: 2);
  static const Duration apiTimeout = Duration(seconds: 10);

  // Reverb WebSocket Configuration
  static const int reverbPort = 8080;
  static const String reverbScheme = 'http';
}
