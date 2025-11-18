import 'package:sirapat_app/domain/entities/user.dart';
import 'package:sirapat_app/domain/repositories/user_repository.dart';

class GetUserByIdUseCase {
  final UserRepository repository;

  GetUserByIdUseCase(this.repository);

  Future<User> execute(int id) {
    return repository.getUserById(id);
  }
}
