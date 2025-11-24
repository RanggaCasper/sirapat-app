import 'package:sirapat_app/domain/entities/user.dart';
import 'package:sirapat_app/domain/repositories/auth_repository.dart';
import 'package:sirapat_app/app/services/local_storage.dart';
import 'package:sirapat_app/data/providers/network/requests/login_request.dart';
import 'package:sirapat_app/data/providers/network/requests/register_request.dart';
import 'package:sirapat_app/data/providers/network/requests/auth/reset_password_request.dart';
import 'package:sirapat_app/data/providers/network/api_endpoint.dart';
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
      print('[AuthRepository] Saving user and token to storage...');
      print('[AuthRepository] User: ${loginData.user.fullName}');
      print('[AuthRepository] Token: ${loginData.token.substring(0, 20)}...');

      final userSaved = await _storage.saveData(
        StorageKey.user,
        loginData.user.toJson(),
      );
      final tokenSaved = await _storage.saveData(
        StorageKey.token,
        loginData.token,
      );

      print('[AuthRepository] User saved: $userSaved');
      print('[AuthRepository] Token saved: $tokenSaved');

      // Verify saved data
      final savedToken = _storage.getString(StorageKey.token);
      print(
        '[AuthRepository] Token verification after save: ${savedToken != null ? "Found" : "Not found"}',
      );

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
    print('[AuthRepository] Logging out - clearing storage...');
    await _storage.removeData(StorageKey.user);
    await _storage.removeData(StorageKey.token);
    print('[AuthRepository] Logout complete');
  }

  @override
  Future<User?> getCurrentUser() async {
    final userData = _storage.getJson(StorageKey.user);
    if (userData == null) return null;

    return User.fromJson(userData);
  }

  /// Verify user from server (check if token is still valid)
  /// Returns user if valid, null if unauthenticated, throws exception for other errors
  Future<User?> verifyUserFromServer() async {
    final token = _storage.getString(StorageKey.token);
    if (token == null || token.isEmpty) {
      print('[AuthRepository] No token found in storage');
      return null;
    }

    print('[AuthRepository] Verifying token with server...');
    print('[AuthRepository] Token: ${token.substring(0, 20)}...');

    try {
      // Create a simple GET request to verify token
      final GetConnect connect = GetConnect();
      connect.timeout = const Duration(seconds: 10);

      final response = await connect.get(
        APIEndpoint.currentUser,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      print(
        '[AuthRepository] Verification response status: ${response.statusCode}',
      );
      print('[AuthRepository] Verification response body: ${response.body}');

      // If 401 Unauthorized - token is invalid, logout
      if (response.statusCode == 401) {
        print('[AuthRepository] Token is invalid (401), logging out');
        await logout();
        return null;
      }

      // If successful
      if (response.statusCode == 200 && response.body != null) {
        final apiResponse = ApiResponse.fromJson(
          response.body as Map<String, dynamic>,
          (data) => User.fromJson(data as Map<String, dynamic>),
        );

        if (apiResponse.status && apiResponse.data != null) {
          final user = apiResponse.data as User;
          print(
            '[AuthRepository] Verification successful for user: ${user.fullName}',
          );
          // Update local storage with fresh data
          await _storage.saveData(StorageKey.user, user.toJson());
          return user;
        }
      }

      // For other status codes or errors, throw exception to be handled by caller
      throw Exception(
        'Server verification failed with status: ${response.statusCode}',
      );
    } catch (e) {
      print('[AuthRepository] Verification error: $e');
      // Re-throw so caller can decide what to do
      rethrow;
    }
  }

  @override
  Future<void> resetPassword(
    String oldPassword,
    String newPassword,
    String newPasswordConfirmation,
  ) async {
    try {
      print('[AuthRepository] Creating reset password request...');
      final request = ResetPasswordRequest(
        oldPassword: oldPassword,
        newPassword: newPassword,
        newPasswordConfirmation: newPasswordConfirmation,
      );

      print('[AuthRepository] Sending request to: ${request.url}');
      final response = await request.request();

      print('[AuthRepository] Reset Password API Response: $response');

      // Check if response has errors (validation failed)
      if (response is Map<String, dynamic> && response.containsKey('errors')) {
        print('[AuthRepository] Validation errors detected');
        throw ApiException.fromJson(response);
      }

      // Parse response
      final apiResponse = ApiResponse.fromJson(
        response as Map<String, dynamic>,
        (data) => data,
      );

      print('[AuthRepository] API Response status: ${apiResponse.status}');
      print('[AuthRepository] API Response message: ${apiResponse.message}');

      // Check if reset password failed
      if (!apiResponse.status) {
        print('[AuthRepository] Reset password failed, throwing ApiException');
        throw ApiException.fromJson(response);
      }

      print('[AuthRepository] Password reset successful');
    } on ApiException catch (e) {
      print('[AuthRepository] Reset Password ApiException caught');
      print('[AuthRepository] Message: ${e.message}');
      print('[AuthRepository] Errors: ${e.errors}');
      rethrow;
    } catch (e) {
      print('[AuthRepository] Generic exception: $e');
      throw ApiException(
        status: false,
        message: 'Reset password failed: ${e.toString()}',
      );
    }
  }
}
