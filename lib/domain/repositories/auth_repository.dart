import 'package:sirapat_app/domain/entities/user.dart';

abstract class AuthRepository {
  Future<User> login(String nip, String password);
  Future<User> register(
    String nip,
    String username,
    String fullName,
    String email,
    String phone,
    String password,
    String passwordConfirmation,
  );
  Future<void> logout();
  Future<User?> getCurrentUser();
  Future<void> resetPassword(
    String oldPassword,
    String newPassword,
    String newPasswordConfirmation,
  );
}
