import 'package:get/get.dart';
import 'package:sirapat_app/data/repositories/meeting_minute_repository_impl.dart';
import 'package:sirapat_app/domain/repositories/meeting_minute_repository.dart';
import 'package:sirapat_app/domain/usecases/meeting_minute/get_meeting_minute_by_meeting_id_usecase.dart';
import 'package:sirapat_app/domain/usecases/meeting_minute/approve_meeting_minute_usecase.dart';
import 'package:sirapat_app/presentation/controllers/meeting_minute_controller.dart';

class MeetingMinuteBinding extends Bindings {
  @override
  void dependencies() {
    // Repositories
    Get.lazyPut<MeetingMinuteRepository>(() => MeetingMinuteRepositoryImpl());

    // Use Cases
    Get.lazyPut(
      () => GetMeetingMinuteByMeetingIdUseCase(
        Get.find<MeetingMinuteRepository>(),
      ),
    );

    Get.lazyPut(
      () => ApproveMeetingMinuteUseCase(Get.find<MeetingMinuteRepository>()),
    );

    // Controller
    Get.lazyPut(
      () => MeetingMinuteController(
        Get.find<GetMeetingMinuteByMeetingIdUseCase>(),
        Get.find<ApproveMeetingMinuteUseCase>(),
      ),
    );
  }
}
