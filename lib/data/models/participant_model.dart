import 'package:sirapat_app/domain/entities/participant.dart';

class ParticipantModel extends Participant {
  ParticipantModel({
    required super.id,
    required super.meetingId,
    required super.userId,
    required super.invitationStatus,
    required super.attended,
    super.createdAt,
    super.updatedAt,
  });

  factory ParticipantModel.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    bool parseBool(dynamic value) {
      if (value is bool) return value;
      if (value is int) return value == 1;
      if (value is String) {
        return value.toLowerCase() == "true" || value == "1";
      }
      return false;
    }

    return ParticipantModel(
      id: parseInt(json['id']),
      meetingId: parseInt(json['meeting_id']),
      userId: parseInt(json['user_id']),
      invitationStatus: json['invitation_status'] ?? "pending",
      attended: parseBool(json['attended']),
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}
