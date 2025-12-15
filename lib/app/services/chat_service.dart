import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:sirapat_app/app/config/app_constants.dart';

class ChatService {
  static final ChatService _instance = ChatService._internal();

  factory ChatService() {
    return _instance;
  }

  ChatService._internal();

  WebSocketChannel? _channel;
  bool _isConnected = false;
  StreamSubscription? _streamSubscription;
  Timer? _heartbeatTimer;
  bool _isReconnecting = false;
  int _reconnectAttempts = 0;
  final int _maxReconnectAttempts = 5;

  // Extract host dari baseUrl
  String get _reverbHost => Uri.parse(AppConstants.baseUrl).host;
  final int _reverbPort = AppConstants.reverbPort;
  String get _reverbScheme => Uri.parse(AppConstants.baseUrl).scheme;

  // Simpan parameter untuk reconnect
  String? _currentMeetingId;
  String? _currentUserId;
  String? _currentUserName;
  String? _currentReverbAppKey;

  // Stream untuk menerima pesan
  final _messageController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;
  bool get isConnected => _isConnected;

  /// Connect ke Reverb WebSocket
  Future<void> connect({
    required String meetingId,
    required String userId,
    required String userName,
    required String reverbAppKey,
  }) async {
    // Simpan parameter untuk reconnect otomatis
    _currentMeetingId = meetingId;
    _currentUserId = userId;
    _currentUserName = userName;
    _currentReverbAppKey = reverbAppKey;

    try {
      // Construct WebSocket URL untuk Reverb
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
      _reconnectAttempts = 0;

      debugPrint('[ChatService] WebSocket connected successfully');

      // Subscribe ke channel
      _subscribeToChannel('chat');

      // Mulai listen ke stream
      _startListening();

      // Setup heartbeat untuk keep-alive
      _setupHeartbeat();
    } catch (e) {
      debugPrint('[ChatService] Connection error: $e');
      _isConnected = false;
      _attemptReconnect();
      rethrow;
    }
  }

  /// Subscribe ke channel
  void _subscribeToChannel(String channel) {
    try {
      final subscribeMessage = {
        'event': 'pusher:subscribe',
        'data': {'channel': channel},
      };

      debugPrint('[ChatService] Subscribing to channel: $channel');
      _channel?.sink.add(jsonEncode(subscribeMessage));
    } catch (e) {
      debugPrint('[ChatService] Subscribe error: $e');
    }
  }

  /// Mulai listen ke incoming messages
  void _startListening() {
    // Cancel previous subscription jika ada
    _streamSubscription?.cancel();

    _streamSubscription = _channel?.stream.listen(
      (message) {
        _handleIncomingMessage(message);
      },
      onError: (error) {
        debugPrint('[ChatService] Stream error: $error');
        _isConnected = false;
        _attemptReconnect();
      },
      onDone: () {
        debugPrint('[ChatService] WebSocket stream closed');
        _isConnected = false;
        _attemptReconnect();
      },
      cancelOnError: false,
    );
  }

  /// Handle incoming messages dari WebSocket
  void _handleIncomingMessage(dynamic message) {
    try {
      debugPrint('[ChatService] Received raw message: $message');

      // Parse JSON string jika diperlukan
      Map<String, dynamic> data;
      if (message is String) {
        data = jsonDecode(message) as Map<String, dynamic>;
      } else {
        data = message as Map<String, dynamic>;
      }

      final event = data['event'] as String?;

      // Ignore system events dari Pusher/Reverb
      if (event == 'pusher:connection_established' ||
          event == 'pusher_internal:subscription_succeeded' ||
          event?.startsWith('pusher:') == true) {
        debugPrint('[ChatService] System event received, ignoring: $event');
        return;
      }

      // Emit actual message ke subscriber
      _messageController.add(data);
      debugPrint('[ChatService] Message emitted: $data');
    } catch (e) {
      debugPrint('[ChatService] Error handling message: $e');
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

  /// Setup heartbeat untuk maintain connection
  void _setupHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(Duration(seconds: 25), (_) {
      if (_isConnected && _channel != null) {
        try {
          final heartbeat = {
            'event': 'pusher:ping',
            'data': {},
          };
          _channel?.sink.add(jsonEncode(heartbeat));
          debugPrint('[ChatService] Heartbeat sent');
        } catch (e) {
          debugPrint('[ChatService] Heartbeat error: $e');
        }
      }
    });
  }

  /// Attempt reconnect dengan exponential backoff
  Future<void> _attemptReconnect() async {
    if (_isReconnecting || _reconnectAttempts >= _maxReconnectAttempts) {
      debugPrint('[ChatService] Max reconnect attempts reached');
      return;
    }

    if (_currentMeetingId == null ||
        _currentUserId == null ||
        _currentUserName == null ||
        _currentReverbAppKey == null) {
      debugPrint('[ChatService] Missing connection parameters');
      return;
    }

    _isReconnecting = true;
    _reconnectAttempts++;

    // Exponential backoff: 2s, 4s, 8s, 16s, 32s
    final delaySeconds = 2 * (_reconnectAttempts);

    debugPrint(
      '[ChatService] Reconnecting ($_reconnectAttempts/$_maxReconnectAttempts) in ${delaySeconds}s',
    );

    await Future.delayed(Duration(seconds: delaySeconds));

    try {
      await disconnect();
      await connect(
        meetingId: _currentMeetingId!,
        userId: _currentUserId!,
        userName: _currentUserName!,
        reverbAppKey: _currentReverbAppKey!,
      );
      _isReconnecting = false;
    } catch (e) {
      debugPrint('[ChatService] Reconnect failed: $e');
      _isReconnecting = false;
      _attemptReconnect();
    }
  }

  /// Disconnect dari WebSocket
  Future<void> disconnect() async {
    try {
      _isConnected = false;
      _heartbeatTimer?.cancel();
      _streamSubscription?.cancel();
      await _channel?.sink.close();
      _channel = null;
      debugPrint('[ChatService] WebSocket disconnected');
    } catch (e) {
      debugPrint('[ChatService] Disconnect error: $e');
    }
  }

  /// Cleanup resources
  void dispose() {
    _heartbeatTimer?.cancel();
    _streamSubscription?.cancel();
    _messageController.close();
    disconnect();
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
