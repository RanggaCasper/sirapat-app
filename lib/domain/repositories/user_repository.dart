import 'package:sirapat_app/domain/entities/user.dart';

abstract class UserRepository {
  Future<List<User>> getUsers();
  Future<User> getUserById(int id);
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
  });

  Future<User> updateUser({
    required int id,
    required String nip,
    required String username,
    required String email,
    required String phone,
    required String fullName,
    String? profilePhoto,
    String? role,
  });

  Future<User> updateUserRole({required int id, required String role});
  Future<bool> deleteUser(int id);
  Future<bool> changePassword({
    required int id,
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  });
}
