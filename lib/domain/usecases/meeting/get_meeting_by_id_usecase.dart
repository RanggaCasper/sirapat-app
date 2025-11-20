import 'package:sirapat_app/domain/entities/meeting.dart';
import 'package:sirapat_app/domain/repositories/meeting_repository.dart';

class GetMeetingByIdUseCase {
  final MeetingRepository repository;

  GetMeetingByIdUseCase(this.repository);

  Future<Meeting> execute(int id) {
    return repository.getMeetingById(id);
  }
}
