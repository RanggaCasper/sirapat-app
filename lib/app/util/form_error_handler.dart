import 'package:get/get.dart';
import 'package:sirapat_app/data/models/api_exception.dart';
import 'package:sirapat_app/presentation/shared/widgets/custom_notification.dart';

class FormErrorHandler {
  static Map<String, String> handleApiException(
    ApiException e) {
    final Map<String, String> fieldErrors = {};

    // Set field-specific errors dari API response
    if (e.errors != null && e.errors!.isNotEmpty) {
      e.errors!.forEach((field, messages) {
        if (messages.isNotEmpty) {
          fieldErrors[field] = messages.first;
        }
      });
    } else {
      final notif = Get.find<NotificationController>();
      notif.showError(e.message);
    }

    return fieldErrors;
  }

  /// Clear specific field error
  static void clearFieldError(
    RxMap<String, String> fieldErrors,
    String fieldName,
  ) {
    fieldErrors.remove(fieldName);
  }

  /// Clear all field errors
  static void clearAllFieldErrors(RxMap<String, String> fieldErrors) {
    fieldErrors.clear();
  }

  /// Get error message for specific field
  static String? getFieldError(
    Map<String, String> fieldErrors,
    String fieldName,
  ) {
    return fieldErrors[fieldName];
  }

  /// Check if field has error
  static bool hasFieldError(Map<String, String> fieldErrors, String fieldName) {
    return fieldErrors.containsKey(fieldName);
  }
}
