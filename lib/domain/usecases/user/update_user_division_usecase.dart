import 'package:sirapat_app/domain/entities/user.dart';
import 'package:sirapat_app/domain/repositories/user_repository.dart';

class UpdateUserDivisionParams {
  final int id;
  final int divisionId;

  UpdateUserDivisionParams({required this.id, required this.divisionId});
}

class UpdateUserDivisionUseCase {
  final UserRepository repository;

  UpdateUserDivisionUseCase(this.repository);

  Future<User> execute(UpdateUserDivisionParams params) {
    return repository.updateDivision(
      id: params.id,
      divisionId: params.divisionId,
    );
  }
}
