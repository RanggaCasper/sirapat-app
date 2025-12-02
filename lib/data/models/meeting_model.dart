import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:sirapat_app/domain/entities/meeting.dart';

MeetingModel meetingModelFromJson(String str) =>
    MeetingModel.fromJson(json.decode(str));

class MeetingModel extends Meeting {
  MeetingModel({
    required super.id,
    super.uuid,
    super.passcode,
    super.qr,
    required super.title,
    super.description,
    required super.date,
    required super.startTime,
    required super.endTime,
    super.location,
    super.agenda,
    required super.status,
    super.createdBy,
    super.createdAt,
    super.updatedAt,
  });

  factory MeetingModel.fromJson(Map<String, dynamic> json) {
    try {
      // Safely parse id, handling both int and string types
      int id = 0;
      final idValue = json["id"];
      if (idValue != null) {
        if (idValue is int) {
          id = idValue;
        } else if (idValue is String) {
          id = int.tryParse(idValue) ?? 0;
        }
      }

      // Safely parse createdBy, handling both int and string types
      int? createdBy;
      final createdByValue = json["created_by"];
      if (createdByValue != null) {
        if (createdByValue is int) {
          createdBy = createdByValue;
        } else if (createdByValue is String) {
          createdBy = int.tryParse(createdByValue);
        }
      }

      return MeetingModel(
        id: id,
        uuid: json["uuid"],
        passcode: json["passcode"],
        qr: json["qr"],
        title: json["title"] ?? 'Untitled Meeting',
        description: json["description"],
        date: json["date"] ?? DateTime.now().toString().split(' ')[0],
        startTime: json["start_time"] ?? '00:00',
        endTime: json["end_time"] ?? '01:00',
        location: json["location"],
        agenda: json["agenda"],
        status: json["status"] ?? 'scheduled',
        createdBy: createdBy,
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
      );
    } catch (e) {
      debugPrint('[MeetingModel.fromJson] Error parsing meeting: $e');
      debugPrint('[MeetingModel.fromJson] JSON data: $json');
      rethrow;
    }
  }

  @override
  String toString() {
    return 'MeetingModel(id: $id, title: $title, description: $description)';
  }
}
