import 'dart:convert';
import 'package:sirapat_app/domain/entities/meeting_minute.dart';

class MeetingMinuteModel extends MeetingMinute {
  MeetingMinuteModel({
    required super.id,
    required super.meetingId,
    required super.content,
    super.originalText,
    super.summary,
    super.minutes,
    super.decisions,
    super.elements,
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

    // Parse elements field - handle both String (JSON encoded) and Map
    Map<String, dynamic>? parseElements(dynamic elementsField) {
      if (elementsField == null) return null;

      // If it's a String, parse it as JSON
      if (elementsField is String) {
        try {
          return jsonDecode(elementsField) as Map<String, dynamic>;
        } catch (e) {
          return null;
        }
      } else if (elementsField is Map<String, dynamic>) {
        return elementsField;
      } else {
        return null;
      }
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
          : 0, // Default value if not provided
      content: json['content'] ?? json['minutes'] ?? '',
      originalText: json['original_text'],
      summary: json['summary'],
      minutes: json['minutes'],
      decisions: parseDecisions(json['decisions']),
      elements: parseElements(json['elements']),
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
      "original_text": originalText,
      "summary": summary,
      "minutes": minutes,
      "decisions": decisions
          ?.map((e) => {"title": e.title, "description": e.description})
          .toList(),
      "elements": elements,
      "approved_by": approvedBy,
      "approved_at": approvedAt?.toIso8601String(),
    };
  }
}
