import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/payment_service.dart';
import '../models/payment_model.dart';

final paymentServiceProvider = Provider((ref) => PaymentService());

final paymentStatusProvider =
    FutureProvider.family<CheckoutPaymentResponse, String>((ref, orderId) async {
      final service = ref.watch(paymentServiceProvider);
      return service.getPaymentStatus(orderId);
    });

final paymentQrProvider = FutureProvider.family<String, String>((ref, orderId) async {
  final service = ref.watch(paymentServiceProvider);
  return service.getPaymentQr(orderId);
});
