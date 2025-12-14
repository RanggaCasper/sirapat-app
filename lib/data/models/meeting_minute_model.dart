import 'package:sirapat_app/domain/entities/meeting_minute.dart';

class MeetingMinuteModel extends MeetingMinute {
  MeetingMinuteModel({
    required super.id,
    required super.meetingId,
    super.originalText,
    super.summary,
    super.pembahasan,
    super.keputusan,
    super.tindakan,
    super.anggaran,
    super.totalAnggaran,
    super.catatanAnggaran,
    super.meeting,
    super.approver,
    super.approvedBy,
    super.approvedAt,
    super.createdAt,
    super.updatedAt,
  });

  factory MeetingMinuteModel.fromJson(Map<String, dynamic> json) {
    // Parse string list fields (keputusan, tindakan)
    List<String>? parseStringList(dynamic field) {
      if (field == null) return null;
      if (field is List) {
        return field.map((e) => e.toString()).toList();
      }
      return null;
    }

    // Parse anggaran list
    List<Map<String, dynamic>>? parseAnggaran(dynamic field) {
      if (field == null) return null;
      if (field is List) {
        return field.map((e) => e as Map<String, dynamic>).toList();
      }
      return null;
    }

    return MeetingMinuteModel(
      id: json['id'] != null
          ? (json['id'] is String ? int.parse(json['id']) : json['id'])
          : (json['meeting_minute_id'] is String
              ? int.parse(json['meeting_minute_id'])
              : json['meeting_minute_id']),
      meetingId: json['meeting_id'] != null
          ? (json['meeting_id'] is String
              ? int.parse(json['meeting_id'])
              : json['meeting_id'])
          : 0,
      originalText: json['original_text'],
      summary: json['summary'],
      pembahasan: json['pembahasan'],
      keputusan: parseStringList(json['keputusan']),
      tindakan: parseStringList(json['tindakan']),
      anggaran: parseAnggaran(json['anggaran']),
      totalAnggaran: json['total_anggaran'],
      catatanAnggaran: json['catatan_anggaran'],
      meeting: json['meeting'],
      approver: json['approver'],
      approvedBy: json['approved_by'] != null
          ? (json['approved_by'] is String
              ? int.parse(json['approved_by'])
              : json['approved_by'])
          : null,
      approvedAt: json['approved_at'] != null
          ? DateTime.parse(json['approved_at'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "meeting_id": meetingId,
      "original_text": originalText,
      "summary": summary,
      "pembahasan": pembahasan,
      "keputusan": keputusan,
      "tindakan": tindakan,
      "anggaran": anggaran,
      "total_anggaran": totalAnggaran,
      "catatan_anggaran": catatanAnggaran,
      "meeting": meeting,
      "approver": approver,
      "approved_by": approvedBy,
      "approved_at": approvedAt?.toIso8601String(),
      "created_at": createdAt?.toIso8601String(),
      "updated_at": updatedAt?.toIso8601String(),
    };
  }
}
