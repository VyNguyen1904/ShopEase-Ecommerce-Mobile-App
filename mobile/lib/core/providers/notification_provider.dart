import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';

final notificationServiceProvider = Provider((ref) => ApiNotificationService());

final unreadNotificationCountProvider = Provider.autoDispose<AsyncValue<int>>((ref) {
  final listAsync = ref.watch(notificationListProvider);
  return listAsync.whenData((list) => list.where((n) => !n.isRead).length);
});

class NotificationListNotifier extends StateNotifier<AsyncValue<List<NotificationModel>>> {
  final ApiNotificationService _service;

  NotificationListNotifier(this._service) : super(const AsyncValue.loading()) {
    fetchNotifications();
    _connectWebSocket();
  }

  Future<void> fetchNotifications() async {
    try {
      final notifications = await _service.getNotifications();
      state = AsyncValue.data(notifications);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void _connectWebSocket() {
    _service.connectWebSocket((newNotification) {
      addLocalNotification(newNotification);
    });
  }

  void addLocalNotification(NotificationModel notification) {
    state.whenData((notifications) {
      state = AsyncValue.data([notification, ...notifications]);
    });
  }

  Future<void> markAsRead(String id) async {
    await _service.markAsRead(id);
    state.whenData((notifications) {
      final updated = notifications.map((n) {
        if (n.id == id) {
          return NotificationModel(
            id: n.id,
            title: n.title,
            message: n.message,
            type: n.type,
            isRead: true,
            createdAt: n.createdAt,
          );
        }
        return n;
      }).toList();
      state = AsyncValue.data(updated);
    });
  }

  Future<void> markAllAsRead() async {
    await _service.markAllAsRead();
    state.whenData((notifications) {
      final updated = notifications.map((n) {
        return NotificationModel(
          id: n.id,
          title: n.title,
          message: n.message,
          type: n.type,
          isRead: true,
          createdAt: n.createdAt,
        );
      }).toList();
      state = AsyncValue.data(updated);
    });
  }

  @override
  void dispose() {
    _service.disconnectWebSocket();
    super.dispose();
  }
}

final notificationListProvider = StateNotifierProvider<NotificationListNotifier, AsyncValue<List<NotificationModel>>>((ref) {
  final service = ref.read(notificationServiceProvider);
  return NotificationListNotifier(service);
});
