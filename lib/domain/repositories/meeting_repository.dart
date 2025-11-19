import 'package:sirapat_app/domain/entities/meeting.dart';

abstract class MeetingRepository {
  Future<List<Meeting>> getAll();
}
