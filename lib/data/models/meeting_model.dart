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
    id: json["id"],
    uuid: json["uuid"],
    passcode: json["passcode"],
    qr: json["qr"],
    title: json["title"],
    description: json["description"],
    date: json["date"],
    startTime: json["start_time"],
    endTime: json["end_time"],
    location: json["location"],
    agenda: json["agenda"],
    status: json["status"],
    createdBy: json["created_by"],
    createdAt: json["created_at"],
    updatedAt: json["updated_at"],
  );

  String toString() {
    return 'MeetingModel(id: $id, title: $title, description: $description)';
  }
}
