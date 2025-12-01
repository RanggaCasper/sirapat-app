import 'package:sirapat_app/domain/entities/attendance.dart';

abstract class AttendanceRepository {
  Future<List<Attendance>> getAttendance(int meetingId);
}
