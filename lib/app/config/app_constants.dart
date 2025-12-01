class AppConstants {
  static const String appName = 'SiRapat App';

  // Environment Configuration
  // 🔴 Set to true for PRODUCTION, false for LOCAL DEVELOPMENT
  static const bool isProduction = true;

  // API Configuration
  static const String productionUrl = 'https://sirapat.my.id';
  static const String localHost = '127.0.0.1';
  static const String localPort = '8000';
  
  // Auto-switch between production and local
  static String get baseUrl => isProduction 
      ? productionUrl 
      : 'http://$localHost:$localPort';
  
  // Legacy (for backward compatibility)
  static const String host =
      '127.0.0.1'; // Default: '127.0.0.1' (for local development)
  static const String port = '8000'; // Default: '8000' (for local development)
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
