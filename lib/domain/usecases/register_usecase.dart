import 'package:sirapat_app/app/core/usecases/param_usecase.dart';
import 'package:sirapat_app/domain/entities/user.dart';
import 'package:sirapat_app/domain/repositories/auth_repository.dart';

class RegisterParams {
  final String nip;
  final String username;
  final String fullName;
  final String email;
  final String phone;
  final String password;
  final String passwordConfirmation;

  RegisterParams({
    required this.nip,
    required this.username,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.password,
    required this.passwordConfirmation,
  });
}

class RegisterUseCase extends ParamUseCase<User, RegisterParams> {
  final AuthRepository _repository;

  RegisterUseCase(this._repository);

  @override
  Future<User> execute(RegisterParams params) {
    return _repository.register(
      params.nip,
      params.username,
      params.fullName,
      params.email,
      params.phone,
      params.password,
      params.passwordConfirmation,
    );
  }
}
