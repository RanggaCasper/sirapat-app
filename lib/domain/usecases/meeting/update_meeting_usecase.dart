import 'package:sirapat_app/domain/entities/meeting.dart';
import 'package:sirapat_app/domain/repositories/meeting_repository.dart';

class UpdateMeetingParams {
  final int id;
  final String title;
  final String? description;
  final String? location;
  final String? agenda;
  final String date;
  final String startTime;
  final String endTime;
  final String? status;

  UpdateMeetingParams({
    required this.id,
    required this.title,
    this.description,
    this.location,
    this.agenda,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.status,
  });
}

class UpdateMeetingUseCase {
  final MeetingRepository repository;

  UpdateMeetingUseCase(this.repository);

  Future<Meeting> execute(UpdateMeetingParams params) {
    return repository.updateMeeting(
      id: params.id,
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
