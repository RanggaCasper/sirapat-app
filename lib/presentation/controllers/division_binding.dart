import 'package:get/get.dart';
import 'package:sirapat_app/data/repositories/division_repository_impl.dart';
import 'package:sirapat_app/domain/usecases/division/get_divisions_usecase.dart';
import 'package:sirapat_app/domain/usecases/division/get_division_by_id_usecase.dart';
import 'package:sirapat_app/domain/usecases/division/create_division_usecase.dart';
import 'package:sirapat_app/domain/usecases/division/update_division_usecase.dart';
import 'package:sirapat_app/domain/usecases/division/delete_division_usecase.dart';
import 'package:sirapat_app/presentation/controllers/division_controller.dart';

class DivisionBinding extends Bindings {
  @override
  void dependencies() {
    // Repository
    Get.lazyPut(() => DivisionRepositoryImpl());

    // Use Cases
    Get.lazyPut(() => GetDivisionsUseCase(Get.find<DivisionRepositoryImpl>()));
    Get.lazyPut(
      () => GetDivisionByIdUseCase(Get.find<DivisionRepositoryImpl>()),
    );
    Get.lazyPut(
      () => CreateDivisionUseCase(Get.find<DivisionRepositoryImpl>()),
    );
    Get.lazyPut(
      () => UpdateDivisionUseCase(Get.find<DivisionRepositoryImpl>()),
    );
    Get.lazyPut(
      () => DeleteDivisionUsecase(Get.find<DivisionRepositoryImpl>()),
    );

    // Controller
    Get.lazyPut(
      () => DivisionController(
        Get.find<GetDivisionsUseCase>(),
        Get.find<GetDivisionByIdUseCase>(),
        Get.find<CreateDivisionUseCase>(),
        Get.find<UpdateDivisionUseCase>(),
        Get.find<DeleteDivisionUsecase>(),
      ),
    );
  }
}
