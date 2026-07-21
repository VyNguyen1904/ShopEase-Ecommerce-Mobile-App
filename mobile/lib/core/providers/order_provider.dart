import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/order_model.dart';
import '../services/order_service.dart';

import 'auth_provider.dart';

final orderServiceProvider = Provider((ref) {
  final authService = ref.watch(authServiceProvider);
  return OrderService(dio: authService.dio);
});

final userOrdersProvider = FutureProvider.autoDispose<List<OrderResponse>>((
  ref,
) async {
  final timer = Timer(const Duration(seconds: 5), () => ref.invalidateSelf());
  ref.onDispose(() => timer.cancel());

  final service = ref.watch(orderServiceProvider);
  return await service.getOrderHistory();
});

final sellerOrdersProvider = FutureProvider.autoDispose<List<OrderResponse>>((
  ref,
) async {
  final timer = Timer(const Duration(seconds: 5), () => ref.invalidateSelf());
  ref.onDispose(() => timer.cancel());

  final service = ref.watch(orderServiceProvider);
  return await service.getSellerOrders();
});

final orderDetailProvider = FutureProvider.family
    .autoDispose<OrderResponse, String>((ref, id) async {
      final service = ref.watch(orderServiceProvider);
      final order = await service.getOrderDetail(id);

      // Tối ưu: Chỉ poll nếu đơn hàng chưa hoàn thành hoặc chưa bị huỷ
      if (order.status != OrderStatus.DELIVERED &&
          order.status != OrderStatus.CANCELLED) {
        final timer = Timer(
          const Duration(seconds: 5),
          () => ref.invalidateSelf(),
        );
        ref.onDispose(() => timer.cancel());
      }

      return order;
    });

class OrderActionController {
  final Ref ref;
  OrderActionController(this.ref);

  Future<void> cancelOrder(String orderId) async {
    final service = ref.read(orderServiceProvider);
    await service.cancelOrder(orderId);
    ref.invalidate(orderDetailProvider(orderId));
    ref.invalidate(userOrdersProvider);
  }

  Future<void> markAsDelivered(String orderId) async {
    final service = ref.read(orderServiceProvider);
    await service.markAsDelivered(orderId);
    ref.invalidate(orderDetailProvider(orderId));
    ref.invalidate(userOrdersProvider);
  }
}

final orderActionControllerProvider = Provider(
  (ref) => OrderActionController(ref),
);
