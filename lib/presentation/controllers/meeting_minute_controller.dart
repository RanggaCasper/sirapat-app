import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sirapat_app/data/models/api_exception.dart';
import 'package:sirapat_app/domain/entities/meeting_minute.dart';
import 'package:sirapat_app/domain/usecases/meeting_minute/get_meeting_minute_by_meeting_id_usecase.dart';
import 'package:sirapat_app/domain/usecases/meeting_minute/approve_meeting_minute_usecase.dart';
import 'package:sirapat_app/presentation/shared/widgets/custom_notification.dart';

class MeetingMinuteController extends GetxController {
  final GetMeetingMinuteByMeetingIdUseCase _getMeetingMinuteByMeetingId;
  final ApproveMeetingMinuteUseCase _approveMeetingMinute;

  MeetingMinuteController(
    this._getMeetingMinuteByMeetingId,
    this._approveMeetingMinute,
  );

  // Observables
  final RxBool isLoadingObs = false.obs;
  final RxBool isLoadingActionObs = false.obs;
  final RxMap<String, String> fieldErrors = <String, String>{}.obs;
  final RxString _errorMessage = ''.obs;

  bool get isLoading => isLoadingObs.value;
  bool get isLoadingAction => isLoadingActionObs.value;
  String get errorMessage => _errorMessage.value;

  NotificationController get _notif => Get.find<NotificationController>();

  dynamic get decisions => null;

  dynamic get content => null;

  Future<MeetingMinute?> getMeetingMinuteByMeetingId(int id) async {
    try {
      final data = await _getMeetingMinuteByMeetingId.execute(id);

      return data;
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

  /// Approve meeting minute
  Future<bool> approveMeetingMinute(int meetingMinuteId) async {
    try {
      isLoadingActionObs.value = true;

      debugPrint(
        '[MeetingMinuteController] Approving meeting minute with ID: $meetingMinuteId',
      );

      // Call use case to approve meeting minute
      await _approveMeetingMinute.execute(meetingMinuteId);

      isLoadingActionObs.value = false;

      debugPrint(
        '[MeetingMinuteController] Meeting minute approved successfully',
      );

      _notif.showSuccess('Notulen rapat berhasil disetujui');
      return true;
    } on ApiException catch (e) {
      isLoadingActionObs.value = false;
      debugPrint(
        '[MeetingMinuteController] ApiException in approveMeetingMinute: ${e.message}',
      );
      _notif.showError(e.message);
      return false;
    } catch (e) {
      isLoadingActionObs.value = false;
      debugPrint(
        '[MeetingMinuteController] Exception in approveMeetingMinute: $e',
      );
      _notif.showError('Gagal menyetujui notulen: ${e.toString()}');
      return false;
    }
  }
}
