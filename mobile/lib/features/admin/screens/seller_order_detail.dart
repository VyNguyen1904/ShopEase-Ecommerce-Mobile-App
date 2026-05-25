import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';


class SellerOrderDetail extends StatefulWidget {
  const SellerOrderDetail({super.key});

  @override
  State<SellerOrderDetail> createState() => _SellerOrderDetailState();
}

class _SellerOrderDetailState extends State<SellerOrderDetail> {
  int _activeStatusStep = 0; // 0 = Confirmed, 1 = Packed, 2 = Shipped, 3 = Completed

  final List<String> _statusTexts = [
    'Đang xử lý',
    'Đã đóng gói',
    'Đang giao',
    'Hoàn thành',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Chi tiết đơn hàng',
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz, color: AppColors.textDark),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Order Code block (Seller/1.png)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              '#DH2405190001',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: _activeStatusStep == 0
                                    ? const Color(0xFFFFF7ED)
                                    : (_activeStatusStep == 3 ? const Color(0xFFEAF5F6) : const Color(0xFFECEFFF)),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _statusTexts[_activeStatusStep],
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: _activeStatusStep == 0
                                      ? const Color(0xFFD97706)
                                      : (_activeStatusStep == 3 ? AppColors.primary : const Color(0xFF3B82F6)),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '19/05/2024 • 10:24  •  Thanh toán: Đã thanh toán',
                          style: TextStyle(fontSize: 13, color: AppColors.textGrey),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 2. Customer info "Thông tin khách hàng"
                  _buildSectionContainer(
                    title: 'Thông tin khách hàng',
                    icon: Icons.person_outline,
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: NetworkImage(
                                'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150&auto=format&fit=crop&q=80',
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Nguyễn Văn An',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textDark),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '📞 0987 654 321',
                                style: TextStyle(fontSize: 13, color: AppColors.textGrey),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chat_bubble_outline, color: AppColors.primary, size: 20),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 3. Delivery address "Địa chỉ giao hàng" (with map)
                  _buildSectionContainer(
                    title: 'Địa chỉ giao hàng',
                    icon: Icons.location_on_outlined,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Nguyễn Văn An',
                                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textDark),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Mặc định',
                                    style: TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              SizedBox(height: 6),
                              Text(
                                '123 Đường Lê Lai, Phường Bến Thành,\nQuận 1, TP. Hồ Chí Minh',
                                style: TextStyle(fontSize: 13, color: AppColors.textGrey, height: 1.4),
                              ),
                              SizedBox(height: 6),
                              Text(
                                '📞 0987 654 321',
                                style: TextStyle(fontSize: 13, color: AppColors.textGrey),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Mock map placeholder
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                            image: const DecorationImage(
                              image: NetworkImage(
                                'https://images.unsplash.com/photo-1524661135-423995f22d0b?w=200&auto=format&fit=crop&q=80',
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 4. Products section
                  _buildSectionContainer(
                    title: 'Sản phẩm',
                    icon: Icons.inventory_2_outlined,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: AppColors.bgLight,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Image.network(
                                'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=200&auto=format&fit=crop&q=80',
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(width: 14),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Nike Air Max 270',
                                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textDark),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Trắng / Đen  •  Size 42  •  x1',
                                    style: TextStyle(fontSize: 13, color: AppColors.textGrey),
                                  ),
                                ],
                              ),
                            ),
                            const Text(
                              '1.250.000đ',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textDark),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(height: 1, color: AppColors.border),
                        const SizedBox(height: 12),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Phí vận chuyển', style: TextStyle(fontSize: 13, color: AppColors.textGrey)),
                            Text('30.000đ', style: TextStyle(fontSize: 13, color: AppColors.textDark, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Tổng tiền',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textDark),
                            ),
                            Text(
                              '1.280.000đ',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.accent),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 5. Payment Details
                  _buildSectionContainer(
                    title: 'Thanh toán',
                    icon: Icons.credit_card_outlined,
                    child: const Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Phương thức', style: TextStyle(fontSize: 13, color: AppColors.textGrey)),
                            Text('Ví ShopeePay', style: TextStyle(fontSize: 13, color: AppColors.textDark, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Trạng thái', style: TextStyle(fontSize: 13, color: AppColors.textGrey)),
                            Text('Đã thanh toán', style: TextStyle(fontSize: 13, color: AppColors.iconGreen, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 6. Timeline history "Lịch sử đơn hàng"
                  _buildSectionContainer(
                    title: 'Lịch sử đơn hàng',
                    icon: Icons.history,
                    child: Column(
                      children: [
                        _buildTimelineItem(
                          title: 'Đơn hàng đã được đặt',
                          time: '19/05/2024 • 10:24',
                          user: 'Hệ thống',
                          isDone: true,
                        ),
                        _buildTimelineItem(
                          title: 'Đơn hàng đã xác nhận',
                          time: '19/05/2024 • 10:30',
                          user: 'Bạn',
                          isDone: _activeStatusStep >= 0,
                        ),
                        _buildTimelineItem(
                          title: 'Đơn hàng đã đóng gói',
                          time: _activeStatusStep >= 1 ? '19/05/2024 • 11:15' : '--:--/--/----  •  --:--',
                          user: _activeStatusStep >= 1 ? 'Bạn' : '---',
                          isDone: _activeStatusStep >= 1,
                        ),
                        _buildTimelineItem(
                          title: 'Đơn hàng đã bàn giao vận chuyển',
                          time: _activeStatusStep >= 2 ? '19/05/2024 • 14:00' : '--:--/--/----  •  --:--',
                          user: _activeStatusStep >= 2 ? 'Bạn' : '---',
                          isDone: _activeStatusStep >= 2,
                        ),
                        _buildTimelineItem(
                          title: 'Đơn hàng đã giao thành công',
                          time: _activeStatusStep >= 3 ? '21/05/2024 • 16:30' : '--:--/--/----  •  --:--',
                          user: _activeStatusStep >= 3 ? 'Hệ thống' : '---',
                          isDone: _activeStatusStep >= 3,
                          isLast: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // 7. Bottom interactive action panel (Seller/1.png)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Cập nhật trạng thái đơn hàng',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textGrey),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildActionButton(0, Icons.check_circle_outline, 'Xác nhận'),
                    const SizedBox(width: 8),
                    _buildActionButton(1, Icons.inventory_2_outlined, 'Đóng gói'),
                    const SizedBox(width: 8),
                    _buildActionButton(2, Icons.local_shipping_outlined, 'Bàn giao'),
                    const SizedBox(width: 8),
                    _buildActionButton(3, Icons.done_all, 'Hoàn thành'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionContainer({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textGrey),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildTimelineItem({
    required String title,
    required String time,
    required String user,
    required bool isDone,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Dots and lines
        Column(
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: isDone ? AppColors.primary : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDone ? AppColors.primary : AppColors.textLight,
                  width: 2.5,
                ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2.5,
                height: 38,
                color: isDone ? AppColors.primary : AppColors.border,
              ),
          ],
        ),
        const SizedBox(width: 16),
        // Timeline content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isDone ? AppColors.textDark : AppColors.textLight,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                time,
                style: const TextStyle(fontSize: 11, color: AppColors.textLight),
              ),
            ],
          ),
        ),
        Text(
          user,
          style: TextStyle(fontSize: 12, color: isDone ? AppColors.textGrey : AppColors.textLight, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildActionButton(int step, IconData icon, String label) {
    final isSelected = _activeStatusStep == step;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _activeStatusStep = step;
          });
        },
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryLight : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isSelected ? AppColors.primary : AppColors.textGrey, size: 18),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? AppColors.primary : AppColors.textGrey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
