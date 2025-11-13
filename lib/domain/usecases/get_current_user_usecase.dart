import 'package:sirapat_app/app/core/usecases/no_param_usecase.dart';
import 'package:sirapat_app/domain/entities/user.dart';
import 'package:sirapat_app/domain/repositories/auth_repository.dart';

class GetCurrentUserUseCase extends NoParamUseCase<User?> {
  final AuthRepository _repository;

  GetCurrentUserUseCase(this._repository);

  @override
  Future<User?> execute() {
    return _repository.getCurrentUser();
  }
}
