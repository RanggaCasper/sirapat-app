import 'package:sirapat_app/data/models/chat_minute_model.dart';
import 'package:sirapat_app/data/providers/network/requests/chat/get_chat_minutes_request.dart';
import 'package:sirapat_app/data/providers/network/requests/chat/save_chat_minute_request.dart';
import 'package:sirapat_app/domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  @override
  Future<List<ChatMinuteModel>> getChatMinutes(int meetingId) async {
    try {
      final request = GetChatMinutesRequest(meetingId: meetingId);
      final response = await request.request();

      // Parse response
      if (response is Map<String, dynamic>) {
        final data = response['data'] as List?;
        if (data != null) {
          final messages = (data)
              .map(
                (item) =>
                    ChatMinuteModel.fromJson(item as Map<String, dynamic>),
              )
              .toList();
          return messages;
        }
      }

      return [];
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> saveChatMinute({
    required int meetingId,
    required String message,
    required int userId,
    required String userName,
  }) async {
    try {
      final request = SaveChatMinuteRequest(
        meetingId: meetingId,
        message: message,
        userId: userId,
        userName: userName,
      );
      await request.request();
    } catch (e) {
      rethrow;
    }
  }
}
