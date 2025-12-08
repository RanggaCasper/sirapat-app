class MeetingMinute {
  final int id;
  final int meetingId;
  final String content;
  final List<Decision>? decisions;
  final int? approvedBy;
  final DateTime? approvedAt;

  MeetingMinute({
    required this.id,
    required this.meetingId,
    required this.content,
    this.decisions,
    this.approvedBy,
    this.approvedAt,
  });
}

class Decision {
  final String title;
  final String description;

  Decision({required this.title, required this.description});
}
