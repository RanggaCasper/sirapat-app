class Meeting {
  final int id;
  final String title;
  final String? description;
  final String date;
  final String startTime;
  final String endTime;
  final String? location;
  final String? agenda;
  final String status;

  Meeting({
    required this.id,
    required this.title,
    this.description,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.location,
    this.agenda,
    required this.status,
  });

  factory Meeting.fromJson(Map<String, dynamic> json) {
    return Meeting(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      date: json['date'],
      startTime: json['start_time'],
      endTime: json['end_time'],
      location: json['location'],
      agenda: json['agenda'],
      status: json['status'],
    );
  }
}
