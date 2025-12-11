import 'dart:io';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:sirapat_app/app/services/local_storage.dart';
import 'package:sirapat_app/data/providers/network/api_endpoint.dart';
import 'package:sirapat_app/data/providers/network/api_provider.dart';

class AudioProvider {
  final APIProvider _apiProvider = Get.find<APIProvider>();
  final LocalStorageService _storage = Get.find<LocalStorageService>();

  Future<Map<String, dynamic>> uploadAudio(File audioFile) async {
    try {
      final fileName = audioFile.path.split('/').last;
      final token = _storage.getData<String>(StorageKey.token);

      debugPrint('AudioProvider: Uploading file: $fileName');
      debugPrint('AudioProvider: File path: ${audioFile.path}');
      debugPrint('AudioProvider: File exists: ${await audioFile.exists()}');
      debugPrint('AudioProvider: Token exists: ${token != null}');

      // Create Dio MultipartFile from file
      final multipartFile = await dio.MultipartFile.fromFile(
        audioFile.path,
        filename: fileName,
      );

      final formData = dio.FormData.fromMap({'file': multipartFile});

      debugPrint('AudioProvider: FormData created for file: $fileName');

      final headers = <String, String>{
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final responseData = await _apiProvider.post(
        APIEndpoint.audioUpload,
        formData,
        headers: headers,
      );

      debugPrint('AudioProvider: Upload response data: $responseData');

      return responseData as Map<String, dynamic>;
    } catch (e) {
      debugPrint('AudioProvider: Upload error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createMeetingMinutes({
    required String text,
    required int meetingId,
    String style = 'detailed',
    bool includeElements = true,
  }) async {
    try {
      final token = _storage.getData<String>(StorageKey.token);

      debugPrint(
        'AudioProvider: Creating meeting minutes for meeting $meetingId',
      );
      debugPrint('AudioProvider: Token exists: ${token != null}');

      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final responseData = await _apiProvider
          .post(APIEndpoint.summarizeMinutes, {
            'text': text,
            'meeting_id': meetingId,
            'style': style,
            'include_elements': includeElements,
          }, headers: headers);

      debugPrint(
        'AudioProvider: Create meeting minutes response data: $responseData',
      );

      return responseData as Map<String, dynamic>;
    } catch (e) {
      debugPrint('AudioProvider: Create meeting minutes error: $e');
      rethrow;
    }
  }
}
