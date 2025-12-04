import 'package:get/get.dart';
import 'package:sirapat_app/data/repositories/participant_repository_impl.dart';
import 'package:sirapat_app/domain/repositories/participant_repository.dart';
import 'package:sirapat_app/domain/usecases/participant/invite_participant_usecase.dart';
import 'package:sirapat_app/presentation/controllers/participant_controller.dart';

class ParticipantBinding extends Bindings {
  @override
  void dependencies() {
    // Repositories
    Get.lazyPut<ParticipantRepository>(() => ParticipantRepositoryImpl());

    // Use Cases
    Get.lazyPut(
      () => InviteParticipantUseCase(Get.find<ParticipantRepository>()),
    );

    // Controller
    Get.lazyPut(
      () => ParticipantController(Get.find<InviteParticipantUseCase>()),
    );
  }
}
