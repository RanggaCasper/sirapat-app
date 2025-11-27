class AppConstants {
  static const String appName = 'Sirapat App';

  // API Configuration
  static const String host = '172.22.39.51'; // Default: '127.0.0.1'
  static const String port = '8001'; // Default: '8000'
  static const String apiVersion = 'v1';
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Storage Keys
  static const String storageKeyUser = 'user';
  static const String storageKeyToken = 'token';
  static const String storageKeyTheme = 'theme';

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
}
