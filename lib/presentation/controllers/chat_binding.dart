import 'package:get/get.dart';
import 'package:sirapat_app/data/repositories/chat_repository_impl.dart';
import 'package:sirapat_app/domain/repositories/chat_repository.dart';
import 'package:sirapat_app/domain/usecases/chat/get_chat_minutes_usecase.dart';
import 'package:sirapat_app/domain/usecases/chat/save_chat_minute_usecase.dart';
import 'package:sirapat_app/presentation/controllers/chat_controller.dart';

class ChatBinding extends Bindings {
  @override
  void dependencies() {
    // Repository
    Get.lazyPut<ChatRepository>(() => ChatRepositoryImpl());

    // UseCases
    Get.lazyPut<GetChatMinutesUseCase>(
      () => GetChatMinutesUseCase(Get.find<ChatRepository>()),
    );
    Get.lazyPut<SaveChatMinuteUseCase>(() => SaveChatMinuteUseCase());

    // Controller
    Get.lazyPut<ChatController>(
      () => ChatController(
        getChatMinutesUseCase: Get.find<GetChatMinutesUseCase>(),
      ),
    );
  }
}
