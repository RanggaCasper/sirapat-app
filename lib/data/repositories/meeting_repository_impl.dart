import 'package:flutter/foundation.dart';
import 'package:sirapat_app/domain/entities/meeting.dart';
import 'package:sirapat_app/domain/repositories/meeting_repository.dart';
import 'package:sirapat_app/data/providers/network/requests/meeting/meeting_get_request.dart';
import 'package:sirapat_app/data/providers/network/requests/meeting/meeting_get_by_id_request.dart';
import 'package:sirapat_app/data/providers/network/requests/meeting/meeting_get_passcode_by_id_request.dart';
import 'package:sirapat_app/data/providers/network/requests/meeting/meeting_create_request.dart';
import 'package:sirapat_app/data/providers/network/requests/meeting/meeting_update_request.dart';
import 'package:sirapat_app/data/providers/network/requests/meeting/meeting_update_status_request.dart';
import 'package:sirapat_app/data/providers/network/requests/meeting/meeting_delete_request.dart';
import 'package:sirapat_app/data/providers/network/requests/meeting/meeting_join_by_code_request.dart';
import 'package:sirapat_app/data/models/api_response_model.dart';
import 'package:sirapat_app/data/models/meeting_model.dart';
import 'package:sirapat_app/data/models/api_exception.dart';
import 'package:sirapat_app/data/providers/network/api_provider.dart';

class MeetingRepositoryImpl extends MeetingRepository {
  @override
  Future<List<Meeting>> getMeetings() async {
    try {
      final request = GetMeetingsRequest();
      final response = await request.request();

      debugPrint('[MeetingRepository] Get Meetings API Response: $response');

      // Parse response using ApiResponse
      final apiResponse = ApiResponse.fromJson(response as Map<String, dynamic>, (
        data,
      ) {
        // Handle if data is directly a list
        if (data is List) {
          debugPrint(
            '[MeetingRepository] Data is directly a List with ${data.length} items',
          );
          final meetings = data
              .map(
                (item) => MeetingModel.fromJson(item as Map<String, dynamic>),
              )
              .toList();
          debugPrint('[MeetingRepository] Parsed ${meetings.length} meetings');
          return meetings;
        }
        // Check if data is a Map with 'data' key (nested structure)
        if (data is Map<String, dynamic> && data.containsKey('data')) {
          final innerData = data['data'];
          if (innerData is List) {
            final meetings = innerData.map((item) {
              return MeetingModel.fromJson(item as Map<String, dynamic>);
            }).toList();
            debugPrint(
              '[MeetingRepository] Parsed ${meetings.length} meetings from nested data',
            );
            return meetings;
          }
        }
        return <MeetingModel>[];
      });

      if (!apiResponse.status) {
        throw ApiException.fromJson(response);
      }

      final meetings = apiResponse.data;
      debugPrint(
        '[MeetingRepository] API Response data type: ${meetings.runtimeType}',
      );
      debugPrint(
        '[MeetingRepository] API Response data length: ${meetings?.length ?? 0}',
      );

      if (meetings != null) {
        final result = List<Meeting>.from(meetings);
        debugPrint('[MeetingRepository] Returning ${result.length} meetings');
        return result;
      }

      return [];
    } on ApiException catch (e) {
      debugPrint(
        '[MeetingRepository] ApiException in getMeetings: ${e.message}',
      );
      rethrow;
    } catch (e) {
      debugPrint('[MeetingRepository] Exception in getMeetings: $e');
      throw ApiException(
        status: false,
        message: 'Failed to fetch meetings: ${e.toString()}',
      );
    }
  }

  @override
  Future<Meeting> getMeetingById(int id) async {
    try {
      final request = GetMeetingByIdRequest(id: id);
      final response = await request.request();

      final apiResponse = ApiResponse.fromJson(
        response as Map<String, dynamic>,
        (data) => MeetingModel.fromJson(data as Map<String, dynamic>),
      );

      if (!apiResponse.status || apiResponse.data == null) {
        throw ApiException.fromJson(response);
      }

      return apiResponse.data as Meeting;
    } on ApiException catch (e) {
      debugPrint(
        '[MeetingRepository] ApiException in getMeetingById: ${e.message}',
      );
      rethrow;
    } catch (e) {
      debugPrint('[MeetingRepository] Exception in getMeetingById: $e');
      throw ApiException(
        status: false,
        message: 'Failed to fetch meeting: ${e.toString()}',
      );
    }
  }

  @override
  Future<Meeting> createMeeting({
    required String title,
    String? description,
    String? location,
    String? agenda,
    required String date,
    required String startTime,
    required String endTime,
    String status = 'scheduled',
    bool? hasPasscode,
  }) async {
    try {
      final request = CreateMeetingRequest(
        title: title,
        description: description,
        location: location,
        agenda: agenda,
        date: date,
        startTime: startTime,
        endTime: endTime,
        status: status,
        hasPasscode: hasPasscode,
      );
      final response = await request.request();

      if (response is Map<String, dynamic> && response.containsKey('errors')) {
        throw ApiException.fromJson(response);
      }

      final apiResponse = ApiResponse.fromJson(
        response as Map<String, dynamic>,
        (data) => MeetingModel.fromJson(data as Map<String, dynamic>),
      );

      if (!apiResponse.status || apiResponse.data == null) {
        throw ApiException.fromJson(response);
      }

      return apiResponse.data as Meeting;
    } on ApiException catch (e) {
      debugPrint(
        '[MeetingRepository] ApiException in createMeeting: ${e.message}',
      );
      debugPrint('[MeetingRepository] Errors: ${e.errors}');
      rethrow;
    } catch (e) {
      debugPrint('[MeetingRepository] Exception in createMeeting: $e');
      throw ApiException(
        status: false,
        message: 'Failed to create meeting: ${e.toString()}',
      );
    }
  }

  @override
  Future<Meeting> updateMeeting({
    required int id,
    required String title,
    String? description,
    String? location,
    String? agenda,
    required String date,
    required String startTime,
    required String endTime,
    String? status,
  }) async {
    try {
      final request = UpdateMeetingRequest(
        id: id,
        title: title,
        description: description,
        location: location,
        agenda: agenda,
        date: date,
        startTime: startTime,
        endTime: endTime,
        status: status,
      );
      final response = await request.request();

      if (response is Map<String, dynamic> && response.containsKey('errors')) {
        throw ApiException.fromJson(response);
      }

      final apiResponse = ApiResponse.fromJson(
        response as Map<String, dynamic>,
        (data) => MeetingModel.fromJson(data as Map<String, dynamic>),
      );

      if (!apiResponse.status || apiResponse.data == null) {
        throw ApiException.fromJson(response);
      }

      return apiResponse.data as Meeting;
    } on ApiException catch (e) {
      debugPrint(
        '[MeetingRepository] ApiException in updateMeeting: ${e.message}',
      );
      debugPrint('[MeetingRepository] Errors: ${e.errors}');
      rethrow;
    } catch (e) {
      debugPrint('[MeetingRepository] Exception in updateMeeting: $e');
      throw ApiException(
        status: false,
        message: 'Failed to update meeting: ${e.toString()}',
      );
    }
  }

  @override
  Future<Meeting> updateMeetingStatus({
    required int id,
    required String status,
  }) async {
    try {
      final request = UpdateMeetingStatusRequest(id: id, status: status);
      final response = await request.request();

      if (response is Map<String, dynamic> && response.containsKey('errors')) {
        throw ApiException.fromJson(response);
      }

      final apiResponse = ApiResponse.fromJson(
        response as Map<String, dynamic>,
        (data) => MeetingModel.fromJson(data as Map<String, dynamic>),
      );

      if (!apiResponse.status || apiResponse.data == null) {
        throw ApiException.fromJson(response);
      }

      return apiResponse.data as Meeting;
    } on ApiException catch (e) {
      debugPrint(
        '[MeetingRepository] ApiException in updateMeetingStatus: ${e.message}',
      );
      rethrow;
    } catch (e) {
      debugPrint('[MeetingRepository] Exception in updateMeetingStatus: $e');
      throw ApiException(
        status: false,
        message: 'Failed to update meeting status: ${e.toString()}',
      );
    }
  }

  @override
  Future<bool> deleteMeeting(int id) async {
    try {
      final request = DeleteMeetingRequest(id: id);
      final response = await request.request();

      final apiResponse = ApiResponse.fromJson(
        response as Map<String, dynamic>,
        (data) => data,
      );

      if (!apiResponse.status) {
        throw ApiException.fromJson(response);
      }

      return true;
    } on ApiException catch (e) {
      debugPrint(
        '[MeetingRepository] ApiException in deleteMeeting: ${e.message}',
      );
      rethrow;
    } catch (e) {
      debugPrint('[MeetingRepository] Exception in deleteMeeting: $e');
      throw ApiException(
        status: false,
        message: 'Failed to delete meeting: ${e.toString()}',
      );
    }
  }

  @override
  Future<Meeting?> joinMeetingByCode(String passcode) async {
    try {
      final request = JoinMeetingByCodeRequest(passcode: passcode);
      final response = await request.request();

      debugPrint('[MeetingRepository] -1 Join by passcode response: $response');

      if (response is Map<String, dynamic>) {
        // Check if response has error status
        if (response['status'] == false || response.containsKey('errors')) {
          final message = response['message'] ?? 'Terjadi kesalahan';
          debugPrint('[MeetingRepository] API Error response: $response');
          debugPrint('[MeetingRepository] Extracted message: $message');
          throw ApiException(status: false, message: message);
        }
      }

      final apiResponse = ApiResponse.fromJson(
        response as Map<String, dynamic>,
        (data) {
          debugPrint('[MeetingRepository] 0 Join by passcode data: $data');
          if (data == null) {
            throw ApiException(
              status: false,
              message: 'Data rapat tidak ditemukan',
            );
          }
          return MeetingModel.fromJson(data as Map<String, dynamic>);
        },
      );

      if (!apiResponse.status) {
        throw ApiException(status: false, message: 'Gagal mengikuti rapat');
      }

      return apiResponse.data as Meeting;
    } on ApiException catch (e) {
      debugPrint('[MeetingRepository] 1 ApiException caught: ${e.message}');
      rethrow;
    } on AppException catch (e) {
      // Handle other app exceptions (BadRequestException, UnauthorisedException, etc)
      debugPrint('[MeetingRepository] 2 AppException caught: ${e.message}');
      throw ApiException(status: false, message: "Passcode rapat tidak valid");
    } catch (e) {
      debugPrint('[MeetingRepository] 3 Unexpected exception: $e');
      throw ApiException(status: false, message: 'Gagal mengikuti rapat');
    }
  }

  @override
  Future<List<Meeting>> getMeetingsByStatus(String status) async {
    try {
      final allMeetings = await getMeetings();
      return allMeetings.where((meeting) => meeting.status == status).toList();
    } catch (e) {
      debugPrint('[MeetingRepository] Exception in getMeetingsByStatus: $e');
      throw ApiException(
        status: false,
        message: 'Failed to fetch meetings by status: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<Meeting>> getUpcomingMeetings() async {
    try {
      final allMeetings = await getMeetings();
      final now = DateTime.now();

      return allMeetings.where((meeting) {
        try {
          final meetingDate = DateTime.parse(meeting.date);
          return meetingDate.isAfter(now) &&
              (meeting.status == 'scheduled' || meeting.status == 'ongoing');
        } catch (e) {
          return false;
        }
      }).toList();
    } catch (e) {
      debugPrint('[MeetingRepository] Exception in getUpcomingMeetings: $e');
      throw ApiException(
        status: false,
        message: 'Failed to fetch upcoming meetings: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<Meeting>> getPastMeetings() async {
    try {
      final allMeetings = await getMeetings();
      final now = DateTime.now();

      return allMeetings.where((meeting) {
        try {
          final meetingDate = DateTime.parse(meeting.date);
          return meetingDate.isBefore(now) || meeting.status == 'completed';
        } catch (e) {
          return false;
        }
      }).toList();
    } catch (e) {
      debugPrint('[MeetingRepository] Exception in getPastMeetings: $e');
      throw ApiException(
        status: false,
        message: 'Failed to fetch past meetings: ${e.toString()}',
      );
    }
  }

  @override
  Future<String> getPasscodeById(int id) async {
    try {
      final request = GetPasscodeByIdRequest(id: id);
      final response = await request.request();

      final apiResponse = ApiResponse.fromJson(response, (data) => data);

      if (!apiResponse.status || apiResponse.data == null) {
        throw ApiException.fromJson(response);
      }

      return apiResponse.data as String;
    } on ApiException catch (e) {
      debugPrint(
        '[MeetingRepository] ApiException in getMeetingById: ${e.message}',
      );
      rethrow;
    } catch (e) {
      debugPrint('[MeetingRepository] Exception in getMeetingById: $e');
      throw ApiException(
        status: false,
        message: 'Failed to fetch meeting: ${e.toString()}',
      );
    }
  }
}
