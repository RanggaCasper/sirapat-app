import 'package:sirapat_app/domain/entities/user.dart';
import 'package:sirapat_app/domain/repositories/user_repository.dart';

class UpdateUserParams {
  final int id;
  final String nip;
  final String username;
  final String email;
  final String phone;
  final String fullName;
  final String? profilePhoto;
  final String? role;

  UpdateUserParams({
    required this.id,
    required this.nip,
    required this.username,
    required this.email,
    required this.phone,
    required this.fullName,
    this.profilePhoto,
    this.role,
  });
}

class UpdateUserUseCase {
  final UserRepository repository;

  UpdateUserUseCase(this.repository);

  Future<User> execute(UpdateUserParams params) {
    return repository.updateUser(
      id: params.id,
      nip: params.nip,
      username: params.username,
      email: params.email,
      phone: params.phone,
      fullName: params.fullName,
      profilePhoto: params.profilePhoto,
      role: params.role,
    );
  }
}
