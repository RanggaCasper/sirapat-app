import 'package:flutter/foundation.dart';
import 'package:sirapat_app/domain/entities/user.dart';
import 'package:sirapat_app/domain/repositories/user_repository.dart';
import 'package:sirapat_app/data/providers/network/requests/user/user_get_request.dart';
import 'package:sirapat_app/data/providers/network/requests/user/user_get_by_id_request.dart';
import 'package:sirapat_app/data/providers/network/requests/user/user_update_request.dart';
import 'package:sirapat_app/data/providers/network/requests/user/user_delete_request.dart';
import 'package:sirapat_app/data/providers/network/requests/user/user_create_request.dart';
import 'package:sirapat_app/data/providers/network/requests/user/user_change_password_request.dart';
import 'package:sirapat_app/data/providers/network/requests/user/user_update_role_request.dart';
import 'package:sirapat_app/data/models/api_response_model.dart';
import 'package:sirapat_app/data/models/user_model.dart';
import 'package:sirapat_app/data/models/api_exception.dart';

class UserRepositoryImpl extends UserRepository {
  @override
  Future<List<User>> getUsers() async {
    try {
      final request = GetUsersRequest();
      final response = await request.request();

      debugPrint('[UserRepository] Get Users API Response: $response');

      // Parse response using ApiResponse
      final apiResponse = ApiResponse.fromJson(response as Map<String, dynamic>, (
        data,
      ) {
        // Check if data is a Map with 'data' key (nested structure)
        if (data is Map<String, dynamic> && data.containsKey('data')) {
          final innerData = data['data'];
          if (innerData is List) {
            final users = innerData.map((item) {
              return UserModel.fromJson(item as Map<String, dynamic>);
            }).toList();
            return users;
          }
        }
        // Handle if data is directly a list
        if (data is List) {
          debugPrint(
            '[UserRepository] Data is directly a List with ${data.length} items',
          );
          return data
              .map((item) => UserModel.fromJson(item as Map<String, dynamic>))
              .toList();
        }
        return <User>[];
      });

      if (!apiResponse.status) {
        throw ApiException.fromJson(response);
      }

      final users = apiResponse.data;
      if (users is List<User>) {
        return users;
      }

      return [];
    } on ApiException catch (e) {
      debugPrint('[UserRepository] ApiException in getUsers: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('[UserRepository] Exception in getUsers: $e');
      throw ApiException(
        status: false,
        message: 'Failed to fetch users: ${e.toString()}',
      );
    }
  }

  @override
  Future<User> getUserById(int id) async {
    try {
      final request = GetUserByIdRequest(id: id);
      final response = await request.request();

      final apiResponse = ApiResponse.fromJson(
        response as Map<String, dynamic>,
        (data) => UserModel.fromJson(data as Map<String, dynamic>),
      );

      if (!apiResponse.status || apiResponse.data == null) {
        throw ApiException.fromJson(response);
      }

      return apiResponse.data as User;
    } on ApiException catch (e) {
      debugPrint('[UserRepository] ApiException in getUserById: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('[UserRepository] Exception in getUserById: $e');
      throw ApiException(
        status: false,
        message: 'Failed to fetch user: ${e.toString()}',
      );
    }
  }

  @override
  Future<User> createUser({
    required String nip,
    required String username,
    required String email,
    required String phone,
    required String fullName,
    required String password,
    required String passwordConfirmation,
    String? profilePhoto,
    String role = 'employee',
  }) async {
    try {
      final request = CreateUserRequest(
        nip: nip,
        username: username,
        email: email,
        phone: phone,
        fullName: fullName,
        password: password,
        passwordConfirmation: passwordConfirmation,
        profilePhoto: profilePhoto,
        role: role,
      );
      final response = await request.request();

      if (response is Map<String, dynamic> && response.containsKey('errors')) {
        throw ApiException.fromJson(response);
      }

      final apiResponse = ApiResponse.fromJson(
        response as Map<String, dynamic>,
        (data) => UserModel.fromJson(data as Map<String, dynamic>),
      );

      if (!apiResponse.status || apiResponse.data == null) {
        throw ApiException.fromJson(response);
      }

      return apiResponse.data as User;
    } on ApiException catch (e) {
      debugPrint('[UserRepository] ApiException in createUser: ${e.message}');
      debugPrint('[UserRepository] Errors: ${e.errors}');
      rethrow;
    } catch (e) {
      debugPrint('[UserRepository] Exception in createUser: $e');
      throw ApiException(
        status: false,
        message: 'Failed to create user: ${e.toString()}',
      );
    }
  }

  @override
  Future<User> updateUser({
    required int id,
    required String nip,
    required String username,
    required String email,
    required String phone,
    required String fullName,
    String? profilePhoto,
    String? role,
  }) async {
    try {
      final request = UpdateUserRequest(
        id: id,
        nip: nip,
        username: username,
        email: email,
        phone: phone,
        fullName: fullName,
        profilePhoto: profilePhoto,
        role: role,
      );
      final response = await request.request();

      if (response is Map<String, dynamic> && response.containsKey('errors')) {
        throw ApiException.fromJson(response);
      }

      final apiResponse = ApiResponse.fromJson(
        response as Map<String, dynamic>,
        (data) => UserModel.fromJson(data as Map<String, dynamic>),
      );

      if (!apiResponse.status || apiResponse.data == null) {
        throw ApiException.fromJson(response);
      }

      return apiResponse.data as User;
    } on ApiException catch (e) {
      debugPrint('[UserRepository] ApiException in updateUser: ${e.message}');
      debugPrint('[UserRepository] Errors: ${e.errors}');
      rethrow;
    } catch (e) {
      debugPrint('[UserRepository] Exception in updateUser: $e');
      throw ApiException(
        status: false,
        message: 'Failed to update user: ${e.toString()}',
      );
    }
  }

  @override
  Future<User> updateUserRole({required int id, required String role}) async {
    try {
      final request = UpdateUserRoleRequest(id: id, role: role);
      final response = await request.request();

      if (response is Map<String, dynamic> && response.containsKey('errors')) {
        throw ApiException.fromJson(response);
      }

      final apiResponse = ApiResponse.fromJson(
        response as Map<String, dynamic>,
        (data) => UserModel.fromJson(data as Map<String, dynamic>),
      );

      if (!apiResponse.status || apiResponse.data == null) {
        throw ApiException.fromJson(response);
      }

      return apiResponse.data as User;
    } on ApiException catch (e) {
      debugPrint(
        '[UserRepository] ApiException in updateUserRole: ${e.message}',
      );
      rethrow;
    } catch (e) {
      debugPrint('[UserRepository] Exception in updateUserRole: $e');
      throw ApiException(
        status: false,
        message: 'Failed to update user role: ${e.toString()}',
      );
    }
  }

  @override
  Future<bool> deleteUser(int id) async {
    try {
      final request = DeleteUserRequest(id: id);
      final response = await request.request();

      final apiResponse = ApiResponse.fromJson(
        response as Map<String, dynamic>,
        (data) => data,
      );

      if (!apiResponse.status) {
        throw ApiException.fromJson(response);
      }

      return true;
    } on ApiException catch (e) {
      debugPrint('[UserRepository] ApiException in deleteUser: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('[UserRepository] Exception in deleteUser: $e');
      throw ApiException(
        status: false,
        message: 'Failed to delete user: ${e.toString()}',
      );
    }
  }

  @override
  Future<bool> changePassword({
    required int id,
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    try {
      final request = ChangePasswordRequest(
        id: id,
        currentPassword: currentPassword,
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
        throw ApiException.fromJson(response);
      }

      return true;
    } on ApiException catch (e) {
      debugPrint(
        '[UserRepository] ApiException in changePassword: ${e.message}',
      );
      debugPrint('[UserRepository] Errors: ${e.errors}');
      rethrow;
    } catch (e) {
      debugPrint('[UserRepository] Exception in changePassword: $e');
      throw ApiException(
        status: false,
        message: 'Failed to change password: ${e.toString()}',
      );
    }
  }
}
