import 'package:flutter/material.dart';
import 'widgets/custom_bottom_nav.dart';

class PaymentSuccessScreen extends StatelessWidget {
  const PaymentSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9FAFB),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2937)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'ShopEase',
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined, color: Color(0xFF1F2937)),
            onPressed: () => Navigator.pushNamed(context, '/cart'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Column(
          children: [
            // Success Icon
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Color(0xFFA5F3FC), // Light cyan
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_outline,
                color: Color(0xFF0F766E), // Dark cyan/teal
                size: 50,
              ),
            ),
            const SizedBox(height: 24),
            
            // Title & Subtitle
            const Text(
              'Thanh toán thành công!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Cảm ơn bạn đã mua sắm tại ShopEase. Đơn hàng của\nbạn đang được xử lý.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),

            // Receipt Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
              ),
              child: Column(
                children: [
                  _buildReceiptRow('Mã giao dịch', '#SE-88291044'),
                  const Divider(color: Color(0xFFF3F4F6), height: 32, thickness: 1),
                  _buildReceiptRow('Thời gian', '14:35, 24 Tháng 5, 2024'),
                  const Divider(color: Color(0xFFF3F4F6), height: 32, thickness: 1),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Phương thức thanh toán', style: TextStyle(color: Color(0xFF4B5563), fontSize: 13)),
                      Row(
                        children: const [
                          Icon(Icons.credit_card, size: 16, color: Color(0xFF1F2937)),
                          SizedBox(width: 6),
                          Text('Ví điện tử MoMo', style: TextStyle(color: Color(0xFF1F2937), fontSize: 13)),
                        ],
                      ),
                    ],
                  ),
                  const Divider(color: Color(0xFFF3F4F6), height: 32, thickness: 1),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('Tổng tiền', style: TextStyle(color: Color(0xFF1F2937), fontWeight: FontWeight.bold, fontSize: 15)),
                      Text('1.250.000 đ', style: TextStyle(color: Color(0xFF2E6582), fontWeight: FontWeight.bold, fontSize: 18)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Promo Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF2E6582),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -20,
                    bottom: -20,
                    child: Icon(
                      Icons.local_offer,
                      size: 100,
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFA5F3FC),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Mới nhất',
                          style: TextStyle(color: Color(0xFF0F766E), fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Ưu đãi mùa hè',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Giảm thêm 15% cho đơn hàng tiếp theo.',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Tracking Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB).withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.local_shipping_outlined, color: Color(0xFF1F2937)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Theo dõi vận chuyển', style: TextStyle(color: Color(0xFF1F2937), fontWeight: FontWeight.bold, fontSize: 14)),
                        SizedBox(height: 4),
                        Text('Cập nhật vị trí gói hàng thời gian thực.', style: TextStyle(color: Color(0xFF6B7280), fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Buttons
            OutlinedButton(
              onPressed: () => Navigator.pushNamed(context, '/orders'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                side: const BorderSide(color: Color(0xFF2E6582)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.receipt_long_outlined, color: Color(0xFF2E6582), size: 18),
                  SizedBox(width: 8),
                  Text('Xem chi tiết đơn hàng', style: TextStyle(color: Color(0xFF2E6582), fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E6582),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Text('Tiếp tục mua sắm', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 0),
    );
  }

  Widget _buildReceiptRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF4B5563), fontSize: 13)),
        Text(value, style: const TextStyle(color: Color(0xFF1F2937), fontSize: 13)),
      ],
    );
  }
}
