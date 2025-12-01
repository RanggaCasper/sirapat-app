import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ChatService {
  static final ChatService _instance = ChatService._internal();

  factory ChatService() {
    return _instance;
  }

  ChatService._internal();

  WebSocketChannel? _channel;
  bool _isConnected = false;
  final String _reverbHost = '192.168.1.100';
  final int _reverbPort = 8080;
  final String _reverbScheme = 'http';

  // Stream untuk menerima pesan
  Stream<dynamic>? get messageStream => _channel?.stream;
  bool get isConnected => _isConnected;

  /// Connect ke Reverb WebSocket
  Future<void> connect({
    required String meetingId,
    required String userId,
    required String userName,
    required String reverbAppKey,
  }) async {
    try {
      // Construct WebSocket URL untuk Reverb
      // Format: ws://host:port/app/{appKey}?user_id={userId}
      final wsScheme = _reverbScheme == 'https' ? 'wss' : 'ws';
      final url = Uri.parse(
        '$wsScheme://$_reverbHost:$_reverbPort/app/$reverbAppKey'
        '?user_id=$userId'
        '&user_name=$userName'
        '&meeting_id=$meetingId',
      );

      debugPrint('[ChatService] Connecting to WebSocket: $url');

      _channel = WebSocketChannel.connect(url);

      // Tunggu sampai connection established
      await _channel!.ready;
      _isConnected = true;

      debugPrint('[ChatService] WebSocket connected successfully');

      // Subscribe ke channel
      _subscribeToChannel(meetingId);
    } catch (e) {
      debugPrint('[ChatService] Connection error: $e');
      _isConnected = false;
      rethrow;
    }
  }

  /// Subscribe ke meeting chat channel
  void _subscribeToChannel(String meetingId) {
    try {
      final subscribeMessage = {
        'event': 'pusher:subscribe',
        'data': {'channel': 'chat'},
      };

      debugPrint('[ChatService] Subscribing to channel: chat');
      _channel?.sink.add(jsonEncode(subscribeMessage));
    } catch (e) {
      debugPrint('[ChatService] Subscribe error: $e');
    }
  }

  /// Kirim pesan ke channel
  void sendMessage({
    required String meetingId,
    required String userId,
    required String userName,
    required String message,
  }) {
    try {
      if (!_isConnected || _channel == null) {
        debugPrint('[ChatService] Not connected to WebSocket');
        return;
      }

      // Format JSON sesuai backend Reverb
      // Include user_id dan user_name untuk broadcast receiver
      final eventData = {
        'event': '.MessageSent',
        'channel': 'chat',
        'data': {
          'message': message,
          'meeting_id': int.tryParse(meetingId) ?? 0,
          'user_id': int.tryParse(userId) ?? 0,
          'user_name': userName,
          'timestamp': DateTime.now().toIso8601String(),
        },
      };

      debugPrint('[ChatService] Sending message: $eventData');
      _channel?.sink.add(jsonEncode(eventData));
      debugPrint('[ChatService] Message sent successfully');
    } catch (e) {
      debugPrint('[ChatService] Send error: $e');
    }
  }

  /// Disconnect dari WebSocket
  Future<void> disconnect() async {
    try {
      _isConnected = false;
      await _channel?.sink.close();
      _channel = null;
      debugPrint('[ChatService] WebSocket disconnected');
    } catch (e) {
      debugPrint('[ChatService] Disconnect error: $e');
    }
  }

  /// Check connection status
  void healthCheck() {
    if (!_isConnected) {
      debugPrint('[ChatService] WebSocket is not connected');
    } else {
      debugPrint('[ChatService] WebSocket is connected');
    }
  }
}
