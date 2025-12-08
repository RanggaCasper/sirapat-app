import 'package:sirapat_app/domain/repositories/meeting_minute_repository.dart';

class ApproveMeetingMinuteUseCase {
  final MeetingMinuteRepository _repository;

  ApproveMeetingMinuteUseCase(this._repository);

  Future<void> execute(int meetingMinuteId) async {
    return await _repository.approveMeetingMinute(meetingMinuteId);
  }
}
