import 'package:sirapat_app/domain/repositories/meeting_repository.dart';

class DeleteMeetingUseCase {
  final MeetingRepository repository;

  DeleteMeetingUseCase(this.repository);

  Future<bool> execute(int id) {
    return repository.deleteMeeting(id);
  }
}
