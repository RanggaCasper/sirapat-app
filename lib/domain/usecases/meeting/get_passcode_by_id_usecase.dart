import 'package:sirapat_app/domain/repositories/meeting_repository.dart';

class GetPasscodeByIdUseCase {
  final MeetingRepository repository;

  GetPasscodeByIdUseCase(this.repository);

  Future<String> execute(int id) {
    return repository.getPasscodeById(id);
  }
}
