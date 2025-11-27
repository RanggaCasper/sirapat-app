import 'dart:convert';
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

  factory MeetingModel.fromJson(Map<String, dynamic> json) => MeetingModel(
    id: json["id"] ?? 0,
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
    createdBy: json["created_by"],
    createdAt: json["created_at"],
    updatedAt: json["updated_at"],
  );

  String toString() {
    return 'MeetingModel(id: $id, title: $title, description: $description)';
  }
}
