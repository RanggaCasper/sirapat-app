import 'package:sirapat_app/domain/entities/participant.dart';

abstract class ParticipantRepository {
  Future<Participant> inviteParticipant({
    required int meetingId,
    required String identifier,
  });
}
