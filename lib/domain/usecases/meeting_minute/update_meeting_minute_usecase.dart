import 'package:sirapat_app/domain/entities/meeting_minute.dart';
import 'package:sirapat_app/domain/repositories/meeting_minute_repository.dart';

class UpdateMeetingMinuteUseCase {
  final MeetingMinuteRepository _repository;

  UpdateMeetingMinuteUseCase(this._repository);

  Future<MeetingMinute> execute({
    required int meetingMinuteId,
    String? originalText,
    String? summary,
    String? pembahasan,
    List<String>? keputusan,
    List<String>? tindakan,
    List<Map<String, dynamic>>? anggaran,
    String? totalAnggaran,
    String? catatanAnggaran,
  }) async {
    return await _repository.updateMeetingMinute(
      meetingMinuteId: meetingMinuteId,
      originalText: originalText,
      summary: summary,
      pembahasan: pembahasan,
      keputusan: keputusan,
      tindakan: tindakan,
      anggaran: anggaran,
      totalAnggaran: totalAnggaran,
      catatanAnggaran: catatanAnggaran,
    );
  }
}
