import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';

import 'auth_provider.dart';
import 'order_provider.dart';
import 'product_provider.dart';

final notificationServiceProvider = Provider((ref) {
  final authService = ref.watch(authServiceProvider);
  return ApiNotificationService(dio: authService.dio);
});

final unreadNotificationCountProvider = Provider.autoDispose<AsyncValue<int>>((ref) {
  final listAsync = ref.watch(notificationListProvider);
  return listAsync.whenData((list) => list.where((n) => !n.isRead).length);
});

class NotificationListNotifier extends StateNotifier<AsyncValue<List<NotificationModel>>> {
  final ApiNotificationService _service;
  final Ref _ref;

  NotificationListNotifier(this._service, this._ref) : super(const AsyncValue.loading()) {
    fetchNotifications();
    _connectWebSocket();
    _service.initializePushNotifications();
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
      
      // Invalidate providers to achieve real-time updates across the app
      // Invalidate orders immediately
      _ref.invalidate(sellerOrdersProvider);
      _ref.invalidate(userOrdersProvider);
      
      // Invalidate all orderDetailProvider instances when order status changes
      // This covers the case where a buyer has an order detail screen open
      if (newNotification.type.contains('ORDER') || newNotification.type.contains('STATUS')) {
        _ref.invalidate(orderDetailProvider);
      }
      
      // Delay product invalidation slightly to allow Kafka events to process the stock update
      Future.delayed(const Duration(seconds: 2), () {
        _ref.invalidate(productsProvider);
        final user = _ref.read(userProfileProvider).valueOrNull;
        if (user != null) {
          _ref.invalidate(sellerProductsProvider(user.id));
        } else {
          _ref.invalidate(sellerProductsProvider);
        }
      });
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
  return NotificationListNotifier(service, ref);
});
