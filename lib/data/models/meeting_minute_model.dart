import 'dart:convert';
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
    // Parse decisions field - handle both String (JSON encoded) and List
    List<Decision>? parseDecisions(dynamic decisionsField) {
      if (decisionsField == null) return null;

      List decisionsData;

      // If it's a String, parse it as JSON
      if (decisionsField is String) {
        try {
          decisionsData = jsonDecode(decisionsField) as List;
        } catch (e) {
          return null;
        }
      } else if (decisionsField is List) {
        decisionsData = decisionsField;
      } else {
        return null;
      }

      return decisionsData.map((d) {
        return Decision(
          title: d is String ? d : d['title'],
          description: d is String ? '' : (d['description'] ?? ''),
        );
      }).toList();
    }

    return MeetingMinuteModel(
      id: json['id'] is String ? int.parse(json['id']) : json['id'],
      meetingId: json['meeting_id'] is String
          ? int.parse(json['meeting_id'])
          : json['meeting_id'],
      content: json['content'],
      decisions: parseDecisions(json['decisions']),
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
