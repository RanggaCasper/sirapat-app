import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sirapat_app/domain/entities/user.dart';
import 'package:sirapat_app/domain/usecases/login_usecase.dart';
import 'package:sirapat_app/domain/usecases/register_usecase.dart';
import 'package:sirapat_app/domain/usecases/get_current_user_usecase.dart';
import 'package:sirapat_app/domain/repositories/auth_repository.dart';
import 'package:sirapat_app/data/models/api_exception.dart';

class AuthController extends GetxController {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final AuthRepository _authRepository;

  AuthController(
    this._loginUseCase,
    this._registerUseCase,
    this._getCurrentUserUseCase,
    this._authRepository,
  );

  final Rx<User?> _currentUser = Rx<User?>(null);
  final RxBool isLoadingObs = false.obs;
  final RxString _errorMessage = ''.obs;
  final RxMap<String, String> fieldErrors = <String, String>{}.obs;
  final RxBool obscurePassword = true.obs;

  User? get currentUser => _currentUser.value;
  bool get isLoading => isLoadingObs.value;
  String get errorMessage => _errorMessage.value;
  bool get isLoggedIn => _currentUser.value != null;

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  @override
  void onInit() {
    super.onInit();
    _checkCurrentUser();
  }

  Future<void> _checkCurrentUser() async {
    try {
      final user = await _getCurrentUserUseCase.execute();
      _currentUser.value = user;
    } catch (e) {
      // ignore: avoid_print
      print('Error checking current user: $e');
    }
  }

  Future<void> login(String nip, String password) async {
    try {
      isLoadingObs.value = true;
      _errorMessage.value = '';
      fieldErrors.clear(); // Clear previous errors

      final user = await _loginUseCase.execute(
        LoginParams(nip: nip, password: password),
      );

      _currentUser.value = user;

      // Show success toast after frame is built
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.snackbar(
          'Login Berhasil',
          'Selamat datang, ${user.fullName}!',
          backgroundColor: Colors.green.shade400,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
          margin: const EdgeInsets.all(10),
        );
      });

      // Navigate to home page
      Get.offAllNamed('/home');
    } on ApiException catch (e) {
      print('Controller - ApiException caught');
      print('Message: ${e.message}');
      print('Errors: ${e.errors}');

      _errorMessage.value = e.message;

      // Show error toast after frame is built
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.snackbar(
          'Login Gagal',
          e.message,
          backgroundColor: Colors.red.shade400,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(10),
        );
      });

      // Set field-specific errors
      if (e.errors != null && e.errors!.isNotEmpty) {
        e.errors!.forEach((field, messages) {
          if (messages.isNotEmpty) {
            fieldErrors[field] = messages.first;
            print('Setting error for field $field: ${messages.first}');
          }
        });
      } else {
        // If no field-specific errors, set general error to NIP field
        fieldErrors['nip'] = e.message;
        print('No field errors, setting general error: ${e.message}');
      }
    } catch (e) {
      print('Controller - Generic exception: $e');
      _errorMessage.value = e.toString();

      // Parse error message for better user experience
      String errorMsg = e.toString();
      String toastMsg = '';

      if (errorMsg.contains('No Internet connection') ||
          errorMsg.contains('fetch-data')) {
        toastMsg =
            'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.';
        fieldErrors['nip'] = toastMsg;
      } else if (errorMsg.contains('Connection refused')) {
        toastMsg =
            'Server tidak merespons. Pastikan backend API sudah berjalan.';
        fieldErrors['nip'] = toastMsg;
      } else if (errorMsg.contains('422')) {
        toastMsg = 'Data tidak valid. Periksa NIP dan password Anda.';
        fieldErrors['nip'] = toastMsg;
      } else if (errorMsg.contains('timeout')) {
        toastMsg = 'Koneksi timeout. Periksa koneksi internet Anda.';
        fieldErrors['nip'] = toastMsg;
      } else {
        toastMsg = 'Login gagal: ${errorMsg.replaceAll('Exception: ', '')}';
        fieldErrors['nip'] = toastMsg;
      }

      // Show error toast after frame is built
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.snackbar(
          'Error',
          toastMsg,
          backgroundColor: Colors.red.shade400,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(10),
        );
      });
    } finally {
      isLoadingObs.value = false;
    }
  }

  String? getFieldError(String fieldName) {
    return fieldErrors[fieldName];
  }

  void clearFieldError(String fieldName) {
    fieldErrors.remove(fieldName);
  }

  Future<void> register({
    required String nip,
    required String username,
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      isLoadingObs.value = true;
      _errorMessage.value = '';
      fieldErrors.clear(); // Clear previous errors

      final user = await _registerUseCase.execute(
        RegisterParams(
          nip: nip,
          username: username,
          fullName: fullName,
          email: email,
          phone: phone,
          password: password,
          passwordConfirmation: passwordConfirmation,
        ),
      );

      _currentUser.value = user;

      // Show success toast after frame is built
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.snackbar(
          'Registrasi Berhasil',
          'Selamat datang, ${user.fullName}!',
          backgroundColor: Colors.green.shade400,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
          margin: const EdgeInsets.all(10),
        );
      });

      // Navigate to home page
      Get.offAllNamed('/home');
    } on ApiException catch (e) {
      print('Controller - Register ApiException caught');
      print('Message: ${e.message}');
      print('Errors: ${e.errors}');

      _errorMessage.value = e.message;

      // Show error toast after frame is built
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.snackbar(
          'Registrasi Gagal',
          e.message,
          backgroundColor: Colors.red.shade400,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(10),
        );
      });

      // Set field-specific errors
      if (e.errors != null && e.errors!.isNotEmpty) {
        e.errors!.forEach((field, messages) {
          if (messages.isNotEmpty) {
            fieldErrors[field] = messages.first;
            print('Setting error for field $field: ${messages.first}');
          }
        });
      }
    } catch (e) {
      print('Controller - Register Generic exception: $e');
      _errorMessage.value = e.toString();

      String errorMsg = e.toString();
      String toastMsg =
          'Registrasi gagal: ${errorMsg.replaceAll('Exception: ', '')}';

      fieldErrors['nip'] = toastMsg;

      // Show error toast after frame is built
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.snackbar(
          'Error',
          toastMsg,
          backgroundColor: Colors.red.shade400,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(10),
        );
      });
    } finally {
      isLoadingObs.value = false;
    }
  }

  Future<void> logout() async {
    try {
      isLoadingObs.value = true;
      await _authRepository.logout();
      _currentUser.value = null;
      Get.offAllNamed('/login');
    } catch (e) {
      Get.snackbar(
        'Error',
        'Logout failed: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingObs.value = false;
    }
  }
}
