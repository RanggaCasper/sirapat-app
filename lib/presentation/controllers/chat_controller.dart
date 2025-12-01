import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:sirapat_app/app/config/app_constants.dart';
import 'package:sirapat_app/app/services/chat_service.dart';
import 'package:sirapat_app/data/models/chat_message_model.dart';
import 'package:sirapat_app/domain/usecases/chat/get_chat_minutes_usecase.dart';
import 'package:sirapat_app/domain/usecases/chat/save_chat_minute_usecase.dart';
import 'package:sirapat_app/presentation/controllers/auth_controller.dart';

class ChatController extends GetxController {
  final ChatService _chatService = ChatService();
  final GetChatMinutesUseCase _getChatMinutesUseCase;
  final SaveChatMinuteUseCase _saveChatMinuteUseCase = SaveChatMinuteUseCase();

  ChatController({required GetChatMinutesUseCase getChatMinutesUseCase})
    : _getChatMinutesUseCase = getChatMinutesUseCase;

  // Observable untuk menyimpan pesan
  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final RxBool isLoadingHistory = false.obs;
  final RxBool isLoading = false.obs;
  final RxBool isConnected = false.obs;
  final RxString errorMessage = ''.obs;

  // For WebSocket stream subscription
  StreamSubscription<dynamic>? _subscription;

  // Reverb configuration
  final String reverbAppKey = 'zagzqeklkihbbgwhwh8j'; // Ganti dengan key Anda
  final String reverbHost = AppConstants.host;
  final int reverbPort = AppConstants.reverbPort;
  final String reverbScheme = AppConstants.reverbScheme;

  @override
  void onInit() {
    super.onInit();
    debugPrint('[ChatController] Initialized');
  }

  @override
  void onClose() {
    _disconnectChat();
    super.onClose();
  }

  /// Initialize dan connect ke WebSocket
  Future<void> initializeChat({required int meetingId}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      messages.clear();

      final authController = Get.find<AuthController>();
      final currentUser = authController.currentUser;

      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      debugPrint('[ChatController] Connecting to chat for meeting: $meetingId');

      // Load chat history from API first
      await _loadChatHistory(meetingId);

      // Connect ke WebSocket
      await _chatService.connect(
        meetingId: meetingId.toString(),
        userId: currentUser.id.toString(),
        userName: currentUser.fullName ?? 'Unknown',
        reverbAppKey: reverbAppKey,
      );

      isConnected.value = true;
      debugPrint('[ChatController] Chat connected successfully');

      // Listen ke incoming messages
      _listenToMessages(meetingId);
    } catch (e) {
      debugPrint('[ChatController] Connection error: $e');
      errorMessage.value = 'Gagal terhubung ke chat: $e';
      isConnected.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Load chat history dari API
  Future<void> _loadChatHistory(int meetingId) async {
    try {
      isLoadingHistory.value = true;
      debugPrint(
        '[ChatController] Loading chat history for meeting: $meetingId',
      );

      final chatMinutes = await _getChatMinutesUseCase(meetingId: meetingId);

      final authController = Get.find<AuthController>();
      final currentUserId = authController.currentUser?.id;

      // Convert ChatMinuteModel to ChatMessage
      for (final minute in chatMinutes) {
        final chatMessage = ChatMessage(
          id: minute.id.toString(),
          meetingId: minute.meetingId,
          userId: minute.sentBy,
          senderName: minute.sender.fullName ?? 'Unknown',
          message: minute.message,
          timestamp: DateTime.parse(minute.createdAt),
          isMe: currentUserId?.toString() == minute.sentBy.toString(),
        );
        messages.add(chatMessage);
      }

      debugPrint(
        '[ChatController] Loaded ${messages.length} messages from history',
      );
    } catch (e) {
      debugPrint('[ChatController] Error loading chat history: $e');
      // Don't set error - chat can still work with WebSocket
    } finally {
      isLoadingHistory.value = false;
    }
  }

  /// Listen ke incoming messages dari WebSocket
  void _listenToMessages(int meetingId) {
    try {
      if (_chatService.messageStream == null) {
        debugPrint('[ChatController] Message stream is null');
        return;
      }

      _subscription = _chatService.messageStream!.listen(
        (data) {
          debugPrint('[ChatController] Received data: $data');

          // Parse pesan yang diterima
          if (data is String) {
            // Jika string, parse as JSON
            try {
              final jsonData = _parseJson(data);
              _handleIncomingMessage(jsonData);
            } catch (e) {
              debugPrint('[ChatController] Error parsing JSON: $e');
            }
          } else if (data is Map) {
            _handleIncomingMessage(data as Map<String, dynamic>);
          }
        },
        onError: (error) {
          debugPrint('[ChatController] WebSocket error: $error');
          errorMessage.value = 'Chat connection error: $error';
          isConnected.value = false;
        },
        onDone: () {
          debugPrint('[ChatController] WebSocket closed');
          isConnected.value = false;
        },
      );

      debugPrint('[ChatController] Started listening to messages');
    } catch (e) {
      debugPrint('[ChatController] Listen error: $e');
    }
  }

  /// Handle incoming message dari broadcast
  void _handleIncomingMessage(Map<String, dynamic> data) {
    try {
      debugPrint('[ChatController] _handleIncomingMessage raw data: $data');

      // Check if this is a Reverb system message (connection_established, etc)
      final event = data['event'];
      if (event == 'pusher:connection_established' ||
          event == 'pusher:pong' ||
          event == null) {
        debugPrint(
          '[ChatController] System message received, ignoring: $event',
        );
        return;
      }

      // Extract message data from broadcast
      var messageData = data['data'];

      // If data is a JSON string, parse it
      if (messageData is String) {
        try {
          messageData = _parseJson(messageData);
        } catch (e) {
          debugPrint('[ChatController] Failed to parse message data: $e');
          return;
        }
      }

      if (messageData is! Map<String, dynamic>) {
        messageData = (messageData as Map).cast<String, dynamic>();
      }

      debugPrint('[ChatController] Parsed message data: $messageData');

      // Check if message contains required fields
      if (!messageData.containsKey('message')) {
        debugPrint('[ChatController] Message data missing "message" field');
        return;
      }

      final authController = Get.find<AuthController>();
      final currentUserId = authController.currentUser?.id;

      // Extract sender ID - bisa dari 'user_id', 'sent_by' (int), atau 'sent_by' (object)
      int? senderUserId;
      if (messageData.containsKey('user_id')) {
        senderUserId = messageData['user_id'] as int?;
      } else if (messageData.containsKey('sent_by')) {
        final sentBy = messageData['sent_by'];
        if (sentBy is int) {
          senderUserId = sentBy;
        } else if (sentBy is Map<String, dynamic>) {
          senderUserId = sentBy['id'] as int?;
        }
      }

      debugPrint(
        '[ChatController] Current user ID: $currentUserId, Sender ID: $senderUserId',
      );

      // Check if message is from current user
      final isMe = currentUserId?.toString() == senderUserId?.toString();

      // SKIP if message is from current user (sudah ditampilkan dari local)
      if (isMe) {
        debugPrint(
          '[ChatController] Skipping own message (already displayed locally)',
        );
        return;
      }

      final chatMessage = ChatMessage.fromJson(messageData, isMe: isMe);

      // Add message ke list
      messages.add(chatMessage);
      debugPrint(
        '[ChatController] Message added: ${chatMessage.senderName} - ${chatMessage.message}',
      );
    } catch (e) {
      debugPrint('[ChatController] Error handling message: $e');
      errorMessage.value = 'Error processing message: $e';
    }
  }

  /// Send message
  Future<void> sendMessage(String message, int meetingId) async {
    try {
      if (message.trim().isEmpty) {
        return;
      }

      if (!isConnected.value) {
        errorMessage.value = 'Tidak terhubung ke chat';
        return;
      }

      final authController = Get.find<AuthController>();
      final currentUser = authController.currentUser;

      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      debugPrint('[ChatController] Sending message: $message');

      // Add local message immediately for better UX
      final localMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        meetingId: meetingId,
        userId: currentUser.id ?? 0,
        senderName: currentUser.fullName ?? 'Me',
        message: message,
        timestamp: DateTime.now(),
        isMe: true,
      );

      messages.add(localMessage);

      // Send via WebSocket (real-time)
      _chatService.sendMessage(
        meetingId: meetingId.toString(),
        userId: currentUser.id.toString(),
        userName: currentUser.fullName ?? 'Unknown',
        message: message,
      );

      debugPrint('[ChatController] Message sent via WebSocket');

      // Save to backend API (persistence) - don't block on error
      try {
        await _saveChatMinuteUseCase.call(
          meetingId: meetingId,
          message: message,
          userId: currentUser.id ?? 0,
          userName: currentUser.fullName ?? 'Unknown',
        );
        debugPrint('[ChatController] Message saved to API');
      } catch (apiError) {
        debugPrint('[ChatController] API save error (non-blocking): $apiError');
        // Don't set errorMessage here - message is already sent via WebSocket
        // This is just for persistence
      }
    } catch (e) {
      debugPrint('[ChatController] Send error: $e');
      errorMessage.value = 'Gagal mengirim pesan: $e';
    }
  }

  /// Disconnect dari chat
  Future<void> disconnect() async {
    try {
      await _subscription?.cancel();
      await _chatService.disconnect();
      isConnected.value = false;
      messages.clear();
      debugPrint('[ChatController] Chat disconnected');
    } catch (e) {
      debugPrint('[ChatController] Disconnect error: $e');
    }
  }

  /// Internal disconnect method
  Future<void> _disconnectChat() async {
    await disconnect();
  }

  /// Parse JSON string
  Map<String, dynamic> _parseJson(String jsonString) {
    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      } else if (decoded is Map) {
        return decoded.cast<String, dynamic>();
      }
      return {};
    } catch (e) {
      debugPrint('[ChatController] JSON parse error: $e');
      return {};
    }
  }
}
