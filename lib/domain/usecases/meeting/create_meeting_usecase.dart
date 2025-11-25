import 'package:sirapat_app/domain/entities/meeting.dart';
import 'package:sirapat_app/domain/repositories/meeting_repository.dart';

class CreateMeetingParams {
  final String title;
  final String? description;
  final String? location;
  final String? agenda;
  final String date;
  final String startTime;
  final String endTime;
  final String status;

  CreateMeetingParams({
    required this.title,
    this.description,
    this.location,
    this.agenda,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.status = 'scheduled',
  });
}

class CreateMeetingUseCase {
  final MeetingRepository repository;

  CreateMeetingUseCase(this.repository);

  Future<Meeting> execute(CreateMeetingParams params) {
    return repository.createMeeting(
      title: params.title,
      description: params.description,
      location: params.location,
      agenda: params.agenda,
      date: params.date,
      startTime: params.startTime,
      endTime: params.endTime,
      status: params.status,
    );
  }
}
