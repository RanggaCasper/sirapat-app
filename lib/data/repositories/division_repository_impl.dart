import 'package:flutter/foundation.dart';
import 'package:sirapat_app/domain/entities/division.dart';
import 'package:sirapat_app/domain/repositories/division_repository.dart';
import 'package:sirapat_app/data/providers/network/requests/division/division_get_request.dart';
import 'package:sirapat_app/data/providers/network/requests/division/division_get_by_id_request.dart';
import 'package:sirapat_app/data/providers/network/requests/division/division_create_request.dart';
import 'package:sirapat_app/data/providers/network/requests/division/division_update_request.dart';
import 'package:sirapat_app/data/providers/network/requests/division/division_delete_request.dart';
import 'package:sirapat_app/data/models/api_response_model.dart';
import 'package:sirapat_app/data/models/division_model.dart';
import 'package:sirapat_app/data/models/api_exception.dart';

class DivisionRepositoryImpl extends DivisionRepository {
  @override
  Future<List<Division>> getAll() async {
    try {
      // Make API call
      final request = DivisionGetRequest();
      final response = await request.request();

      // Debug: print response
      debugPrint('Get Divisions API Response: $response');

      // Parse response
      final apiResponse = ApiResponse.fromJson(
        response as Map<String, dynamic>,
        (data) {
          // Check if data is a Map with 'data' key (nested structure)
          if (data is Map<String, dynamic> && data.containsKey('data')) {
            final innerData = data['data'];
            if (innerData is List) {
              final divisions = innerData.map((item) {
                return DivisionModel.fromJson(item as Map<String, dynamic>);
              }).toList();
              return divisions;
            }
          }
          // Handle if data is directly a list
          if (data is List) {
            debugPrint('Data is directly a List with ${data.length} items');
            return data
                .map(
                  (item) =>
                      DivisionModel.fromJson(item as Map<String, dynamic>),
                )
                .toList();
          }
          // Return empty list if structure doesn't match
          debugPrint('Data structure does not match expected format');
          return [];
        },
      );

      debugPrint('API Response status: ${apiResponse.status}');
      debugPrint('API Response data: ${apiResponse.data}');
      debugPrint('API Response data type: ${apiResponse.data.runtimeType}');

      // Check if request failed (status = false)
      if (!apiResponse.status) {
        debugPrint('Get divisions failed, throwing ApiException');
        throw ApiException.fromJson(response);
      }

      // Return list of divisions
      if (apiResponse.data is List) {
        final divisionList = (apiResponse.data as List).cast<Division>();
        debugPrint('Returning ${divisionList.length} divisions');
        return divisionList;
      }

      debugPrint('API Response data is not a List, returning empty list');
      return [];
    } on ApiException catch (e) {
      debugPrint('ApiException caught: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Generic exception: $e');
      throw ApiException(
        status: false,
        message: 'Failed to fetch divisions: ${e.toString()}',
      );
    }
  }

  @override
  Future<Division> getById(int id) async {
    try {
      // Make API call
      final request = DivisionGetByIdRequest(id);
      final response = await request.request();

      // Debug: print response
      debugPrint('Get Division API Response: $response');

      // Parse response
      final apiResponse = ApiResponse.fromJson(
        response as Map<String, dynamic>,
        (data) => DivisionModel.fromJson(data as Map<String, dynamic>),
      );

      // Check if request failed (status = false)
      if (!apiResponse.status || apiResponse.data == null) {
        debugPrint('Get division failed, throwing ApiException');
        throw ApiException.fromJson(response);
      }

      return apiResponse.data as Division;
    } on ApiException catch (e) {
      debugPrint('Get Division ApiException caught');
      debugPrint('Message: ${e.message}');
      debugPrint('Errors: ${e.errors}');
      rethrow;
    } catch (e) {
      debugPrint('Generic exception: $e');
      throw ApiException(
        status: false,
        message: 'Failed to fetch division: ${e.toString()}',
      );
    }
  }

  @override
  Future<Division> create(String name, String? description) async {
    try {
      // Make API call
      final request = DivisionCreateRequest(
        name: name,
        description: description,
      );
      final response = await request.request();

      debugPrint('Create Division API Response: $response');

      // Check if response has errors field (validation error)
      if (response is Map<String, dynamic> && response.containsKey('errors')) {
        debugPrint('Create division validation errors detected');
        throw ApiException.fromJson(response);
      }

      // Parse response
      final apiResponse = ApiResponse.fromJson(
        response as Map<String, dynamic>,
        (data) => DivisionModel.fromJson(data as Map<String, dynamic>),
      );

      // Check if creation failed
      if (!apiResponse.status || apiResponse.data == null) {
        debugPrint('Create division failed, throwing ApiException');
        throw ApiException.fromJson(response);
      }

      return apiResponse.data as Division;
    } on ApiException catch (e) {
      debugPrint('Create Division ApiException caught');
      debugPrint('Message: ${e.message}');
      debugPrint('Errors: ${e.errors}');
      rethrow;
    } catch (e) {
      debugPrint('Generic exception: $e');
      throw ApiException(
        status: false,
        message: 'Failed to create division: ${e.toString()}',
      );
    }
  }

  @override
  Future<Division> update(int id, String name, String? description) async {
    try {
      // Make API call
      final request = DivisionUpdateRequest(
        id: id,
        name: name,
        description: description,
      );
      final response = await request.request();

      debugPrint('Update Division API Response: $response');

      // Check if response has errors field (validation error)
      if (response is Map<String, dynamic> && response.containsKey('errors')) {
        debugPrint('Update division validation errors detected');
        throw ApiException.fromJson(response);
      }

      // Parse response
      final apiResponse = ApiResponse.fromJson(
        response as Map<String, dynamic>,
        (data) => DivisionModel.fromJson(data as Map<String, dynamic>),
      );

      // Check if update failed
      if (!apiResponse.status || apiResponse.data == null) {
        debugPrint('Update division failed, throwing ApiException');
        throw ApiException.fromJson(response);
      }

      return apiResponse.data as Division;
    } on ApiException catch (e) {
      debugPrint('Update Division ApiException caught');
      debugPrint('Message: ${e.message}');
      debugPrint('Errors: ${e.errors}');
      rethrow;
    } catch (e) {
      debugPrint('Generic exception: $e');
      throw ApiException(
        status: false,
        message: 'Failed to update division: ${e.toString()}',
      );
    }
  }

  @override
  Future<bool> delete(int id) async {
    try {
      // Make API call
      final request = DivisionDeleteRequest(id);
      final response = await request.request();

      debugPrint('Delete Division API Response: $response');

      // Parse response
      final apiResponse = ApiResponse.fromJson(
        response as Map<String, dynamic>,
        (data) => data, // No specific data needed for delete
      );

      // Check if deletion failed
      if (!apiResponse.status) {
        debugPrint('Delete division failed, throwing ApiException');
        throw ApiException.fromJson(response);
      }

      return true;
    } on ApiException catch (e) {
      debugPrint('Delete Division ApiException caught');
      debugPrint('Message: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('Generic exception: $e');
      throw ApiException(
        status: false,
        message: 'Failed to delete division: ${e.toString()}',
      );
    }
  }
}
