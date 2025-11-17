import 'package:get/get.dart';
import 'package:sirapat_app/data/models/api_exception.dart';
import 'package:sirapat_app/data/providers/network/requests/forgot_password_request.dart';
import 'package:sirapat_app/data/providers/network/requests/reset_password_request.dart';
import 'package:sirapat_app/presentation/widgets/custom_notification.dart';

class ForgotPasswordController extends GetxController {
  final isLoading = false.obs;
  final isOtpSent = false.obs;
  final fieldErrors = <String, String?>{}.obs;
  final retryAfter = 0.obs;
  final lastEmail = ''.obs;
  bool _isCountingDown = false;

  NotificationController get _notif => Get.find<NotificationController>();

  @override
  void onInit() {
    super.onInit();
    // Start countdown if there's retry_after
    ever(retryAfter, (value) {
      if (value > 0 && !_isCountingDown) {
        _startCountdown();
      }
    });
  }

  void _startCountdown() {
    if (_isCountingDown) return;

    _isCountingDown = true;
    Future.delayed(const Duration(seconds: 1), () {
      if (retryAfter.value > 0) {
        retryAfter.value--;
        if (retryAfter.value > 0) {
          _isCountingDown = false;
          _startCountdown();
        } else {
          _isCountingDown = false;
        }
      } else {
        _isCountingDown = false;
      }
    });
  }

  void clearFieldError(String field) {
    fieldErrors[field] = null;
  }

  String? getFieldError(String field) {
    return fieldErrors[field];
  }

  Future<void> sendOtp(String email) async {
    if (isLoading.value) return;

    // Check if still in cooldown for same email
    if (retryAfter.value > 0 && lastEmail.value == email) {
      _notif.showError(
        'Terlalu banyak percobaan. Coba lagi dalam ${retryAfter.value} detik.',
      );
      return;
    }

    try {
      isLoading.value = true;
      fieldErrors.clear();
      lastEmail.value = email;

      final request = ForgotPasswordRequest(email: email);
      final response = await request.request();

      // Check if response is successful
      if (response is Map<String, dynamic>) {
        if (response['status'] == true) {
          isOtpSent.value = true;
          retryAfter.value = 0;
          _notif.showSuccess(response['message']);
        } else {
          // Handle error response with retry_after
          if (response['errors'] != null &&
              response['errors']['retry_after'] != null) {
            retryAfter.value = response['errors']['retry_after'] as int;
            _notif.showError(
              response['message'] ??
                  'Terlalu banyak percobaan. Coba lagi dalam ${retryAfter.value} detik.',
            );
          } else {
            throw ApiException.fromJson(response);
          }
        }
      }
    } on ApiException catch (e) {
      _notif.showError(e.message);

      if (e.errors != null) {
        e.errors!.forEach((key, value) {
          if (value.isNotEmpty) {
            fieldErrors[key] = value.first;
          }
        });
      }
    } catch (e) {
      _notif.showError('Terjadi kesalahan: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resetPassword({
    required String email,
    required String otp,
    required String password,
    required String passwordConfirmation,
  }) async {
    if (isLoading.value) return;

    try {
      isLoading.value = true;
      fieldErrors.clear();

      final request = ResetPasswordRequest(
        email: email,
        otp: otp,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      final response = await request.request();

      // Check if response is successful
      if (response is Map<String, dynamic> && response['status'] == true) {
        _notif.showSuccess(response['message'] ?? 'Password berhasil direset');

        await Future.delayed(const Duration(seconds: 2));
        Get.offAllNamed('/login');
      } else {
        throw ApiException.fromJson(response);
      }
    } on ApiException catch (e) {
      _notif.showError(e.message);

      if (e.errors != null) {
        e.errors!.forEach((key, value) {
          if (value.isNotEmpty) {
            fieldErrors[key] = value.first;
          }
        });
      }
    } catch (e) {
      _notif.showError('Terjadi kesalahan: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }
}
