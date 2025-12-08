import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sirapat_app/app/util/form_error_handler.dart';
import 'package:sirapat_app/data/models/api_exception.dart';
import 'package:sirapat_app/domain/usecases/participant/invite_participant_usecase.dart';
import 'package:sirapat_app/presentation/shared/widgets/custom_notification.dart';

class ParticipantController extends GetxController {
  final InviteParticipantUseCase _inviteParticipantUseCase;

  ParticipantController(this._inviteParticipantUseCase);

  // Observables
  final RxBool isLoadingObs = false.obs;
  final RxBool isLoadingActionObs = false.obs;
  final RxMap<String, String> fieldErrors = <String, String>{}.obs;
  final RxString _errorMessage = ''.obs;

  bool get isLoading => isLoadingObs.value;
  bool get isLoadingAction => isLoadingActionObs.value;
  String get errorMessage => _errorMessage.value;

  NotificationController get _notif => Get.find<NotificationController>();

  Future<void> inviteParticipant({
    required int meetingId,
    required String identifier,
  }) async {
    try {
      isLoadingActionObs.value = true;
      _errorMessage.value = '';
      FormErrorHandler.clearAllFieldErrors(fieldErrors);

      final result = await _inviteParticipantUseCase.execute(
        InviteParticipantParams(meetingId: meetingId, identifier: identifier),
      );

      _notif.showSuccess('Peserta ${result.userId} berhasil diundang');
    } on ApiException catch (e) {
      debugPrint('[ParticipantController] ApiException: ${e.message}');

      _errorMessage.value = e.message;

      final errors = FormErrorHandler.handleApiException(e);
      fieldErrors.addAll(errors);

      if (errors.isEmpty) {
        fieldErrors['participant'] = e.message;
      }

      _notif.showError(e.message);
    } catch (e) {
      debugPrint('[ParticipantController] Exception: $e');
      final msg = 'Gagal mengundang peserta: $e';

      _errorMessage.value = msg;
      fieldErrors['participant'] = msg;

      _notif.showError(msg);
    } finally {
      isLoadingActionObs.value = false;
    }
  }
}
