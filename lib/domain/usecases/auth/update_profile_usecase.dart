import 'package:sirapat_app/domain/entities/user.dart';
import 'package:sirapat_app/domain/repositories/auth_repository.dart';

class UpdateProfileParams {
  final String fullName;
  final String phone;
  final int divisionId;

  UpdateProfileParams({
    required this.fullName,
    required this.phone,
    required this.divisionId,
  });
}

class UpdateProfileUseCase {
  final AuthRepository _authRepository;

  UpdateProfileUseCase(this._authRepository);

  Future<User> execute(UpdateProfileParams params) async {
    return await _authRepository.updateProfile(
      fullName: params.fullName,
      phone: params.phone,
      divisionId: params.divisionId,
    );
  }
}
