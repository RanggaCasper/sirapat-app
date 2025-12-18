import 'package:flutter/foundation.dart';
import 'package:sirapat_app/data/providers/network/requests/auth/profile_update_request.dart';
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
import 'package:sirapat_app/app/config/app_constants.dart';
import 'package:get/get.dart';

class AuthRepositoryImpl extends AuthRepository {
  final LocalStorageService _storage = Get.find<LocalStorageService>();

  @override
  Future<User> login(String nip, String password) async {
    try {
      final request = LoginRequest(nip: nip, password: password);
      final response = await request.request();

      debugPrint('API Response: $response');

      if (response is Map<String, dynamic> && response.containsKey('errors')) {
        throw ApiException.fromJson(response);
      }

      final apiResponse = ApiResponse.fromJson(
        response as Map<String, dynamic>,
        (data) => LoginResponseData.fromJson(data as Map<String, dynamic>),
      );

      if (!apiResponse.status || apiResponse.data == null) {
        debugPrint('Login failed, throwing ApiException');
        throw ApiException.fromJson(response);
      }

      final loginData = apiResponse.data as LoginResponseData;

      // Save user & token
      await _storage.saveData(
        StorageKey.user,
        loginData.user.toJson(),
      );
      debugPrint('[AuthRepository] User saved: ${loginData.user.toJson()}');
      await _storage.saveData(
        StorageKey.token,
        loginData.token,
      );

      return loginData.user;
    } on ApiException {
      rethrow;
    } catch (e) {
      debugPrint('Generic exception: $e');
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

      debugPrint('Register API Response: $response');

      if (response is Map<String, dynamic> && response.containsKey('errors')) {
        debugPrint('Register validation errors detected');
        throw ApiException.fromJson(response);
      }

      final apiResponse = ApiResponse.fromJson(
        response as Map<String, dynamic>,
        (data) => LoginResponseData.fromJson(data as Map<String, dynamic>),
      );

      if (!apiResponse.status || apiResponse.data == null) {
        debugPrint('Register failed, throwing ApiException');
        throw ApiException.fromJson(response);
      }

      final registerData = apiResponse.data as LoginResponseData;

      // Save user and token to local storage
      await _storage.saveData(StorageKey.user, registerData.user.toJson());
      await _storage.saveData(StorageKey.token, registerData.token);

      return registerData.user;
    } on ApiException catch (e) {
      debugPrint('Register ApiException caught');
      debugPrint('Message: ${e.message}');
      debugPrint('Errors: ${e.errors}');
      rethrow; // Re-throw ApiException as-is
    } catch (e) {
      debugPrint('Generic exception: $e');
      throw ApiException(
        status: false,
        message: 'Register failed: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> logout() async {
    final token = _storage.getString(StorageKey.token);

    try {
      if (token != null && token.isNotEmpty) {
        final GetConnect connect = GetConnect();
        connect.timeout = AppConstants.apiTimeout;

        await connect.post(
          APIEndpoint.logout,
          {},
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        );
      }
    } catch (e) {
      debugPrint('[AuthRepository] Logout error: $e');
    } finally {
      // Selalu hapus data lokal (Token & User)
      await _storage.removeData(StorageKey.token);
      await _storage.removeData(StorageKey.user);
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    final userData = _storage.getJson(StorageKey.user);
    if (userData == null) return null;

    final user = User.fromJson(userData);
    debugPrint('[AuthRepository] getCurrentUser: ${user.fullName}');
    debugPrint('[AuthRepository] Division: ${user.division?.name ?? "null"}');
    debugPrint('[AuthRepository] DivisionId: ${user.divisionId}');
    return user;
  }

  @override
  Future<User?> verifyUserFromServer() async {
    final token = _storage.getString(StorageKey.token);
    if (token == null || token.isEmpty) {
      debugPrint('[AuthRepository] No token found in storage');
      return null;
    }

    try {
      final GetConnect connect = GetConnect();
      connect.timeout = AppConstants.apiTimeout;

      final response = await connect.get(
        APIEndpoint.currentUser,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 401) {
        debugPrint('[AuthRepository] Token is invalid (401), logging out');
        await logout();
        return null;
      }

      if (response.statusCode == 200 && response.body != null) {
        final apiResponse = ApiResponse.fromJson(
          response.body as Map<String, dynamic>,
          (data) => User.fromJson(data as Map<String, dynamic>),
        );

        if (apiResponse.status && apiResponse.data != null) {
          final user = apiResponse.data as User;
          await _storage.saveData(StorageKey.user, user.toJson());
          return user;
        }
      }

      throw Exception(
        'Server verification failed with status: ${response.statusCode}',
      );
    } catch (e) {
      debugPrint('[AuthRepository] Verification error: $e');
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
      debugPrint('[AuthRepository] Creating reset password request...');
      final request = ResetPasswordRequest(
        oldPassword: oldPassword,
        newPassword: newPassword,
        newPasswordConfirmation: newPasswordConfirmation,
      );

      final response = await request.request();

      if (response is Map<String, dynamic> && response.containsKey('errors')) {
        throw ApiException.fromJson(response);
      }

      final apiResponse = ApiResponse.fromJson(
        response as Map<String, dynamic>,
        (data) => data,
      );

      if (!apiResponse.status) {
        debugPrint(
          '[AuthRepository] Reset password failed, throwing ApiException',
        );
        throw ApiException.fromJson(response);
      }
    } on ApiException catch (e) {
      debugPrint('[AuthRepository] Reset Password ApiException caught');
      debugPrint('[AuthRepository] Message: ${e.message}');
      debugPrint('[AuthRepository] Errors: ${e.errors}');
      rethrow;
    } catch (e) {
      debugPrint('[AuthRepository] Generic exception: $e');
      throw ApiException(
        status: false,
        message: 'Reset password failed: ${e.toString()}',
      );
    }
  }

  @override
  Future<User> updateProfile({
    required String fullName,
    required String phone,
    required int divisionId,
  }) async {
    try {
      debugPrint('[AuthRepository] Updating profile...');

      final request = ProfileUpdateRequest(
        fullName: fullName,
        phone: phone,
        divisionId: divisionId,
      );

      final response = await request.request();

      debugPrint('[AuthRepository] Update profile response: $response');

      if (response is Map<String, dynamic> && response.containsKey('errors')) {
        throw ApiException.fromJson(response);
      }

      if (response == null || response['status'] != true) {
        debugPrint('[AuthRepository] Update profile failed');
        throw ApiException(
          status: false,
          message: response?['message'] ?? 'Gagal memperbarui profile',
        );
      }

      final updatedUser = await verifyUserFromServer();

      if (updatedUser == null) {
        throw ApiException(
          status: false,
          message: 'Gagal mengambil data user dari server',
        );
      }

      debugPrint(
        '[AuthRepository] Profile updated successfully for: ${updatedUser.fullName}',
      );

      return updatedUser;
    } on ApiException catch (e) {
      debugPrint('[AuthRepository] Update Profile ApiException caught');
      debugPrint('[AuthRepository] Message: ${e.message}');
      debugPrint('[AuthRepository] Errors: ${e.errors}');
      rethrow; // Re-throw ApiException to be handled by controller
    } catch (e, stackTrace) {
      debugPrint('[AuthRepository] Error updating profile: $e');
      debugPrint('[AuthRepository] Stack trace: $stackTrace');
      throw ApiException(
        status: false,
        message: 'Gagal memperbarui profile: ${e.toString()}',
      );
    }
  }
}
