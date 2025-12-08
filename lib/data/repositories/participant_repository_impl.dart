import 'package:flutter/foundation.dart';
import 'package:sirapat_app/domain/entities/participant.dart';
import 'package:sirapat_app/domain/repositories/participant_repository.dart';
import 'package:sirapat_app/data/providers/network/requests/participant/invite_participant_request.dart';
import 'package:sirapat_app/data/models/api_response_model.dart';
import 'package:sirapat_app/data/models/participant_model.dart';
import 'package:sirapat_app/data/models/api_exception.dart';

class ParticipantRepositoryImpl extends ParticipantRepository {
  @override
  Future<Participant> inviteParticipant({
    required int meetingId,
    required String identifier,
  }) async {
    try {
      final request = InviteParticipantRequest(
        meetingId: meetingId,
        identifier: identifier,
      );
      final response = await request.request();
      debugPrint(
        '[ParticipantRepository] inviteParticipant response: $response',
      );

      if (response is Map<String, dynamic> && response.containsKey('errors')) {
        throw ApiException.fromJson(response);
      }

      final apiResponse = ApiResponse.fromJson(
        response as Map<String, dynamic>,
        (data) => ParticipantModel.fromJson(data as Map<String, dynamic>),
      );

      if (!apiResponse.status || apiResponse.data == null) {
        throw ApiException.fromJson(response);
      }

      return apiResponse.data as Participant;
    } on ApiException catch (e) {
      debugPrint(
        '[ParticipantRepository] ApiException in inviteParticipant: ${e.message}',
      );
      debugPrint('[ParticipantRepository] Errors: ${e.errors}');
      rethrow;
    } catch (e) {
      debugPrint('[ParticipantRepository] Exception in inviteParticipant: $e}');
      throw ApiException(
        status: false,
        message: 'Failed to invite participant: ${e.toString()}',
      );
    }
  }
}
