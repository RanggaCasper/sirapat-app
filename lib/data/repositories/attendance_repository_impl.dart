import 'package:flutter/foundation.dart';
import 'package:sirapat_app/domain/entities/attendance.dart';
import 'package:sirapat_app/data/providers/network/requests/attendance/attendance_get_by_meeting_id_request.dart';
import 'package:sirapat_app/domain/repositories/attendance_repository.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  @override
  Future<List<Attendance>> getAttendance(int meetingId) async {
    try {
      final request = AttendanceGetByMeetingIdRequest(meetingId: meetingId);
      final response = await request.request();

      if (response['status'] == true && response['data'] != null) {
        final attendanceList = (response['data'] as List)
            .map((item) => Attendance.fromJson(item as Map<String, dynamic>))
            .toList();
        return attendanceList;
      }

      return [];
    } catch (e) {
      debugPrint('[AttendanceRepositoryImpl] Error getting attendance: $e');
      rethrow;
    }
  }
}
