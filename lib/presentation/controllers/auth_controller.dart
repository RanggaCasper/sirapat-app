import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:sirapat_app/app/routes/app_routes.dart';
import 'package:sirapat_app/app/util/form_error_handler.dart';
import 'package:sirapat_app/domain/entities/user.dart';
import 'package:sirapat_app/domain/usecases/login_usecase.dart';
import 'package:sirapat_app/domain/usecases/register_usecase.dart';
import 'package:sirapat_app/domain/usecases/get_current_user_usecase.dart';
import 'package:sirapat_app/domain/usecases/auth/reset_password_usecase.dart';
import 'package:sirapat_app/domain/repositories/auth_repository.dart';
import 'package:sirapat_app/data/models/api_exception.dart';
import 'package:sirapat_app/presentation/shared/widgets/custom_notification.dart';

class AuthController extends GetxController {
  // Dependencies
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final ResetPasswordUseCase _resetPasswordUseCase;
  final AuthRepository _authRepository;

  AuthController(
    this._loginUseCase,
    this._registerUseCase,
    this._getCurrentUserUseCase,
    this._resetPasswordUseCase,
    this._authRepository,
  );

  // Reactive state
  final Rx<User?> _currentUser = Rx<User?>(null);
  final RxBool _isLoading = false.obs;
  final RxString _errorMessage = ''.obs;
  final RxMap<String, String> _fieldErrors = <String, String>{}.obs;
  final RxBool _obscurePassword = true.obs;

  // Getters for reactive state
  User? get currentUser => _currentUser.value;
  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;
  Map<String, String> get fieldErrors => _fieldErrors;
  bool get obscurePassword => _obscurePassword.value;
  bool get isLoggedIn => _currentUser.value != null;
  String? get userRole => _currentUser.value?.role?.toLowerCase();

  // Notification helper
  NotificationController get _notif => Get.find<NotificationController>();

  @override
  void onInit() {
    super.onInit();
    _checkCurrentUser();
  }

  // Toggle password visibility
  void togglePasswordVisibility() {
    _obscurePassword.toggle();
  }

  // Get field-specific error message
  String? getFieldError(String fieldName) {
    return FormErrorHandler.getFieldError(_fieldErrors, fieldName);
  }

  // Clear specific field error
  void clearFieldError(String fieldName) {
    FormErrorHandler.clearFieldError(_fieldErrors, fieldName);
  }

  // Clear all errors
  void clearAllErrors() {
    _errorMessage.value = '';
    FormErrorHandler.clearAllFieldErrors(_fieldErrors);
  }

  // Check current user from local storage
  Future<void> _checkCurrentUser() async {
    try {
      final user = await _getCurrentUserUseCase.execute();
      _currentUser.value = user;
    } catch (e) {
      debugPrint('[AuthController] Error checking current user: $e');
      _currentUser.value = null;
    }
  }

  // Verify user authentication status from server
  // Returns true if user is authenticated and has valid session
  Future<bool> verifyAuthentication() async {
    try {
      _setLoading(true);

      // First check local storage
      final localUser = await _getCurrentUserUseCase.execute();
      if (localUser == null) {
        _currentUser.value = null;
        return false;
      }

      // Then verify with server
      final verifiedUser = await _authRepository.verifyUserFromServer();

      if (verifiedUser != null) {
        _currentUser.value = verifiedUser;
        return true;
      }

      _currentUser.value = null;
      return false;
    } catch (e) {
      debugPrint('[AuthController] Verification failed: $e');
      _currentUser.value = null;
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Check if user has specific role
  bool hasRole(String requiredRole) {
    return userRole == requiredRole.toLowerCase();
  }

  // Verify user and redirect to login if not authenticated
  Future<bool> verifyOrRedirect({String? requiredRole}) async {
    final isAuthenticated = await verifyAuthentication();

    if (!isAuthenticated) {
      _notif.showError('Sesi Anda telah berakhir. Silakan login kembali.');
      Get.offAllNamed(AppRoutes.login);
      return false;
    }

    if (requiredRole != null && !hasRole(requiredRole)) {
      _notif.showError('Anda tidak memiliki akses ke halaman ini.');
      await logout();
      return false;
    }

    return true;
  }

  // Login with NIP and password
  Future<void> login(String nip, String password) async {
    try {
      _setLoading(true);
      clearAllErrors();

      final user = await _loginUseCase.execute(
        LoginParams(nip: nip, password: password),
      );

      _currentUser.value = user;
      _notif.showSuccess('Selamat datang, ${user.fullName}!');

      // Navigate based on role
      _navigateToRoleDashboard(user.role);
    } on ApiException catch (e) {
      _handleApiException(e);
    } catch (e) {
      _handleGenericError(e);
    } finally {
      _setLoading(false);
    }
  }

  // Register new user
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
      _setLoading(true);
      clearAllErrors();

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
      _notif.showSuccess(
        'Registrasi berhasil! Selamat datang, ${user.fullName}!',
      );

      // Navigate based on role
      _navigateToRoleDashboard(user.role);
    } on ApiException catch (e) {
      _handleApiException(e);
    } catch (e) {
      _handleGenericError(e);
    } finally {
      _setLoading(false);
    }
  }

  // Logout current user
  Future<void> logout() async {
    try {
      _setLoading(true);
      await _authRepository.logout();
      _currentUser.value = null;
      clearAllErrors();
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      _notif.showError('Gagal logout: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Reset/change user password
  Future<void> resetPassword({
    required String oldPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    try {
      _setLoading(true);
      clearAllErrors();

      await _resetPasswordUseCase.execute(
        ResetPasswordParams(
          oldPassword: oldPassword,
          newPassword: newPassword,
          newPasswordConfirmation: newPasswordConfirmation,
        ),
      );

      _notif.showSuccess('Password berhasil diubah');
      Get.back(); // Close the dialog/page
    } on ApiException catch (e) {
      _handleApiException(e);
    } catch (e) {
      _handleGenericError(e);
    } finally {
      _setLoading(false);
    }
  }

  // Set loading state
  void _setLoading(bool value) {
    _isLoading.value = value;
  }

  // Navigate to role-specific dashboard
  void _navigateToRoleDashboard(String? role) {
    switch (role?.toLowerCase()) {
      case 'master':
        Get.offAllNamed(AppRoutes.masterDashboard);
        break;
      case 'admin':
        Get.offAllNamed(AppRoutes.adminDashboard);
        break;
      case 'employee':
        Get.offAllNamed(AppRoutes.employeeDashboard);
        break;
      default:
        _notif.showError('Role tidak valid');
        Get.offAllNamed(AppRoutes.login);
    }
  }

  // Handle API exceptions with field errors using global handler
  void _handleApiException(ApiException e) {
    _errorMessage.value = e.message;

    // Use global form error handler
    final errors = FormErrorHandler.handleApiException(e);
    _fieldErrors.addAll(errors);
  }

  // Handle generic errors
  void _handleGenericError(dynamic e) {
    final errorMsg = e.toString();
    _errorMessage.value = errorMsg;
    _notif.showError(errorMsg);
  }
}
