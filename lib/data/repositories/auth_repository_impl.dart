import 'package:sirapat_app/domain/entities/user.dart';
import 'package:sirapat_app/domain/repositories/auth_repository.dart';
import 'package:sirapat_app/app/services/local_storage.dart';
import 'package:sirapat_app/data/providers/network/requests/login_request.dart';
import 'package:sirapat_app/data/providers/network/requests/register_request.dart';
import 'package:sirapat_app/data/models/api_response_model.dart';
import 'package:sirapat_app/data/models/login_response_model.dart';
import 'package:sirapat_app/data/models/api_exception.dart';
import 'package:get/get.dart';

class AuthRepositoryImpl extends AuthRepository {
  final LocalStorageService _storage = Get.find<LocalStorageService>();

  @override
  Future<User> login(String nip, String password) async {
    try {
      // Make API call
      final request = LoginRequest(nip: nip, password: password);
      final response = await request.request();

      // Debug: print response
      print('API Response: $response');

      // Parse response
      final apiResponse = ApiResponse.fromJson(
        response as Map<String, dynamic>,
        (data) => LoginResponseData.fromJson(data as Map<String, dynamic>),
      );

      // Check if login failed (status = false)
      if (!apiResponse.status || apiResponse.data == null) {
        // Throw ApiException with error details from response
        print('Login failed, throwing ApiException');
        throw ApiException.fromJson(response);
      }

      final loginData = apiResponse.data as LoginResponseData;

      // Save user and token to local storage
      await _storage.saveData(StorageKey.user, loginData.user.toJson());
      await _storage.saveData(StorageKey.token, loginData.token);

      return loginData.user;
    } on ApiException catch (e) {
      print('ApiException caught: ${e.message}, errors: ${e.errors}');
      rethrow; // Re-throw ApiException as-is
    } catch (e) {
      print('Generic exception: $e');
      throw ApiException(
        status: false,
        message: 'Login failed: ${e.toString()}',
      );
    }
  }

  @override
  Future<User> register(
    String nip,
    String username,
    String fullName,
    String email,
    String phone,
    String password,
    String passwordConfirmation,
  ) async {
    try {
      // Make API call
      final request = RegisterRequest(
        nip: nip,
        username: username,
        fullName: fullName,
        email: email,
        phone: phone,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      final response = await request.request();

      print('Register API Response: $response');

      // Check if response has errors field (validation error)
      if (response is Map<String, dynamic> && response.containsKey('errors')) {
        print('Register validation errors detected');
        throw ApiException.fromJson(response);
      }

      // Parse response
      final apiResponse = ApiResponse.fromJson(
        response as Map<String, dynamic>,
        (data) => LoginResponseData.fromJson(data as Map<String, dynamic>),
      );

      // Check if register failed (status = false)
      if (!apiResponse.status || apiResponse.data == null) {
        print('Register failed, throwing ApiException');
        throw ApiException.fromJson(response);
      }

      final registerData = apiResponse.data as LoginResponseData;

      // Save user and token to local storage
      await _storage.saveData(StorageKey.user, registerData.user.toJson());
      await _storage.saveData(StorageKey.token, registerData.token);

      return registerData.user;
    } on ApiException catch (e) {
      print('Register ApiException caught');
      print('Message: ${e.message}');
      print('Errors: ${e.errors}');
      rethrow; // Re-throw ApiException as-is
    } catch (e) {
      print('Generic exception: $e');
      throw ApiException(
        status: false,
        message: 'Register failed: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> logout() async {
    await _storage.removeData(StorageKey.user);
    await _storage.removeData(StorageKey.token);
  }

  @override
  Future<User?> getCurrentUser() async {
    final userData = _storage.getJson(StorageKey.user);
    if (userData == null) return null;

    return User.fromJson(userData);
  }
}
