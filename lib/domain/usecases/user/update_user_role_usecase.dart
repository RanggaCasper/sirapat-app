import 'package:sirapat_app/domain/entities/user.dart';
import 'package:sirapat_app/domain/repositories/user_repository.dart';

class UpdateUserRoleParams {
  final int id;
  final String role;

  UpdateUserRoleParams({required this.id, required this.role});
}

class UpdateUserRoleUseCase {
  final UserRepository repository;

  UpdateUserRoleUseCase(this.repository);

  Future<User> execute(UpdateUserRoleParams params) {
    return repository.updateUserRole(id: params.id, role: params.role);
  }
}
