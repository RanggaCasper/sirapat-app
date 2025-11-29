import 'package:sirapat_app/data/models/chat_minute_model.dart';
import 'package:sirapat_app/domain/repositories/chat_repository.dart';

class GetChatMinutesUseCase {
  final ChatRepository _repository;

  GetChatMinutesUseCase(this._repository);

  Future<List<ChatMinuteModel>> call({required int meetingId}) async {
    return await _repository.getChatMinutes(meetingId);
  }
}
