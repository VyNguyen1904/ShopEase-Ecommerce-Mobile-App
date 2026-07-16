import 'dart:io' show Platform;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import '../models/notification_model.dart';
import 'auth_service.dart';

class ApiNotificationService {
  final Dio _dio;
  final AuthService _authService = AuthService();

  String get _host {
    if (kIsWeb) {
      final host = Uri.base.host;
      return "http://${host.isNotEmpty ? host : '127.0.0.1'}:8000";
    }
    try {
      if (Platform.isAndroid) return 'http://172.20.10.5:8000';
    } catch (_) {}
    return 'http://127.0.0.1:8000';
  }

  String get _apiUrl => '$_host/api/notifications';

  ApiNotificationService({Dio? dio}) : _dio = dio ?? Dio();

  Future<List<NotificationModel>> getNotifications() async {
    try {
      final response = await _dio.get(_apiUrl);
      final data = response.data['data'] as List<dynamic>;
      return data.map((json) => NotificationModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load notifications: $e');
    }
  }

  Future<int> getUnreadCount() async {
    try {
      final response = await _dio.get('$_apiUrl/unread-count');
      return response.data['data']['count'] as int;
    } catch (e) {
      return 0;
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      await _dio.put('$_apiUrl/$id/read');
    } catch (e) {
      throw Exception('Failed to mark as read: $e');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _dio.put('$_apiUrl/read-all');
    } catch (e) {
      throw Exception('Failed to mark all as read: $e');
    }
  }

  // WebSocket support for real-time notifications
  StompClient? _stompClient;
  Function(NotificationModel)? onNotificationReceived;

  String get _wsUrl {
    if (kIsWeb) {
      final host = Uri.base.host;
      return "ws://${host.isNotEmpty ? host : '127.0.0.1'}:8091/ws/notifications";
    }
    try {
      if (Platform.isAndroid) return 'ws://172.20.10.5:8091/ws/notifications';
    } catch (_) {}
    return 'ws://127.0.0.1:8091/ws/notifications';
  }

  Future<void> connectWebSocket(Function(NotificationModel) onReceived) async {
    onNotificationReceived = onReceived;
    final token = await _authService.getAccessToken();
    final userId = await _authService.getUserId();
    if (userId == null) return;

    _stompClient = StompClient(
      config: StompConfig(
        url: _wsUrl,
        onConnect: (StompFrame frame) {
          _stompClient?.subscribe(
            destination: '/topic/notifications/$userId',
            callback: (frame) {
              if (frame.body != null && onNotificationReceived != null) {
                final Map<String, dynamic> data = jsonDecode(frame.body!);
                onNotificationReceived!(NotificationModel.fromJson(data));
              }
            },
          );
        },
        onWebSocketError: (dynamic error) => debugPrint('WS Error: $error'),
        stompConnectHeaders: {'Authorization': 'Bearer $token'},
      ),
    );
    _stompClient?.activate();
  }

  void disconnectWebSocket() {
    _stompClient?.deactivate();
    _stompClient = null;
  }
}
