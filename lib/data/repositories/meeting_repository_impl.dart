import 'package:sirapat_app/domain/entities/meeting.dart';

import 'package:sirapat_app/data/models/meeting_model.dart';
import 'package:sirapat_app/data/models/api_exception.dart';
import 'package:sirapat_app/data/models/api_response_model.dart';
import 'package:sirapat_app/domain/repositories/meeting_repository.dart';
import 'package:sirapat_app/data/providers/network/requests/meet/meet_get_request.dart';

class MeetingRepositoryImpl implements MeetingRepository {
  @override
  Future<List<Meeting>> getAll() async {
    try {
      // Make API call
      final request = MeetGetRequest();
      final response = await request.request();

      // Debug: print response
      print('Get Meetings API Response: $response');

      // Parse response
      final apiResponse = ApiResponse.fromJson(
        response as Map<String, dynamic>,
        (data) {
          // Check if data is a Map with 'data' key (nested structure)
          if (data is Map<String, dynamic> && data.containsKey('data')) {
            final innerData = data['data'];
            if (innerData is List) {
              final Meetings = innerData.map((item) {
                return MeetingModel.fromJson(item as Map<String, dynamic>);
              }).toList();
              return Meetings;
            }
          }
          // Handle if data is directly a list
          if (data is List) {
            print('Data is directly a List with ${data.length} items');
            return data
                .map(
                  (item) => MeetingModel.fromJson(item as Map<String, dynamic>),
                )
                .toList();
          }
          // Return empty list if structure doesn't match
          print('Data structure does not match expected format');
          return [];
        },
      );

      print('API Response status: ${apiResponse.status}');
      print('API Response data: ${apiResponse.data}');
      print('API Response data type: ${apiResponse.data.runtimeType}');

      // Check if request failed (status = false)
      if (!apiResponse.status) {
        print('Get Meetings failed, throwing ApiException');
        throw ApiException.fromJson(response);
      }

      // Return list of Meetings
      if (apiResponse.data is List) {
        final MeetingList = (apiResponse.data as List).cast<Meeting>();
        print('Returning ${MeetingList.length} Meetings');
        return MeetingList;
      }

      print('API Response data is not a List, returning empty list');
      return [];
    } on ApiException catch (e) {
      print('ApiException caught: ${e.message}');
      rethrow;
    } catch (e) {
      print('Generic exception: $e');
      throw ApiException(
        status: false,
        message: 'Failed to fetch Meetings: ${e.toString()}',
      );
    }
  }
}
