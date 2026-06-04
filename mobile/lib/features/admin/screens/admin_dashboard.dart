import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header (Admin/1.png)
              Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: const DecorationImage(
                          image: NetworkImage(
                            'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150&auto=format&fit=crop&q=80',
                          ),
                          fit: BoxFit.cover,
                        ),
                        border: Border.all(color: AppColors.border, width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Chào mừng trở lại, Admin',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Image.network(
                              'https://fonts.gstatic.com/s/e/notoemoji/latest/1f44b/512.webp', // Waving hand gif/img
                              width: 20,
                              height: 20,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Text('👋'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Chúc bạn một ngày làm việc hiệu quả!',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Bell Icon
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.bgLight,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Icon(
                          Icons.notifications_none,
                          color: AppColors.textDark,
                          size: 22,
                        ),
                        Positioned(
                          right: 12,
                          top: 12,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.alertRed,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // 2. Overview "Tổng quan"
              const Text(
                'Tổng quan',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 16),

              // Overview Cards Row
              Row(
                children: [
                  // Total revenue card
                  Expanded(
                    child: _buildOverviewCard(
                      icon: Icons.attach_money,
                      iconColor: AppColors.primary,
                      iconBg: const Color(0xFFEAF5F6),
                      title: 'Tổng doanh thu',
                      value: '\$25,450',
                      percentage: '12.7%',
                      isIncrease: true,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Total orders card
                  Expanded(
                    child: _buildOverviewCard(
                      icon: Icons.shopping_bag_outlined,
                      iconColor: AppColors.primary,
                      iconBg: const Color(0xFFEAF5F6),
                      title: 'Tổng đơn hàng',
                      value: '1,245',
                      percentage: '13.3%',
                      isIncrease: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // 3. Sales chart section "Tổng quan doanh số" (Admin/1.png)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Tổng quan doanh số',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Row(
                      children: [
                        Text(
                          '7 ngày qua',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.keyboard_arrow_down,
                          size: 16,
                          color: AppColors.textGrey,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Chart legend labels
              Row(
                children: [
                  _buildLegendDot(AppColors.primary, 'Doanh thu'),
                  const SizedBox(width: 16),
                  _buildLegendDot(const Color(0xFFCBECE8), 'Đơn hàng'),
                ],
              ),
              const SizedBox(height: 24),

              // Bar Chart custom visual representation
              SizedBox(
                height: 200,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildDoubleBar(
                      '9 Thg 5',
                      revenueHeight: 80,
                      orderHeight: 100,
                    ),
                    _buildDoubleBar(
                      '10 Thg 5',
                      revenueHeight: 120,
                      orderHeight: 90,
                    ),
                    _buildDoubleBar(
                      '11 Thg 5',
                      revenueHeight: 140,
                      orderHeight: 160,
                    ),
                    _buildDoubleBar(
                      '12 Thg 5',
                      revenueHeight: 150,
                      orderHeight: 120,
                    ),
                    _buildDoubleBar(
                      '13 Thg 5',
                      revenueHeight: 100,
                      orderHeight: 110,
                    ),
                    _buildDoubleBar(
                      '14 Thg 5',
                      revenueHeight: 150,
                      orderHeight: 110,
                    ),
                    _buildDoubleBar(
                      '15 Thg 5',
                      revenueHeight: 170,
                      orderHeight: 110,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String value,
    required String percentage,
    required bool isIncrease,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.01),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Styled Icon circle
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 18),
          // Title
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textGrey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          // Value
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          // Percentage change row
          Row(
            children: [
              Icon(
                isIncrease ? Icons.arrow_upward : Icons.arrow_downward,
                color: isIncrease ? AppColors.iconGreen : AppColors.alertRed,
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                percentage,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isIncrease ? AppColors.iconGreen : AppColors.alertRed,
                ),
              ),
              const SizedBox(width: 4),
              const Expanded(
                child: Text(
                  'so với tháng trước',
                  style: TextStyle(fontSize: 9, color: AppColors.textLight),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendDot(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textGrey,
          ),
        ),
      ],
    );
  }

  Widget _buildDoubleBar(
    String date, {
    required double revenueHeight,
    required double orderHeight,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Two adjacent bars representing chart data
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              width: 10,
              height: revenueHeight,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ),
            const SizedBox(width: 4),
            Container(
              width: 10,
              height: orderHeight,
              decoration: const BoxDecoration(
                color: Color(0xFFCBECE8),
                borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Date Label
        Text(
          date,
          style: const TextStyle(
            fontSize: 9,
            color: AppColors.textGrey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
