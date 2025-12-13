import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:sirapat_app/app/config/app_constants.dart';
import 'package:sirapat_app/presentation/controllers/auth_controller.dart';

class APIEndpoint {
  static const String _apiVersion = AppConstants.apiVersion;

  // Use production URL or fallback to local development
  static String get baseUrl => "${AppConstants.baseUrl}/api/$_apiVersion";

  // Auth endpoints
  static String get login => "$baseUrl/auth/login";
  static String get updateDivision => "$baseUrl/auth/update-division";
  static String get register => "$baseUrl/auth/register";
  static String get logout => "$baseUrl/auth/logout";
  static String get currentUser => "$baseUrl/auth/profile";
  static String get updateProfile => "$baseUrl/profile/update";
  static String get resetPassword => "$baseUrl/profile/reset-password";
  // static String get divisions => "$baseUrl/master/division";
  static String get users => "$baseUrl/master/user";
  static String get chatMinutes => "$baseUrl/chat-minute";
  // static String get attendace => "$baseUrl/admin/attendance";
  static String get participants => "$baseUrl/admin/meeting-participant";
  // static String get meetingMinutes => "$baseUrl/admin/meeting-minute";

  // Audio & AI endpoints
  static String get audioUpload => "$baseUrl/audio/upload";
  static String get summarizeMinutes => "$baseUrl/summarize/minutes";

  // Meeting endpoints - Dynamic based on role
  static String get meetings {
    try {
      final authController = Get.find<AuthController>();
      final currentUser = authController.currentUser;

      debugPrint('[APIEndpoint] Current user: ${currentUser?.fullName}');

      if (currentUser == null) {
        debugPrint(
          '[APIEndpoint] WARNING: User not loaded yet, defaulting to employee',
        );
        return "$baseUrl/employee/meeting";
      }

      final userRole = currentUser.role?.toLowerCase() ?? 'employee';
      debugPrint('[APIEndpoint] User role: $userRole');

      if (userRole == 'admin' || userRole == 'master') {
        final endpoint = "$baseUrl/admin/meeting";
        debugPrint('[APIEndpoint] Using admin endpoint: $endpoint');
        return endpoint;
      }
      final endpoint = "$baseUrl/employee/meeting";
      debugPrint('[APIEndpoint] Using employee endpoint: $endpoint');
      return endpoint;
    } catch (e) {
      debugPrint('[APIEndpoint] Error getting role, defaulting to employee: $e');
      return "$baseUrl/employee/meeting";
    }
  }

  static String get attendace {
    try {
      final authController = Get.find<AuthController>();
      final userRole =
          authController.currentUser?.role?.toLowerCase() ?? 'employee';

      if (userRole == 'admin' || userRole == 'master') {
        return "$baseUrl/admin/attendance";
      }
      return "$baseUrl/employee/attendance";
    } catch (e) {
      return "$baseUrl/employee/attendance";
    }
  }

  static String get divisions {
    try {
      final authController = Get.find<AuthController>();
      final userRole =
          authController.currentUser?.role?.toLowerCase() ?? 'employee';

      if (userRole == 'master') {
        return "$baseUrl/master/division";
      }
      return "$baseUrl/profile/get-division";
    } catch (e) {
      return "$baseUrl/profile/get-division";
    }
  }

  static String get meetingMinutes {
    try {
      final authController = Get.find<AuthController>();
      final userRole =
          authController.currentUser?.role?.toLowerCase() ?? 'employee';

      if (userRole == 'admin' || userRole == 'master') {
        return "$baseUrl/admin/meeting-minute";
      }
      return "$baseUrl/employee/meeting-minute";
    } catch (e) {
      return "$baseUrl/employee/meeting-minute";
    }
  }
  // // Endpoint khusus admin
  // static String get meetingsAdmin => "$baseUrl/admin/meeting";

  // // Endpoint khusus employee
  // static String get meetingsEmployee => "$baseUrl/employee/meeting";
}
