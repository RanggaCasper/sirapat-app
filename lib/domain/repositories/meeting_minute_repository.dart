import 'package:sirapat_app/domain/entities/meeting_minute.dart';

abstract class MeetingMinuteRepository {
  Future<MeetingMinute> getMeetingById(int meetingId);
  Future<void> approveMeetingMinute(int meetingMinuteId);
  Future<MeetingMinute> updateMeetingMinute({
    required int meetingMinuteId,
    String? originalText,
    String? summary,
    String? pembahasan,
    List<String>? keputusan,
    List<String>? tindakan,
    List<Map<String, dynamic>>? anggaran,
    String? totalAnggaran,
    String? catatanAnggaran,
  });
}
