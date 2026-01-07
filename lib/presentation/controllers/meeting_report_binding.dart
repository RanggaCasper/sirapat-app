import 'package:get/get.dart';
import 'package:sirapat_app/presentation/controllers/meeting_report_controller.dart';

class MeetingReportBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MeetingReportController>(
      () => MeetingReportController(),
    );
  }
}
