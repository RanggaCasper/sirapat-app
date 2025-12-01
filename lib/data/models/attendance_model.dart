import 'package:sirapat_app/data/models/user_model.dart';

class AttendanceModel {
  final int id;
  final int userId;
  final int meetingId;
  final String date;
  final String checkInTime;
  final String status;
  final String createdAt;
  final String updatedAt;
  final UserModel? participant;

  AttendanceModel({
    required this.id,
    required this.userId,
    required this.meetingId,
    required this.date,
    required this.checkInTime,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.participant,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      meetingId: json['meeting_id'] ?? 0,
      date: json['date'] ?? '',
      checkInTime: json['check_in_time'] ?? '',
      status: json['status'] ?? 'unknown',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      participant: json['participant'] != null
          ? UserModel.fromJson(json['participant'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'meeting_id': meetingId,
      'date': date,
      'check_in_time': checkInTime,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'participant': participant?.toJson(),
    };
  }

  // Helper method to get status color
  String getStatusDisplay() {
    switch (status.toLowerCase()) {
      case 'present':
        return 'Hadir';
      case 'absent':
        return 'Tidak Hadir';
      case 'late':
        return 'Terlambat';
      default:
        return status;
    }
  }

  // Helper method to check if present
  bool get isPresent => status.toLowerCase() == 'present';
}
