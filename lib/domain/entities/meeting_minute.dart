class MeetingMinute {
  final int id;
  final int meetingId;
  final String? originalText;
  final String? summary;
  final String? pembahasan;
  final List<String>? keputusan;
  final List<String>? tindakan;
  final List<Map<String, dynamic>>? anggaran;
  final String? totalAnggaran;
  final String? catatanAnggaran;
  final dynamic meeting;
  final dynamic approver;
  final int? approvedBy;
  final DateTime? approvedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  MeetingMinute({
    required this.id,
    required this.meetingId,
    this.originalText,
    this.summary,
    this.pembahasan,
    this.keputusan,
    this.tindakan,
    this.anggaran,
    this.totalAnggaran,
    this.catatanAnggaran,
    this.meeting,
    this.approver,
    this.approvedBy,
    this.approvedAt,
    this.createdAt,
    this.updatedAt,
  });
}
