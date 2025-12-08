import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sirapat_app/data/models/api_exception.dart';
import 'package:sirapat_app/domain/entities/meeting_minute.dart';
import 'package:sirapat_app/domain/usecases/meeting_minute/get_meeting_minute_by_meeting_id_usecase.dart';
import 'package:sirapat_app/presentation/shared/widgets/custom_notification.dart';

class MeetingMinuteController extends GetxController {
  final GetMeetingMinuteByMeetingIdUseCase _getMeetingMinuteByMeetingId;

  MeetingMinuteController(this._getMeetingMinuteByMeetingId);

  // Observables
  final RxBool isLoadingObs = false.obs;
  final RxBool isLoadingActionObs = false.obs;
  final RxMap<String, String> fieldErrors = <String, String>{}.obs;
  final RxString _errorMessage = ''.obs;

  bool get isLoading => isLoadingObs.value;
  bool get isLoadingAction => isLoadingActionObs.value;
  String get errorMessage => _errorMessage.value;

  NotificationController get _notif => Get.find<NotificationController>();

  get decisions => null;

  get content => null;

  Future<MeetingMinute?> getMeetingMinuteByMeetingId(int id) async {
    try {
      final passcode = await _getMeetingMinuteByMeetingId.execute(id);

      return passcode;
    } on ApiException catch (e) {
      debugPrint(
        '[MeetingMinuteController] ApiException in getMeetingMinuteByMeetingId: ${e.message}',
      );
      _notif.showError(e.message);
      return null;
    } catch (e) {
      debugPrint(
        '[MeetingMinuteController] Exception in getMeetingMinuteByMeetingId: $e',
      );
      _notif.showError(e.toString());
      return null;
    }
  }
}
