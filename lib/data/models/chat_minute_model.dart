import 'package:sirapat_app/data/models/user_model.dart';

class ChatMinuteModel {
  final int id;
  final int meetingId;
  final String message;
  final int sentBy;
  final String createdAt;
  final String updatedAt;
  final UserModel sender;

  ChatMinuteModel({
    required this.id,
    required this.meetingId,
    required this.message,
    required this.sentBy,
    required this.createdAt,
    required this.updatedAt,
    required this.sender,
  });

  factory ChatMinuteModel.fromJson(Map<String, dynamic> json) {
    return ChatMinuteModel(
      id: json['id'] as int? ?? 0,
      meetingId: json['meeting_id'] as int? ?? 0,
      message: json['message'] as String? ?? '',
      sentBy: json['sent_by'] as int? ?? 0,
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
      sender: json['sender'] != null
          ? UserModel.fromJson(json['sender'] as Map<String, dynamic>)
          : UserModel(
              id: 0,
              nip: '',
              username: '',
              email: '',
              phone: '',
              fullName: 'Unknown',
              profilePhoto: null,
              role: 'unknown',
              createdAt: '',
              updatedAt: '',
              divisionId: null,
            ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'meeting_id': meetingId,
      'message': message,
      'sent_by': sentBy,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'sender': sender.toJson(),
    };
  }

  ChatMinuteModel copyWith({
    int? id,
    int? meetingId,
    String? message,
    int? sentBy,
    String? createdAt,
    String? updatedAt,
    UserModel? sender,
  }) {
    return ChatMinuteModel(
      id: id ?? this.id,
      meetingId: meetingId ?? this.meetingId,
      message: message ?? this.message,
      sentBy: sentBy ?? this.sentBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      sender: sender ?? this.sender,
    );
  }

  @override
  String toString() =>
      'ChatMinuteModel(id: $id, meetingId: $meetingId, message: $message, sentBy: $sentBy, sender: ${sender.fullName})';
}
