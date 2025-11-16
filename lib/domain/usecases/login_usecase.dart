import 'package:sirapat_app/app/core/usecases/param_usecase.dart';
import 'package:sirapat_app/domain/entities/user.dart';
import 'package:sirapat_app/domain/repositories/auth_repository.dart';

class LoginParams {
  final String nip;
  final String password;

  LoginParams({required this.nip, required this.password});
}

class LoginUseCase extends ParamUseCase<User, LoginParams> {
  final AuthRepository _repository;

  LoginUseCase(this._repository);

  @override
  Future<User> execute(LoginParams params) {
    return _repository.login(params.nip, params.password);
  }
}
