import 'package:sirapat_app/domain/entities/meeting_minute.dart';

class MeetingMinuteModel extends MeetingMinute {
  MeetingMinuteModel({
    required super.id,
    required super.meetingId,
    required super.content,
    super.decisions,
    super.approvedBy,
    super.approvedAt,
  });

  factory MeetingMinuteModel.fromJson(Map<String, dynamic> json) {
    return MeetingMinuteModel(
      id: json['id'] is String ? int.parse(json['id']) : json['id'],
      meetingId: json['meeting_id'] is String
          ? int.parse(json['meeting_id'])
          : json['meeting_id'],
      content: json['content'],
      decisions: json['decisions'] != null
          ? (json['decisions'] as List)
                .map(
                  (d) => Decision(
                    title: d is String ? d : d['title'],
                    description: d is String ? '' : (d['description'] ?? ''),
                  ),
                )
                .toList()
          : null,
      approvedBy: json['approved_by'] != null
          ? (json['approved_by'] is String
                ? int.parse(json['approved_by'])
                : json['approved_by'])
          : null,
      approvedAt: json['approved_at'] != null
          ? DateTime.parse(json['approved_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "meeting_id": meetingId,
      "content": content,
      "decisions": decisions
          ?.map((e) => {"title": e.title, "description": e.description})
          .toList(),
      "approved_by": approvedBy,
      "approved_at": approvedAt?.toIso8601String(),
    };
  }
}
