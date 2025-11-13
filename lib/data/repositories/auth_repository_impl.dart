import 'package:sirapat_app/domain/entities/user.dart';
import 'package:sirapat_app/domain/repositories/auth_repository.dart';
import 'package:sirapat_app/app/services/local_storage.dart';
import 'package:get/get.dart';

class AuthRepositoryImpl extends AuthRepository {
  final LocalStorageService _storage = Get.find<LocalStorageService>();

  @override
  Future<User> login(String email, String password) async {
    // TODO: Implement actual API call
    // Simulating API call
    await Future.delayed(const Duration(seconds: 1));

    // Mock user data
    final user = User(
      id: '1',
      name: 'John Doe',
      email: email,
      avatar: 'https://ui-avatars.com/api/?name=John+Doe',
    );

    // Save user to local storage
    await _storage.saveData(StorageKey.user, user.toJson());

    return user;
  }

  @override
  Future<User> register(String name, String email, String password) async {
    // TODO: Implement actual API call
    // Simulating API call
    await Future.delayed(const Duration(seconds: 1));

    final user = User(
      id: '1',
      name: name,
      email: email,
      avatar: 'https://ui-avatars.com/api/?name=${name.replaceAll(' ', '+')}',
    );

    await _storage.saveData(StorageKey.user, user.toJson());

    return user;
  }

  @override
  Future<void> logout() async {
    await _storage.removeData(StorageKey.user);
    await _storage.removeData(StorageKey.token);
  }

  @override
  Future<User?> getCurrentUser() async {
    final userData = _storage.getJson(StorageKey.user);
    if (userData == null) return null;

    return User.fromJson(userData);
  }
}
