import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:sirapat_app/data/models/audio_transcript_model.dart';
import 'package:sirapat_app/data/providers/network/audio_provider.dart';
import 'package:sirapat_app/domain/entities/meeting_minute.dart';
import 'package:sirapat_app/data/models/meeting_minute_model.dart';

class AudioRepository {
  final AudioProvider _audioProvider = Get.find<AudioProvider>();

  Future<AudioTranscriptModel> uploadAndTranscribeAudio(File audioFile) async {
    try {
      debugPrint('AudioRepository: Uploading audio file: ${audioFile.path}');
      final responseData = await _audioProvider.uploadAudio(audioFile);

      debugPrint('AudioRepository: Response status: ${responseData['status']}');
      debugPrint(
        'AudioRepository: Response data keys: ${responseData['data']?.keys}',
      );

      if (responseData['status'] == true) {
        try {
          return AudioTranscriptModel.fromJson(responseData['data']);
        } catch (e) {
          debugPrint('AudioRepository: Error parsing transcript model: $e');
          debugPrint('AudioRepository: Response data: ${responseData['data']}');
          rethrow;
        }
      } else {
        throw Exception(
          responseData['message'] ?? 'Failed to transcribe audio',
        );
      }
    } catch (e) {
      debugPrint('AudioRepository: Upload error: $e');
      throw Exception('Error uploading audio: $e');
    }
  }

  Future<MeetingMinute> createMeetingMinutes({
    required String text,
    required int meetingId,
    String style = 'detailed',
    bool includeElements = true,
  }) async {
    try {
      final responseData = await _audioProvider.createMeetingMinutes(
        text: text,
        meetingId: meetingId,
        style: style,
        includeElements: includeElements,
      );

      if (responseData['status'] == true) {
        return MeetingMinuteModel.fromJson(responseData['data']);
      } else {
        throw Exception(
          responseData['message'] ?? 'Failed to create meeting minutes',
        );
      }
    } catch (e) {
      throw Exception('Error creating meeting minutes: $e');
    }
  }
}
