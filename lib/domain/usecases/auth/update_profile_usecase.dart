import 'package:sirapat_app/domain/entities/user.dart';
import 'package:sirapat_app/domain/repositories/auth_repository.dart';

class UpdateProfileParams {
  // final String nip;
  // final String username;
  final String fullName;
  // final String email;
  final String phone;
  final int divisionId;

  UpdateProfileParams({
    // required this.nip,
    // required this.username,
    required this.fullName,
    // required this.email,
    required this.phone,
    required this.divisionId,
  });
}

class UpdateProfileUseCase {
  final AuthRepository _authRepository;

  UpdateProfileUseCase(this._authRepository);

  Future<User> execute(UpdateProfileParams params) async {
    return await _authRepository.updateProfile(
      // nip: params.nip,
      // username: params.username,
      fullName: params.fullName,
      // email: params.email,
      phone: params.phone,
      divisionId: params.divisionId,
    );
  }
}
