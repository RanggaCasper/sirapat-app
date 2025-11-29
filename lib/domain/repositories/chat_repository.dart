import 'package:sirapat_app/data/models/chat_minute_model.dart';

abstract class ChatRepository {
  /// Get chat messages by meeting ID
  Future<List<ChatMinuteModel>> getChatMinutes(int meetingId);

  /// Save chat minute message
  Future<void> saveChatMinute({
    required int meetingId,
    required String message,
    required int userId,
    required String userName,
  });
}
