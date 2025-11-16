import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sirapat_app/data/models/api_exception.dart';
import 'package:sirapat_app/data/providers/network/requests/forgot_password_request.dart';
import 'package:sirapat_app/data/providers/network/requests/reset_password_request.dart';

class ForgotPasswordController extends GetxController {
  final isLoading = false.obs;
  final isOtpSent = false.obs;
  final fieldErrors = <String, String?>{}.obs;
  final retryAfter = 0.obs;
  final lastEmail = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Start countdown if there's retry_after
    ever(retryAfter, (value) {
      if (value > 0) {
        _startCountdown();
      }
    });
  }

  void _startCountdown() {
    Future.delayed(const Duration(seconds: 1), () {
      if (retryAfter.value > 0) {
        retryAfter.value--;
        if (retryAfter.value > 0) {
          _startCountdown();
        }
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
      Get.snackbar(
        'Error',
        'Terlalu banyak percobaan. Coba lagi dalam ${retryAfter.value} detik.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    try {
      isLoading.value = true;
      fieldErrors.clear();
      lastEmail.value = email;

      final request = ForgotPasswordRequest(email: email);
      final response = await request.request();

      print('Send OTP Response: $response');

      // Check if response is successful
      if (response is Map<String, dynamic>) {
        if (response['status'] == true) {
          isOtpSent.value = true;
          retryAfter.value = 0; // Reset retry counter on success
          Get.snackbar(
            'Berhasil',
            response['message'] ?? 'OTP telah dikirim ke email Anda',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
          );
        } else {
          // Handle error response with retry_after
          if (response['errors'] != null &&
              response['errors']['retry_after'] != null) {
            retryAfter.value = response['errors']['retry_after'] as int;
            Get.snackbar(
              'Error',
              response['message'] ??
                  'Terlalu banyak percobaan. Coba lagi dalam ${retryAfter.value} detik.',
              snackPosition: SnackPosition.TOP,
              backgroundColor: Colors.red,
              colorText: Colors.white,
              duration: const Duration(seconds: 3),
            );
          } else {
            throw ApiException.fromJson(response);
          }
        }
      }
    } on ApiException catch (e) {
      print('Send OTP ApiException: ${e.message}');
      Get.snackbar(
        'Error',
        e.message,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );

      if (e.errors != null) {
        e.errors!.forEach((key, value) {
          if (value.isNotEmpty) {
            fieldErrors[key] = value.first;
          }
        });
      }
    } catch (e) {
      print('Send OTP Error: $e');
      Get.snackbar(
        'Error',
        'Terjadi kesalahan: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
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

      print('Reset Password Response: $response');

      // Check if response is successful
      if (response is Map<String, dynamic> && response['status'] == true) {
        Get.snackbar(
          'Berhasil',
          response['message'] ?? 'Password berhasil direset',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );

        // Navigate back to login page
        await Future.delayed(const Duration(seconds: 2));
        Get.offAllNamed('/login');
      } else {
        throw ApiException.fromJson(response);
      }
    } on ApiException catch (e) {
      print('Reset Password ApiException: ${e.message}');
      Get.snackbar(
        'Error',
        e.message,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );

      if (e.errors != null) {
        e.errors!.forEach((key, value) {
          if (value.isNotEmpty) {
            fieldErrors[key] = value.first;
          }
        });
      }
    } catch (e) {
      print('Reset Password Error: $e');
      Get.snackbar(
        'Error',
        'Terjadi kesalahan: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }
}
