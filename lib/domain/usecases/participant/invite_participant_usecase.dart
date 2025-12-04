import 'package:sirapat_app/domain/entities/participant.dart';
import 'package:sirapat_app/domain/repositories/participant_repository.dart';

class InviteParticipantParams {
  final int meetingId;
  final String identifier;

  InviteParticipantParams({required this.meetingId, required this.identifier});
}

class InviteParticipantUseCase {
  final ParticipantRepository repository;

  InviteParticipantUseCase(this.repository);

  Future<Participant> execute(InviteParticipantParams params) {
    return repository.inviteParticipant(
      meetingId: params.meetingId,
      identifier: params.identifier,
    );
  }
}
