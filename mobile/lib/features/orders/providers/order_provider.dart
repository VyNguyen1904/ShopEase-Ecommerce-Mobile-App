import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/order_service.dart';
import '../../../../core/models/order_model.dart';

final orderServiceProvider = Provider<OrderService>((ref) {
  return OrderService();
});

final orderHistoryProvider = FutureProvider.autoDispose<List<OrderResponse>>((ref) async {
  final service = ref.watch(orderServiceProvider);
  return await service.getOrderHistory();
});
