class Meeting {
  final int id;
  final String? uuid;
  final String? passcode;
  final String? qr;
  final String title;
  final String? description;
  final String date;
  final String startTime;
  final String endTime;
  final String? location;
  final String? agenda;
  final String status;
  final int? createdBy;
  final String? createdAt;
  final String? updatedAt;

  Meeting({
    required this.id,
    this.uuid,
    this.passcode,
    this.qr,
    required this.title,
    this.description,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.location,
    this.agenda,
    required this.status,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  factory Meeting.fromJson(Map<String, dynamic> json) {
    return Meeting(
      id: json['id'],
      uuid: json['uuid'],
      passcode: json['passcode'],
      qr: json['qr'],
      title: json['title'],
      description: json['description'],
      date: json['date'],
      startTime: json['start_time'],
      endTime: json['end_time'],
      location: json['location'],
      agenda: json['agenda'],
      status: json['status'],
      createdBy: json['created_by'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}
