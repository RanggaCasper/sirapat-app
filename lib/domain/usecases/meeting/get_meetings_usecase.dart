import 'package:sirapat_app/domain/entities/meeting.dart';
import 'package:sirapat_app/domain/repositories/meeting_repository.dart';

class GetMeetingsUseCase {
  final MeetingRepository repository;

  GetMeetingsUseCase(this.repository);

  Future<List<Meeting>> execute() {
    return repository.getAll();
  }
}
