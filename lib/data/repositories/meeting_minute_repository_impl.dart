import 'package:flutter/foundation.dart';
import 'package:sirapat_app/data/providers/network/requests/meeting_minute/meeting_minute_get_by_meeting_id_request.dart';
import 'package:sirapat_app/data/providers/network/requests/meeting_minute/meeting_minute_approve_request.dart';
import 'package:sirapat_app/data/providers/network/requests/meeting_minute/meeting_minute_update_request.dart';
import 'package:sirapat_app/domain/entities/meeting_minute.dart';
import 'package:sirapat_app/domain/repositories/meeting_minute_repository.dart';
import 'package:sirapat_app/data/models/api_response_model.dart';
import 'package:sirapat_app/data/models/meeting_minute_model.dart';
import 'package:sirapat_app/data/models/api_exception.dart';

class MeetingMinuteRepositoryImpl extends MeetingMinuteRepository {
  @override
  Future<MeetingMinute> getMeetingById(int meetingId) async {
    try {
      final request = GetMeetingMinuteByMeetingIdRequest(meetingId: meetingId);
      final response = await request.request();
      debugPrint(
        '[MeetingMinute] getmeetingminutebymeetingid response: $response',
      );

      if (response is Map<String, dynamic> && response.containsKey('errors')) {
        throw ApiException.fromJson(response);
      }

      final apiResponse = ApiResponse.fromJson(
        response as Map<String, dynamic>,
        (data) {
          // API returns data as a list of meeting minutes
          if (data is List && data.isNotEmpty) {
            return MeetingMinuteModel.fromJson(data[0] as Map<String, dynamic>);
          }
          throw ApiException(status: false, message: 'No meeting minute found');
        },
      );

      if (!apiResponse.status || apiResponse.data == null) {
        throw ApiException.fromJson(response);
      }

      return apiResponse.data as MeetingMinute;
    } on ApiException catch (e) {
      debugPrint(
        '[MeetingMinute] ApiException in getmeetingminutebymeetingid: ${e.message}',
      );
      debugPrint('[MeetingMinute] Errors: ${e.errors}');
      rethrow;
    } catch (e) {
      debugPrint(
        '[MeetingMinute] Exception in getmeetingminutebymeetingid: $e',
      );
      throw ApiException(
        status: false,
        message: 'Failed to get meeting minute: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> approveMeetingMinute(int meetingMinuteId) async {
    try {
      final request = ApproveMeetingMinuteRequest(
        meetingMinuteId: meetingMinuteId,
      );
      final response = await request.request();

      debugPrint('[MeetingMinute] approvemeetingminute response: $response');

      if (response is Map<String, dynamic> && response.containsKey('errors')) {
        throw ApiException.fromJson(response);
      }

      final apiResponse = ApiResponse.fromJson(
        response as Map<String, dynamic>,
        (data) => data, // No data transformation needed for approve
      );

      if (!apiResponse.status) {
        throw ApiException(status: false, message: apiResponse.message);
      }

      debugPrint('[MeetingMinute] Meeting minute approved successfully');
    } on ApiException catch (e) {
      debugPrint(
        '[MeetingMinute] ApiException in approvemeetingminute: ${e.message}',
      );
      debugPrint('[MeetingMinute] Errors: ${e.errors}');
      rethrow;
    } catch (e) {
      debugPrint('[MeetingMinute] Exception in approvemeetingminute: $e');
      throw ApiException(
        status: false,
        message: 'Failed to approve meeting minute: ${e.toString()}',
      );
    }
  }

  @override
  Future<MeetingMinute> updateMeetingMinute({
    required int meetingMinuteId,
    String? originalText,
    String? summary,
    String? pembahasan,
    List<String>? keputusan,
    List<String>? tindakan,
    List<Map<String, dynamic>>? anggaran,
    String? totalAnggaran,
    String? catatanAnggaran,
  }) async {
    try {
      final request = UpdateMeetingMinuteRequest(
        meetingMinuteId: meetingMinuteId,
        originalText: originalText,
        summary: summary,
        pembahasan: pembahasan,
        keputusan: keputusan,
        tindakan: tindakan,
        anggaran: anggaran,
        totalAnggaran: totalAnggaran,
        catatanAnggaran: catatanAnggaran,
      );
      final response = await request.request();

      debugPrint('[MeetingMinute] updatemeetingminute response: $response');

      if (response is Map<String, dynamic> && response.containsKey('errors')) {
        throw ApiException.fromJson(response);
      }

      final apiResponse = ApiResponse.fromJson(
        response as Map<String, dynamic>,
        (data) => MeetingMinuteModel.fromJson(data as Map<String, dynamic>),
      );

      if (!apiResponse.status || apiResponse.data == null) {
        throw ApiException.fromJson(response);
      }

      return apiResponse.data as MeetingMinute;
    } on ApiException catch (e) {
      debugPrint(
        '[MeetingMinute] ApiException in updatemeetingminute: ${e.message}',
      );
      debugPrint('[MeetingMinute] Errors: ${e.errors}');
      rethrow;
    } catch (e) {
      debugPrint('[MeetingMinute] Exception in updatemeetingminute: $e');
      throw ApiException(
        status: false,
        message: 'Failed to update meeting minute: ${e.toString()}',
      );
    }
  }
}
