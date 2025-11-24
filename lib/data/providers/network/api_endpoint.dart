import 'package:sirapat_app/app/config/app_constants.dart';
import 'package:get_storage/get_storage.dart';

class APIEndpoint {
  static const String _host = AppConstants.host;
  static const String _port = AppConstants.port;
  static const String _apiVersion = AppConstants.apiVersion;

  static String get baseUrl => "http://$_host:$_port/api/$_apiVersion";

  static final storage = GetStorage();

  static String get role => storage.read("role") ?? 'employee';

  static String byRole(String path) => "$baseUrl/$role/$path";

  // Auth
  static String get login => "$baseUrl/auth/login";
  static String get register => "$baseUrl/auth/register";
  static String get logout => "$baseUrl/auth/logout";
  static String get currentUser => "$baseUrl/auth/profile";

  // Master / Admin / Employee endpoint
  static String get divisions => byRole("division");
  static String get users => byRole("user");
  static String get meetings => byRole("meeting");
}
