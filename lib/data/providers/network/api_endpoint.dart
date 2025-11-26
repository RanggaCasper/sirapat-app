import 'package:get/get.dart';
import 'package:sirapat_app/app/config/app_constants.dart';
import 'package:sirapat_app/presentation/controllers/auth_controller.dart';

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

  // Meeting endpoints - Dynamic based on role
  static String get meetings {
    try {
      final authController = Get.find<AuthController>();
      final userRole =
          authController.currentUser?.role?.toLowerCase() ?? 'employee';

      if (userRole == 'admin' || userRole == 'master') {
        return "$baseUrl/admin/meeting";
      }
      return "$baseUrl/employee/meeting";
    } catch (e) {
      return "$baseUrl/employee/meeting";
    }
  }

  // // Endpoint khusus admin
  // static String get meetingsAdmin => "$baseUrl/admin/meeting";

  // // Endpoint khusus employee
  // static String get meetingsEmployee => "$baseUrl/employee/meeting";
}
