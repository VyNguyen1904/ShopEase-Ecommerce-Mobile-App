import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/order_model.dart';
import '../services/order_service.dart';

final orderServiceProvider = Provider((ref) => OrderService());

final userOrdersProvider = FutureProvider.autoDispose<List<OrderResponse>>((ref) async {
  final service = ref.watch(orderServiceProvider);
  return await service.getOrderHistory();
});

final sellerOrdersProvider = FutureProvider.autoDispose<List<OrderResponse>>((ref) async {
  final service = ref.watch(orderServiceProvider);
  return await service.getSellerOrders();
});

final orderDetailProvider = FutureProvider.family.autoDispose<OrderResponse, String>((ref, id) async {
  final service = ref.watch(orderServiceProvider);
  return await service.getOrderDetail(id);
});
