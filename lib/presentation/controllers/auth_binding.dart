import 'package:get/get.dart';
import 'package:sirapat_app/data/repositories/auth_repository_impl.dart';
import 'package:sirapat_app/domain/usecases/login_usecase.dart';
import 'package:sirapat_app/domain/usecases/get_current_user_usecase.dart';
import 'package:sirapat_app/presentation/controllers/auth_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    // Repository
    Get.lazyPut(() => AuthRepositoryImpl());

    // Use Cases
    Get.lazyPut(() => LoginUseCase(Get.find<AuthRepositoryImpl>()));
    Get.lazyPut(() => GetCurrentUserUseCase(Get.find<AuthRepositoryImpl>()));

    // Controller
    Get.put(
      AuthController(
        Get.find<LoginUseCase>(),
        Get.find<GetCurrentUserUseCase>(),
        Get.find<AuthRepositoryImpl>(),
      ),
      permanent: true,
    );
  }
}
