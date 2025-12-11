class MeetingMinute {
  final int id;
  final int meetingId;
  final String content;
  final String? originalText;
  final String? summary;
  final String? minutes;
  final List<Decision>? decisions;
  final Map<String, dynamic>? elements;
  final int? approvedBy;
  final DateTime? approvedAt;

  MeetingMinute({
    required this.id,
    required this.meetingId,
    required this.content,
    this.originalText,
    this.summary,
    this.minutes,
    this.decisions,
    this.elements,
    this.approvedBy,
    this.approvedAt,
  });
}

class Decision {
  final String title;
  final String description;

  Decision({required this.title, required this.description});
}
