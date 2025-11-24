import 'package:sirapat_app/app/config/app_constants.dart';

class APIEndpoint {
  static const String _host = AppConstants.host;
  static const String _port = AppConstants.port;
  static const String _apiVersion = AppConstants.apiVersion;

  static String get baseUrl => "http://$_host:$_port/api/$_apiVersion";

  // Auth endpoints
  static String get login => "$baseUrl/auth/login";
  static String get register => "$baseUrl/auth/register";
  static String get logout => "$baseUrl/auth/logout";
  static String get currentUser => "$baseUrl/auth/profile";
  static String get resetPassword => "$baseUrl/profile/reset-password";
  static String get divisions => "$baseUrl/master/division";
  static String get users => "$baseUrl/master/user";
  static String get meetings => "$baseUrl/admin/meeting";
}
