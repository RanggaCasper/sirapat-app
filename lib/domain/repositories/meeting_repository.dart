import 'package:sirapat_app/domain/entities/meeting.dart';

abstract class MeetingRepository {
  Future<List<Meeting>> getMeetings();

  Future<Meeting> getMeetingById(int id);

  Future<Meeting> createMeeting({
    required String title,
    String? description,
    String? location,
    String? agenda,
    required String date,
    required String startTime,
    required String endTime,
    String status = 'scheduled',
    bool? hasPasscode,
  });

  Future<Meeting> updateMeeting({
    required int id,
    required String title,
    String? description,
    String? location,
    String? agenda,
    required String date,
    required String startTime,
    required String endTime,
    String? status,
  });

  Future<Meeting> updateMeetingStatus({
    required int id,
    required String status,
  });

  Future<bool> deleteMeeting(int id);

  Future<Meeting?> joinMeetingByCode(String passcode);

  Future<List<Meeting>> getMeetingsByStatus(String status);

  Future<List<Meeting>> getUpcomingMeetings();

  Future<List<Meeting>> getPastMeetings();
}
