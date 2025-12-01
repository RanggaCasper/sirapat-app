import 'package:sirapat_app/domain/entities/attendance.dart';
import 'package:sirapat_app/domain/repositories/attendance_repository.dart';

class GetAttendanceUseCase {
  final AttendanceRepository repository;

  GetAttendanceUseCase(this.repository);

  Future<List<Attendance>> call(int meetingId) async {
    return await repository.getAttendance(meetingId);
  }
}
