import 'package:get/get.dart';
import 'package:sirapat_app/data/repositories/meeting_repository_impl.dart';
import 'package:sirapat_app/domain/usecases/meeting/get_meetings_usecase.dart';
import 'package:sirapat_app/domain/usecases/meeting/get_meeting_by_id_usecase.dart';
import 'package:sirapat_app/domain/usecases/meeting/create_meeting_usecase.dart';
import 'package:sirapat_app/domain/usecases/meeting/update_meeting_usecase.dart';
import 'package:sirapat_app/domain/usecases/meeting/delete_meeting_usecase.dart';
import 'package:sirapat_app/presentation/controllers/meeting_controller.dart';

class MeetingBinding extends Bindings {
  @override
  void dependencies() {
    // Repository
    Get.lazyPut(() => MeetingRepositoryImpl());

    // Use Cases
    Get.lazyPut(() => GetMeetingsUseCase(Get.find<MeetingRepositoryImpl>()));
    Get.lazyPut(() => GetMeetingByIdUseCase(Get.find<MeetingRepositoryImpl>()));
    Get.lazyPut(() => CreateMeetingUseCase(Get.find<MeetingRepositoryImpl>()));
    Get.lazyPut(() => UpdateMeetingUseCase(Get.find<MeetingRepositoryImpl>()));
    Get.lazyPut(() => DeleteMeetingUseCase(Get.find<MeetingRepositoryImpl>()));

    // Controller
    Get.lazyPut(
      () => MeetingController(
        Get.find<GetMeetingsUseCase>(),
        Get.find<GetMeetingByIdUseCase>(),
        Get.find<CreateMeetingUseCase>(),
        Get.find<UpdateMeetingUseCase>(),
        Get.find<DeleteMeetingUseCase>(),
      ),
    );
  }
}
