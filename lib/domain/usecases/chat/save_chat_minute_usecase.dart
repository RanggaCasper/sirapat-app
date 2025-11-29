import 'package:sirapat_app/data/providers/network/requests/chat/save_chat_minute_request.dart';

class SaveChatMinuteUseCase {
  Future<void> call({
    required int meetingId,
    required String message,
    required int userId,
    required String userName,
  }) async {
    final request = SaveChatMinuteRequest(
      meetingId: meetingId,
      message: message,
      userId: userId,
      userName: userName,
    );

    try {
      await request.request();
    } catch (e) {
      rethrow;
    }
  }
}
