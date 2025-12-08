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
    // Safely parse id, handling both int and string types
    int id = 0;
    final idValue = json['id'];
    if (idValue != null) {
      if (idValue is int) {
        id = idValue;
      } else if (idValue is String) {
        id = int.tryParse(idValue) ?? 0;
      }
    }

    // Safely parse createdBy, handling both int and string types
    int? createdBy;
    final createdByValue = json['created_by'];
    if (createdByValue != null) {
      if (createdByValue is int) {
        createdBy = createdByValue;
      } else if (createdByValue is String) {
        createdBy = int.tryParse(createdByValue);
      }
    }

    return Meeting(
      id: id,
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
      createdBy: createdBy,
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}
