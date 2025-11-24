import 'package:sirapat_app/domain/repositories/auth_repository.dart';

class ResetPasswordParams {
  final String oldPassword;
  final String newPassword;
  final String newPasswordConfirmation;

  ResetPasswordParams({
    required this.oldPassword,
    required this.newPassword,
    required this.newPasswordConfirmation,
  });
}

class ResetPasswordUseCase {
  final AuthRepository repository;

  ResetPasswordUseCase(this.repository);

  Future<void> execute(ResetPasswordParams params) async {
    return await repository.resetPassword(
      params.oldPassword,
      params.newPassword,
      params.newPasswordConfirmation,
    );
  }
}
