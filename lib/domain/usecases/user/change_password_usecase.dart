import 'package:sirapat_app/domain/repositories/user_repository.dart';

class ChangePasswordParams {
  final int id;
  final String currentPassword;
  final String newPassword;
  final String newPasswordConfirmation;

  ChangePasswordParams({
    required this.id,
    required this.currentPassword,
    required this.newPassword,
    required this.newPasswordConfirmation,
  });
}

class ChangePasswordUseCase {
  final UserRepository repository;

  ChangePasswordUseCase(this.repository);

  Future<bool> execute(ChangePasswordParams params) {
    return repository.changePassword(
      id: params.id,
      currentPassword: params.currentPassword,
      newPassword: params.newPassword,
      newPasswordConfirmation: params.newPasswordConfirmation,
    );
  }
}
