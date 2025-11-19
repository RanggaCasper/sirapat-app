import 'package:get/get.dart';
import 'package:sirapat_app/data/repositories/meeting_repository_impl.dart';
import 'package:sirapat_app/domain/usecases/meeting/get_meetings_usecase.dart';
import 'package:sirapat_app/presentation/controllers/meeting_controller.dart';

class MeetingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MeetingRepositoryImpl());

    Get.lazyPut(() => GetMeetingsUseCase(Get.find<MeetingRepositoryImpl>()));

    Get.lazyPut(() => MeetingController(Get.find<GetMeetingsUseCase>()));
  }
}
