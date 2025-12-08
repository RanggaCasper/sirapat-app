import 'package:sirapat_app/domain/entities/meeting_minute.dart';

abstract class MeetingMinuteRepository {
  Future<MeetingMinute> getMeetingById(int meetingId);
  Future<void> approveMeetingMinute(int meetingMinuteId);
}
