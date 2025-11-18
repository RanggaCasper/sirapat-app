import 'package:get/get.dart';
import 'package:sirapat_app/data/repositories/user_repository_impl.dart';
import 'package:sirapat_app/domain/usecases/user/get_users_usecase.dart';
import 'package:sirapat_app/domain/usecases/user/get_user_by_id_usecase.dart';
import 'package:sirapat_app/domain/usecases/user/create_user_usecase.dart';
import 'package:sirapat_app/domain/usecases/user/update_user_usecase.dart';
import 'package:sirapat_app/domain/usecases/user/update_user_role_usecase.dart';
import 'package:sirapat_app/domain/usecases/user/delete_user_usecase.dart';
import 'package:sirapat_app/domain/usecases/user/change_password_usecase.dart';
import 'package:sirapat_app/presentation/controllers/user_controller.dart';

class UserBinding extends Bindings {
  @override
  void dependencies() {
    // Repository
    Get.lazyPut(() => UserRepositoryImpl());

    // Use Cases
    Get.lazyPut(() => GetUsersUseCase(Get.find<UserRepositoryImpl>()));
    Get.lazyPut(() => GetUserByIdUseCase(Get.find<UserRepositoryImpl>()));
    Get.lazyPut(() => CreateUserUseCase(Get.find<UserRepositoryImpl>()));
    Get.lazyPut(() => UpdateUserUseCase(Get.find<UserRepositoryImpl>()));
    Get.lazyPut(() => UpdateUserRoleUseCase(Get.find<UserRepositoryImpl>()));
    Get.lazyPut(() => DeleteUserUseCase(Get.find<UserRepositoryImpl>()));
    Get.lazyPut(() => ChangePasswordUseCase(Get.find<UserRepositoryImpl>()));

    // Controller
    Get.lazyPut(
      () => UserController(
        Get.find<GetUsersUseCase>(),
        Get.find<GetUserByIdUseCase>(),
        Get.find<CreateUserUseCase>(),
        Get.find<UpdateUserUseCase>(),
        Get.find<UpdateUserRoleUseCase>(),
        Get.find<DeleteUserUseCase>(),
        Get.find<ChangePasswordUseCase>(),
      ),
    );
  }
}
