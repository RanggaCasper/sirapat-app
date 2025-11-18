import 'package:get/get.dart';
import 'package:sirapat_app/domain/entities/user.dart';
import 'package:sirapat_app/domain/usecases/login_usecase.dart';
import 'package:sirapat_app/domain/usecases/register_usecase.dart';
import 'package:sirapat_app/domain/usecases/get_current_user_usecase.dart';
import 'package:sirapat_app/domain/repositories/auth_repository.dart';
import 'package:sirapat_app/data/models/api_exception.dart';
import 'package:sirapat_app/presentation/widgets/custom_notification.dart';

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

  NotificationController get _notif => Get.find<NotificationController>();

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

      _notif.showSuccess('Selamat datang, ${user.fullName}!');

      if (user.role == 'master') {
        Get.offAllNamed('/master-dashboard');
      } else if (user.role == 'admin') {
        Get.offAllNamed('/admin-dashboard');
      } else if (user.role == 'employee') {
        Get.offAllNamed('/employee-dashboard');
      } else {
        _notif.showError('Belum login atau role tidak valid');
        Get.offAllNamed('/login');
      }
    } on ApiException catch (e) {
      _errorMessage.value = e.message;

      _notif.showError(e.message);

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
      String errorMsg = e.toString();
      _notif.showError(errorMsg);
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

      _notif.showSuccess(
        'Registrasi berhasil! Selamat datang, ${user.fullName}!',
      );

      // Navigate to home page
      Get.offAllNamed('/home');
    } on ApiException catch (e) {
      _errorMessage.value = e.message;

      _notif.showError(e.message);

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
      String errorMsg = e.toString();
      _notif.showError(errorMsg);
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
      _notif.showError(e.toString());
    } finally {
      isLoadingObs.value = false;
    }
  }
}
