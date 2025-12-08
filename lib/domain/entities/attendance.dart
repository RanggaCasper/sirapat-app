import 'package:sirapat_app/domain/entities/user.dart';

class Attendance {
  final int? id;
  final int userId;
  final int meetingId;
  final DateTime date;
  final DateTime checkInTime;
  final AttendanceStatus status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final User? participant;

  Attendance({
    this.id,
    required this.userId,
    required this.meetingId,
    required this.date,
    required this.checkInTime,
    required this.status,
    this.createdAt,
    this.updatedAt,
    this.participant,
  });

  // Factory from JSON (for entity)
  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id'] is String ? int.tryParse(json['id']) : json['id'] as int?,
      userId: json['user_id'] is String
          ? int.parse(json['user_id'])
          : json['user_id'] as int,
      meetingId: json['meeting_id'] is String
          ? int.parse(json['meeting_id'])
          : json['meeting_id'] as int,
      date: json['date'] != null
          ? DateTime.parse(json['date'] as String)
          : DateTime.now(),
      checkInTime: json['check_in_time'] != null
          ? DateTime.parse(json['check_in_time'] as String)
          : DateTime.now(),
      status: AttendanceStatus.fromString(
        json['status'] as String? ?? 'unknown',
      ),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      participant: json['participant'] != null
          ? User.fromJson(json['participant'] as Map<String, dynamic>)
          : null,
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'meeting_id': meetingId,
      'date': date.toIso8601String(),
      'check_in_time': checkInTime.toIso8601String(),
      'status': status.value,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
      if (participant != null) 'participant': participant!.toJson(),
    };
  }

  // CopyWith for immutability
  Attendance copyWith({
    int? id,
    int? userId,
    int? meetingId,
    DateTime? date,
    DateTime? checkInTime,
    AttendanceStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    User? participant,
  }) {
    return Attendance(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      meetingId: meetingId ?? this.meetingId,
      date: date ?? this.date,
      checkInTime: checkInTime ?? this.checkInTime,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      participant: participant ?? this.participant,
    );
  }

  // Helper getters
  bool get isPresent => status == AttendanceStatus.present;
  bool get isAbsent => status == AttendanceStatus.absent;
  bool get isLate => status == AttendanceStatus.late;

  String get statusDisplay => status.displayName;
  String get participantName => participant?.fullName ?? 'Unknown';

  @override
  String toString() {
    return 'Attendance(id: $id, userId: $userId, meetingId: $meetingId, '
        'date: $date, checkInTime: $checkInTime, status: ${status.value}, '
        'participant: ${participant?.fullName})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Attendance &&
        other.id == id &&
        other.userId == userId &&
        other.meetingId == meetingId &&
        other.date == date &&
        other.checkInTime == checkInTime &&
        other.status == status;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        meetingId.hashCode ^
        date.hashCode ^
        checkInTime.hashCode ^
        status.hashCode;
  }
}

// Enum for Attendance Status
enum AttendanceStatus {
  present('present', 'Hadir'),
  absent('absent', 'Tidak Hadir'),
  late('late', 'Terlambat'),
  excused('excused', 'Izin'),
  unknown('unknown', 'Tidak Diketahui');

  final String value;
  final String displayName;

  const AttendanceStatus(this.value, this.displayName);

  static AttendanceStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'present':
        return AttendanceStatus.present;
      case 'absent':
        return AttendanceStatus.absent;
      case 'late':
        return AttendanceStatus.late;
      case 'excused':
        return AttendanceStatus.excused;
      default:
        return AttendanceStatus.unknown;
    }
  }

  // Helper method untuk mendapatkan warna status
  String get colorHex {
    switch (this) {
      case AttendanceStatus.present:
        return '#4CAF50'; // Green
      case AttendanceStatus.absent:
        return '#F44336'; // Red
      case AttendanceStatus.late:
        return '#FF9800'; // Orange
      case AttendanceStatus.excused:
        return '#2196F3'; // Blue
      case AttendanceStatus.unknown:
        return '#9E9E9E'; // Grey
    }
  }
}
