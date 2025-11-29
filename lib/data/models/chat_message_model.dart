class ChatMessage {
  final String id;
  final int meetingId;
  final int userId;
  final String senderName;
  final String message;
  final DateTime timestamp;
  final bool isMe;

  ChatMessage({
    required this.id,
    required this.meetingId,
    required this.userId,
    required this.senderName,
    required this.message,
    required this.timestamp,
    required this.isMe,
  });

  // Factory untuk parse dari JSON
  factory ChatMessage.fromJson(Map<String, dynamic> json, {bool isMe = false}) {
    return ChatMessage(
      id:
          json['id']?.toString() ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      meetingId: json['meeting_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      senderName: json['sender_name'] ?? json['user_name'] ?? 'Unknown',
      message: json['message'] ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'].toString())
          : DateTime.now(),
      isMe: isMe,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'meeting_id': meetingId,
      'user_id': userId,
      'sender_name': senderName,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // Copy with method
  ChatMessage copyWith({
    String? id,
    int? meetingId,
    int? userId,
    String? senderName,
    String? message,
    DateTime? timestamp,
    bool? isMe,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      meetingId: meetingId ?? this.meetingId,
      userId: userId ?? this.userId,
      senderName: senderName ?? this.senderName,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      isMe: isMe ?? this.isMe,
    );
  }
}
