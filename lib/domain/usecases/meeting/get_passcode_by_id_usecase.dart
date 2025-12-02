import 'package:sirapat_app/domain/entities/meeting.dart';
import 'package:sirapat_app/domain/repositories/meeting_repository.dart';

class GetPasscodeByIdUseCase {
  final MeetingRepository repository;

  GetPasscodeByIdUseCase(this.repository);

  Future<Meeting> execute(int id) {
    return repository.getPasscodeById(id);
  }
}
