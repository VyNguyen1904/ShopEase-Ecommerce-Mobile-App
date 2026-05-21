import 'package:flutter/material.dart';
import 'widgets/custom_bottom_nav.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  int _selectedTabIndex = 0;
  final List<String> _tabs = ['Tất cả', 'Đang xử lý', 'Đang giao', 'Hoàn thành', 'Đã hủy'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 28),
                  const Text(
                    'Đơn hàng của tôi',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F4C75),
                    ),
                  ),
                  const Icon(Icons.search_rounded, color: Color(0xFF1E3A8A), size: 26),
                ],
              ),
            ),
            const SizedBox(height: 32),

            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _tabs.length,
                itemBuilder: (context, index) {
                  final isActive = _selectedTabIndex == index;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTabIndex = index;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: isActive ? const Color(0xFF205273) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          _tabs[index],
                          style: TextStyle(
                            color: isActive ? Colors.white : const Color(0xFF4B5563),
                            fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _buildActiveOrderCard(),
                  const SizedBox(height: 20),
                  _buildCompletedOrderCard(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 3),
    );
  }

  Widget _buildActiveOrderCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('MÃ ĐƠN HÀNG', style: TextStyle(color: Color(0xFF6B7280), fontSize: 11, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text('#ZNB123456', style: TextStyle(color: Color(0xFF205273), fontSize: 15, fontWeight: FontWeight.w900)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: const [
                  Text('Ngày đặt', style: TextStyle(color: Color(0xFF6B7280), fontSize: 11)),
                  SizedBox(height: 4),
                  Text('24 Thg 10, 2023', style: TextStyle(color: Color(0xFF374151), fontSize: 13, fontWeight: FontWeight.w500)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Color(0xFFF3F4F6), thickness: 1, height: 1),
          const SizedBox(height: 16),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStepItem(Icons.check_circle_rounded, 'Đã đặt', true, true),
              _buildStepLine(true),
              _buildStepItem(Icons.check_circle_rounded, 'Đang xử lý', true, true),
              _buildStepLine(true),
              _buildStepItem(Icons.local_shipping_outlined, 'Đang giao', true, false, isCurrent: true),
              _buildStepLine(false),
              _buildStepItem(Icons.circle, 'Thành công', false, false),
            ],
          ),
          const SizedBox(height: 24),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    'https://images.unsplash.com/photo-1618366712010-f4ae9c647dcb?auto=format&fit=crop&w=150&q=80',
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Tai nghe Không dây Chống ồn Premium Z-Series',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF1F2937)),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Màu: Đen Midnight • Số lượng: 1',
                        style: TextStyle(color: Color(0xFF6B7280), fontSize: 12),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '2.450.000 đ',
                        style: TextStyle(color: Color(0xFF205273), fontWeight: FontWeight.w800, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Divider(color: Color(0xFFF3F4F6), thickness: 1, height: 1),
          const SizedBox(height: 16),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFD1D5DB)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text('Chi tiết', style: TextStyle(color: Color(0xFF374151), fontWeight: FontWeight.w600, fontSize: 14)),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF03425F),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text('Theo dõi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildCompletedOrderCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('MÃ ĐƠN HÀNG', style: TextStyle(color: Color(0xFF6B7280), fontSize: 11, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text('#ZNB098765', style: TextStyle(color: Color(0xFF374151), fontSize: 15, fontWeight: FontWeight.w900)),
                ],
              ),
              Row(
                children: const [
                  Icon(Icons.check_circle_rounded, color: Color(0xFF059669), size: 16),
                  SizedBox(width: 4),
                  Text('Đã giao hàng', style: TextStyle(color: Color(0xFF059669), fontSize: 13, fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Product details
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  'https://images.unsplash.com/photo-1546868871-7041f2a55e12?auto=format&fit=crop&w=150&q=80',
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Đồng hồ Thông minh Tracker Pro',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF374151)),
                    ),
                    SizedBox(height: 6),
                    Text(
                      '1.200.000 đ',
                      style: TextStyle(color: Color(0xFF9CA3AF), fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(color: Color(0xFFF3F4F6), thickness: 1, height: 1),
          const SizedBox(height: 16),

          // Action buttons
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFD1D5DB)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text('Mua lại', style: TextStyle(color: Color(0xFF4B5563), fontWeight: FontWeight.w600, fontSize: 13)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStepItem(IconData icon, String label, bool isCompleted, bool isSolid, {bool isCurrent = false}) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(isCurrent ? 6 : 0),
            decoration: isCurrent
                ? BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF205273), width: 2),
                  )
                : null,
            child: isSolid
                ? Icon(icon, color: const Color(0xFF205273), size: 24)
                : Icon(
                    icon,
                    color: isCompleted ? const Color(0xFF205273) : const Color(0xFFD1D5DB),
                    size: isCurrent ? 24 : 20,
                  ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isCurrent ? FontWeight.bold : (isCompleted ? FontWeight.w600 : FontWeight.normal),
              color: isCurrent ? const Color(0xFF03425F) : (isCompleted ? const Color(0xFF1F2937) : const Color(0xFF9CA3AF)),
            ),
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }

  Widget _buildStepLine(bool isCompleted) {
    return Container(
      margin: const EdgeInsets.only(top: 14),
      width: 30,
      height: 3,
      decoration: BoxDecoration(
        color: isCompleted ? const Color(0xFF205273) : const Color(0xFFE5E7EB),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}


