class Participant {
  final int id;
  final int meetingId;
  final int userId;
  final String invitationStatus;
  final bool attended;
  final String? createdAt;
  final String? updatedAt;

  Participant({
    required this.id,
    required this.meetingId,
    required this.userId,
    required this.invitationStatus,
    required this.attended,
    this.createdAt,
    this.updatedAt,
  });

  factory Participant.fromJson(Map<String, dynamic> json) {
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

    return Participant(
      id: parseInt(json['id']),
      meetingId: parseInt(json['meeting_id']),
      userId: parseInt(json['user_id']),
      invitationStatus: json['invitation_status'] ?? 'pending',
      attended: parseBool(json['attended']),
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  // Map<String, dynamic> toJson() {
  //   return {
  //     'id': id,
  //     'meeting_id': meetingId,
  //     'user_id': userId,
  //     'invitation_status': invitationStatus,
  //     'attended': attended,
  //     'created_at': createdAt,
  //     'updated_at': updatedAt,
  //   };
  // }
}
