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
      print('Get Divisions API Response: $response');

      // Parse response
      final apiResponse = ApiResponse.fromJson(
        response as Map<String, dynamic>,
        (data) {
          // Handle if data is a list
          if (data is List) {
            return data
                .map(
                  (item) =>
                      DivisionModel.fromJson(item as Map<String, dynamic>),
                )
                .toList();
          }
          // Handle if data is wrapped in another object
          return [];
        },
      );

      // Check if request failed (status = false)
      if (!apiResponse.status) {
        print('Get divisions failed, throwing ApiException');
        throw ApiException.fromJson(response);
      }

      // Return list of divisions
      if (apiResponse.data is List<DivisionModel>) {
        return apiResponse.data as List<Division>;
      }

      return [];
    } on ApiException catch (e) {
      print('ApiException caught: ${e.message}');
      rethrow;
    } catch (e) {
      print('Generic exception: $e');
      throw ApiException(
        status: false,
        message: 'Failed to fetch divisions: ${e.toString()}',
      );
    }
  }

  @override
  Future<Division> getById(int id) async{
    try {
      // Make API call
      final request = DivisionGetByIdRequest(id);
      final response = await request.request();

      // Debug: print response
      print('Get Division API Response: $response');      

      // Parse response
      final apiResponse = ApiResponse.fromJson(
        response as Map<String, dynamic>,
        (data) => DivisionModel.fromJson(data as Map<String, dynamic>),
      );      

      // Check if request failed (status = false)
      if (!apiResponse.status || apiResponse.data == null) {
        print('Get division failed, throwing ApiException');
        throw ApiException.fromJson(response);
      }

      return apiResponse.data as Division;
    } on ApiException catch (e) {
      print('Get Division ApiException caught');
      print('Message: ${e.message}');
      print('Errors: ${e.errors}');
      rethrow;
    } catch (e) {
      print('Generic exception: $e');
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

      print('Create Division API Response: $response');

      // Check if response has errors field (validation error)
      if (response is Map<String, dynamic> && response.containsKey('errors')) {
        print('Create division validation errors detected');
        throw ApiException.fromJson(response);
      }

      // Parse response
      final apiResponse = ApiResponse.fromJson(
        response as Map<String, dynamic>,
        (data) => DivisionModel.fromJson(data as Map<String, dynamic>),
      );

      // Check if creation failed
      if (!apiResponse.status || apiResponse.data == null) {
        print('Create division failed, throwing ApiException');
        throw ApiException.fromJson(response);
      }

      return apiResponse.data as Division;
    } on ApiException catch (e) {
      print('Create Division ApiException caught');
      print('Message: ${e.message}');
      print('Errors: ${e.errors}');
      rethrow;
    } catch (e) {
      print('Generic exception: $e');
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

      print('Update Division API Response: $response');

      // Check if response has errors field (validation error)
      if (response is Map<String, dynamic> && response.containsKey('errors')) {
        print('Update division validation errors detected');
        throw ApiException.fromJson(response);
      }

      // Parse response
      final apiResponse = ApiResponse.fromJson(
        response as Map<String, dynamic>,
        (data) => DivisionModel.fromJson(data as Map<String, dynamic>),
      );

      // Check if update failed
      if (!apiResponse.status || apiResponse.data == null) {
        print('Update division failed, throwing ApiException');
        throw ApiException.fromJson(response);
      }

      return apiResponse.data as Division;
    } on ApiException catch (e) {
      print('Update Division ApiException caught');
      print('Message: ${e.message}');
      print('Errors: ${e.errors}');
      rethrow;
    } catch (e) {
      print('Generic exception: $e');
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

      print('Delete Division API Response: $response');

      // Parse response
      final apiResponse = ApiResponse.fromJson(
        response as Map<String, dynamic>,
        (data) => data, // No specific data needed for delete
      );

      // Check if deletion failed
      if (!apiResponse.status) {
        print('Delete division failed, throwing ApiException');
        throw ApiException.fromJson(response);
      }

      return true;
    } on ApiException catch (e) {
      print('Delete Division ApiException caught');
      print('Message: ${e.message}');
      rethrow;
    } catch (e) {
      print('Generic exception: $e');
      throw ApiException(
        status: false,
        message: 'Failed to delete division: ${e.toString()}',
      );
    }
  }
}
