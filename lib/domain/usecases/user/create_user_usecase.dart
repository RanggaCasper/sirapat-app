import 'package:sirapat_app/domain/entities/user.dart';
import 'package:sirapat_app/domain/repositories/user_repository.dart';

class CreateUserParams {
  final String nip;
  final String username;
  final String email;
  final String phone;
  final String fullName;
  final String password;
  final String passwordConfirmation;
  final String? profilePhoto;
  final String role;

  CreateUserParams({
    required this.nip,
    required this.username,
    required this.email,
    required this.phone,
    required this.fullName,
    required this.password,
    required this.passwordConfirmation,
    this.profilePhoto,
    this.role = 'employee',
  });
}

class CreateUserUseCase {
  final UserRepository repository;

  CreateUserUseCase(this.repository);

  Future<User> execute(CreateUserParams params) {
    return repository.createUser(
      nip: params.nip,
      username: params.username,
      email: params.email,
      phone: params.phone,
      fullName: params.fullName,
      password: params.password,
      passwordConfirmation: params.passwordConfirmation,
      profilePhoto: params.profilePhoto,
      role: params.role,
    );
  }
}
