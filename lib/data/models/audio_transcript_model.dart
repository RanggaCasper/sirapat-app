import 'package:flutter/foundation.dart';

class AudioTranscriptModel {
  final String text;
  final AudioInfo audioInfo;
  final double processingTime;

  AudioTranscriptModel({
    required this.text,
    required this.audioInfo,
    required this.processingTime,
  });

  factory AudioTranscriptModel.fromJson(Map<String, dynamic> json) {
    try {
      return AudioTranscriptModel(
        text: json['text']?.toString() ?? '',
        audioInfo: json['audio_info'] != null
            ? AudioInfo.fromJson(json['audio_info'] as Map<String, dynamic>)
            : AudioInfo.empty(),
        processingTime: json['processing_time'] != null
            ? (json['processing_time'] is int
                  ? (json['processing_time'] as int).toDouble()
                  : json['processing_time'] as double)
            : 0.0,
      );
    } catch (e) {
      debugPrint('Error parsing AudioTranscriptModel: $e');
      debugPrint('JSON data: $json');
      rethrow;
    }
  }
}

class AudioInfo {
  final String filename;
  final double duration;
  final int sampleRate;
  final int fileSize;
  final String format;

  AudioInfo({
    required this.filename,
    required this.duration,
    required this.sampleRate,
    required this.fileSize,
    required this.format,
  });

  factory AudioInfo.fromJson(Map<String, dynamic> json) {
    return AudioInfo(
      filename: json['filename']?.toString() ?? '',
      duration: json['duration'] != null
          ? (json['duration'] is int
                ? (json['duration'] as int).toDouble()
                : json['duration'] as double)
          : 0.0,
      sampleRate: json['sample_rate'] is int ? json['sample_rate'] : 0,
      fileSize: json['file_size'] is int ? json['file_size'] : 0,
      format: json['format']?.toString() ?? '',
    );
  }

  factory AudioInfo.empty() {
    return AudioInfo(
      filename: '',
      duration: 0.0,
      sampleRate: 0,
      fileSize: 0,
      format: '',
    );
  }
}
