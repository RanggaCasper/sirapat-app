import 'package:get/get.dart';
import 'package:sirapat_app/data/repositories/meeting_repository_impl.dart';
import 'package:sirapat_app/data/repositories/attendance_repository_impl.dart';
import 'package:sirapat_app/domain/repositories/meeting_repository.dart';
import 'package:sirapat_app/domain/repositories/attendance_repository.dart';
import 'package:sirapat_app/domain/usecases/meeting/get_meetings_usecase.dart';
import 'package:sirapat_app/domain/usecases/meeting/get_meeting_by_id_usecase.dart';
import 'package:sirapat_app/domain/usecases/meeting/create_meeting_usecase.dart';
import 'package:sirapat_app/domain/usecases/meeting/update_meeting_usecase.dart';
import 'package:sirapat_app/domain/usecases/meeting/delete_meeting_usecase.dart';
import 'package:sirapat_app/domain/usecases/meeting/join_meeting_by_code_usecase.dart';
import 'package:sirapat_app/domain/usecases/attendance/get_attendance_usecase.dart';
import 'package:sirapat_app/presentation/controllers/meeting_controller.dart';

class MeetingBinding extends Bindings {
  @override
  void dependencies() {
    // Repositories
    Get.lazyPut<MeetingRepository>(() => MeetingRepositoryImpl());
    Get.lazyPut<AttendanceRepository>(() => AttendanceRepositoryImpl());

    // Use Cases
    Get.lazyPut(() => GetMeetingsUseCase(Get.find<MeetingRepository>()));
    Get.lazyPut(() => GetMeetingByIdUseCase(Get.find<MeetingRepository>()));
    Get.lazyPut(() => CreateMeetingUseCase(Get.find<MeetingRepository>()));
    Get.lazyPut(() => UpdateMeetingUseCase(Get.find<MeetingRepository>()));
    Get.lazyPut(() => DeleteMeetingUseCase(Get.find<MeetingRepository>()));
    Get.lazyPut(() => JoinMeetingByCodeUseCase(Get.find<MeetingRepository>()));
    Get.lazyPut(() => GetAttendanceUseCase(Get.find<AttendanceRepository>()));

    // Controller
    Get.lazyPut(
      () => MeetingController(
        Get.find<GetMeetingsUseCase>(),
        Get.find<GetMeetingByIdUseCase>(),
        Get.find<CreateMeetingUseCase>(),
        Get.find<UpdateMeetingUseCase>(),
        Get.find<DeleteMeetingUseCase>(),
        Get.find<JoinMeetingByCodeUseCase>(),
      ),
    );
  }
}
