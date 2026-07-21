import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/providers/payment_provider.dart';
import '../../../core/models/order_model.dart';
import '../../../core/services/order_service.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  final String orderId;

  const PaymentScreen({super.key, required this.orderId});

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  bool _hasOpenedVNPay = false;
  bool _isPolling = false;
  Timer? _pollTimer;
  String _statusText = 'Đang tạo liên kết thanh toán...';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _openVNPay();
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _openVNPay() async {
    setState(() => _statusText = 'Đang tạo liên kết thanh toán...');
    try {
      final orderService = OrderService();
      final order = await orderService.getOrderDetail(widget.orderId);
      final paymentService = ref.read(paymentServiceProvider);
      final paymentUrl = await paymentService.createVNPayUrl(
        widget.orderId,
        order.totalAmount.toInt(),
      );
      final uri = Uri.parse(paymentUrl);

      if (await canLaunchUrl(uri)) {
        setState(() {
          _hasOpenedVNPay = true;
          _statusText = 'Đã mở trang VNPay. Vui lòng hoàn tất thanh toán.';
        });
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        // After returning from VNPay, start polling
        _startPolling();
      } else {
        setState(
          () => _statusText = 'Không thể mở trang VNPay. Vui lòng thử lại.',
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _statusText = 'Lỗi: $e');
      }
    }
  }

  void _startPolling() {
    if (_isPolling) return;
    setState(() {
      _isPolling = true;
      _statusText = 'Đang kiểm tra kết quả thanh toán...';
    });
    // Check immediately
    _checkOrderStatus();
    _pollTimer = Timer.periodic(const Duration(seconds: 2), (_) async {
      await _checkOrderStatus();
    });
  }

  Future<void> _checkOrderStatus() async {
    try {
      final orderService = OrderService();
      final order = await orderService.getOrderDetail(widget.orderId);
      if (!mounted) return;

      if (order.paymentStatus == PaymentStatus.PAID ||
          order.status == OrderStatus.CONFIRMED ||
          order.status == OrderStatus.PACKED ||
          order.status == OrderStatus.SHIPPED ||
          order.status == OrderStatus.DELIVERED) {
        _pollTimer?.cancel();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thanh toán thành công! Đơn hàng đã được xác nhận.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
        context.go(AppRoutes.orderDetailPath(widget.orderId));
      } else if (order.paymentStatus == PaymentStatus.FAILED ||
          order.status == OrderStatus.FAILED ||
          order.status == OrderStatus.CANCELLED) {
        _pollTimer?.cancel();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Thanh toán thất bại. Bạn có thể thử lại từ trang đơn hàng.',
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
        context.go(AppRoutes.orders);
      }
    } catch (_) {
      // Silently ignore poll errors
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Thanh toán đơn hàng',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color(0xFF1E293B),
            size: 20,
          ),
          onPressed: () => context.go(AppRoutes.orders),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // VNPay logo block
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: const Color(0xFF1D4ED8),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1D4ED8).withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'VNPay',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                _hasOpenedVNPay
                    ? 'Đang chờ kết quả thanh toán'
                    : 'Đang kết nối VNPay',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                _statusText,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),
              const CircularProgressIndicator(
                color: Color(0xFF1D4ED8),
                strokeWidth: 3,
              ),
              if (_hasOpenedVNPay) ...[
                const SizedBox(height: 48),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Đã hoàn tất thanh toán trên VNPay?',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _startPolling,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1D4ED8),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Kiểm tra kết quả',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => context.go(AppRoutes.orders),
                        child: Text(
                          'Quay lại đơn hàng',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
