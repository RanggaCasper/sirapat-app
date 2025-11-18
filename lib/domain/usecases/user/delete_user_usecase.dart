import 'package:sirapat_app/domain/repositories/user_repository.dart';

class DeleteUserUseCase {
  final UserRepository repository;

  DeleteUserUseCase(this.repository);

  Future<bool> execute(int id) {
    return repository.deleteUser(id);
  }
}
