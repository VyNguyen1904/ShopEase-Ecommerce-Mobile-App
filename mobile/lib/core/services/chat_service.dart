import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'auth_service.dart';

class ApiChatService {
  final Dio _dio;
  final AuthService _authService = AuthService();

  String get _host {
    if (kIsWeb) {
      final host = Uri.base.host;
      return "http://${host.isNotEmpty ? host : '127.0.0.1'}:8000";
    }
    try {
      if (Platform.isAndroid) return 'http://10.0.2.2:8000';
    } catch (_) {}
    return 'http://127.0.0.1:8000';
  }

  String get _chatUrl => '$_host/api/chats';

  ApiChatService({Dio? dio}) : _dio = dio ?? Dio();

  Future<List<dynamic>> getMyChats() async {
    try {
      final response = await _dio.get(
        _chatUrl,
        queryParameters: {'_t': DateTime.now().millisecondsSinceEpoch},
      );
      return response.data['data'] as List<dynamic>;
    } catch (e) {
      throw Exception('Failed to load chats: $e');
    }
  }

  Future<List<dynamic>> getMessages(String roomId) async {
    try {
      final response = await _dio.get(
        '$_chatUrl/$roomId/messages',
        queryParameters: {'_t': DateTime.now().millisecondsSinceEpoch},
      );
      return response.data['data'] as List<dynamic>;
    } catch (e) {
      throw Exception('Failed to load messages: $e');
    }
  }

  Future<dynamic> sendMessage(String roomId, String text) async {
    try {
      final response = await _dio.post('$_chatUrl/$roomId/messages', data: text);
      return response.data['data'];
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  Future<dynamic> getOrCreateRoom(String targetUserId) async {
    try {
      final response = await _dio.post('$_chatUrl/room?targetUserId=$targetUserId');
      return response.data['data'];
    } catch (e) {
      throw Exception('Failed to create room: $e');
    }
  }

  // WebSocket / STOMP support
  StompClient? _stompClient;
  Function(dynamic)? onMessageReceived;

  String get _wsUrl {
    if (kIsWeb) {
      final host = Uri.base.host;
      return "ws://${host.isNotEmpty ? host : '127.0.0.1'}:8090/ws/chats";
    }
    try {
      if (Platform.isAndroid) return 'ws://10.0.2.2:8090/ws/chats';
    } catch (_) {}
    return 'ws://127.0.0.1:8090/ws/chats';
  }

  Function(String)? onTypingIndicatorReceived;

  void connectWebSocket(String roomId, Function(dynamic) onMessage, {Function(String)? onTyping}) async {
    onMessageReceived = onMessage;
    onTypingIndicatorReceived = onTyping;
    final token = await _authService.getAccessToken();
    
    _stompClient = StompClient(
      config: StompConfig(
        url: _wsUrl,
        onConnect: (StompFrame frame) {
          _stompClient?.subscribe(
            destination: '/topic/chat/$roomId',
            callback: (frame) {
              if (frame.body != null && onMessageReceived != null) {
                onMessageReceived!(frame.body);
              }
            },
          );
          if (onTypingIndicatorReceived != null) {
            _stompClient?.subscribe(
              destination: '/topic/chat/$roomId/typing',
              callback: (frame) {
                if (frame.body != null) {
                  onTypingIndicatorReceived!(frame.body!);
                }
              },
            );
          }
        },
        onWebSocketError: (dynamic error) => debugPrint('WebSocket Error: $error'),
        stompConnectHeaders: {'Authorization': 'Bearer $token'},
      ),
    );
    _stompClient?.activate();
  }

  void sendTypingEvent(String roomId, String myUserId) {
    _stompClient?.send(
      destination: '/app/chat/$roomId/typing',
      body: myUserId,
    );
  }

  void disconnectWebSocket() {
    _stompClient?.deactivate();
    _stompClient = null;
    onMessageReceived = null;
    onTypingIndicatorReceived = null;
  }
}
