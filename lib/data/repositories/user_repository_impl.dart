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

      print('Get Users API Response: $response');

      final data = response['data'];
      final List usersJson = data['data'] ?? [];

      print("Parsed users count: ${usersJson.length}");

      final users = usersJson
          .map((item) => UserModel.fromJson(item as Map<String, dynamic>))
          .toList();

      return users;
    } catch (e) {
      print('Generic exception: $e');
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

      print('Get User By ID API Response: $response');

      final apiResponse = ApiResponse.fromJson(
        response as Map<String, dynamic>,
        (data) => UserModel.fromJson(data as Map<String, dynamic>),
      );

      if (!apiResponse.status || apiResponse.data == null) {
        print('Get user by id failed, throwing ApiException');
        throw ApiException.fromJson(response);
      }

      return apiResponse.data as User;
    } on ApiException catch (e) {
      print('ApiException caught: ${e.message}');
      rethrow;
    } catch (e) {
      print('Generic exception: $e');
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

      print('Create User API Response: $response');

      if (response is Map<String, dynamic> && response.containsKey('errors')) {
        print('Create user validation errors detected');
        throw ApiException.fromJson(response);
      }

      final apiResponse = ApiResponse.fromJson(
        response as Map<String, dynamic>,
        (data) => UserModel.fromJson(data as Map<String, dynamic>),
      );

      if (!apiResponse.status || apiResponse.data == null) {
        print('Create user failed, throwing ApiException');
        throw ApiException.fromJson(response);
      }

      return apiResponse.data as User;
    } on ApiException catch (e) {
      print('Create User ApiException caught');
      print('Message: ${e.message}');
      print('Errors: ${e.errors}');
      rethrow;
    } catch (e) {
      print('Generic exception: $e');
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

      print('Update User API Response: $response');

      if (response is Map<String, dynamic> && response.containsKey('errors')) {
        print('Update user validation errors detected');
        throw ApiException.fromJson(response);
      }

      final apiResponse = ApiResponse.fromJson(
        response as Map<String, dynamic>,
        (data) => UserModel.fromJson(data as Map<String, dynamic>),
      );

      if (!apiResponse.status || apiResponse.data == null) {
        print('Update user failed, throwing ApiException');
        throw ApiException.fromJson(response);
      }

      return apiResponse.data as User;
    } on ApiException catch (e) {
      print('Update User ApiException caught');
      print('Message: ${e.message}');
      print('Errors: ${e.errors}');
      rethrow;
    } catch (e) {
      print('Generic exception: $e');
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

      print('Update User Role API Response: $response');

      if (response is Map<String, dynamic> && response.containsKey('errors')) {
        print('Update role validation errors detected');
        throw ApiException.fromJson(response);
      }

      final apiResponse = ApiResponse.fromJson(
        response as Map<String, dynamic>,
        (data) => UserModel.fromJson(data as Map<String, dynamic>),
      );

      if (!apiResponse.status || apiResponse.data == null) {
        print('Update role failed, throwing ApiException');
        throw ApiException.fromJson(response);
      }

      return apiResponse.data as User;
    } on ApiException catch (e) {
      print('Update Role ApiException caught');
      print('Message: ${e.message}');
      rethrow;
    } catch (e) {
      print('Generic exception: $e');
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

      print('Delete User API Response: $response');

      final apiResponse = ApiResponse.fromJson(
        response as Map<String, dynamic>,
        (data) => data,
      );

      if (!apiResponse.status) {
        print('Delete user failed, throwing ApiException');
        throw ApiException.fromJson(response);
      }

      return true;
    } on ApiException catch (e) {
      print('Delete User ApiException caught');
      print('Message: ${e.message}');
      rethrow;
    } catch (e) {
      print('Generic exception: $e');
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

      print('Change Password API Response: $response');

      if (response is Map<String, dynamic> && response.containsKey('errors')) {
        print('Change password validation errors detected');
        throw ApiException.fromJson(response);
      }

      final apiResponse = ApiResponse.fromJson(
        response as Map<String, dynamic>,
        (data) => data,
      );

      if (!apiResponse.status) {
        print('Change password failed, throwing ApiException');
        throw ApiException.fromJson(response);
      }

      return true;
    } on ApiException catch (e) {
      print('Change Password ApiException caught');
      print('Message: ${e.message}');
      print('Errors: ${e.errors}');
      rethrow;
    } catch (e) {
      print('Generic exception: $e');
      throw ApiException(
        status: false,
        message: 'Failed to change password: ${e.toString()}',
      );
    }
  }
}
