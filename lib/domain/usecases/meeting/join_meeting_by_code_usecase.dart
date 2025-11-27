import 'package:sirapat_app/domain/entities/meeting.dart';
import 'package:sirapat_app/domain/repositories/meeting_repository.dart';

class JoinMeetingByCodeUseCase {
  final MeetingRepository repository;

  JoinMeetingByCodeUseCase(this.repository);

  Future<Meeting?> execute(String passcode) {
    return repository.joinMeetingByCode(passcode);
  }
}
