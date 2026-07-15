import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/payment_service.dart';
import '../models/payment_model.dart';

import 'auth_provider.dart';

final paymentServiceProvider = Provider((ref) {
  final authService = ref.watch(authServiceProvider);
  return PaymentService(dio: authService.dio);
});

final paymentStatusProvider =
    FutureProvider.family<CheckoutPaymentResponse, String>((ref, orderId) async {
      final service = ref.watch(paymentServiceProvider);
      return service.getPaymentStatus(orderId);
    });

final paymentQrProvider = FutureProvider.family<String, String>((ref, orderId) async {
  final service = ref.watch(paymentServiceProvider);
  return service.getPaymentQr(orderId);
});
