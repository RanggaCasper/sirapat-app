import 'package:sirapat_app/domain/entities/meeting_minute.dart';
import 'package:sirapat_app/domain/repositories/meeting_minute_repository.dart';

class GetMeetingMinuteByMeetingIdUseCase {
  final MeetingMinuteRepository repository;

  GetMeetingMinuteByMeetingIdUseCase(this.repository);

  Future<MeetingMinute> execute(int id) {
    return repository.getMeetingById(id);
  }
}
