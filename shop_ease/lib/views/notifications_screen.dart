import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  int _selectedTabIndex = 0;
  final List<String> _tabs = ['Tất cả', 'Đơn hàng', 'Khuyến mãi', 'Hệ thống'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Color(0xFF1E3A8A),
                      size: 22,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    'Thông báo',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F4C75),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.search_rounded,
                      color: Color(0xFF1E3A8A),
                      size: 26,
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Tabs
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isActive
                            ? const Color(0xFF205273)
                            : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(20),
                        border: isActive
                            ? null
                            : Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Center(
                        child: Text(
                          _tabs[index],
                          style: TextStyle(
                            color: isActive
                                ? Colors.white
                                : const Color(0xFF4B5563),
                            fontWeight: isActive
                                ? FontWeight.bold
                                : FontWeight.w600,
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

            // Notification List
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _buildNotificationItem(
                    icon: Icons.local_shipping,
                    iconBgColor: const Color(0xFF03425F),
                    iconColor: Colors.white,
                    title: 'Đơn hàng #ZNZ-8492 đang được giao',
                    description:
                        'Đơn hàng của bạn đã được bàn giao cho đối tác vận chuyển và dự kiến giao trong ngày...',
                    time: '10 phút trước',
                    isUnread: true,
                  ),
                  _buildNotificationItem(
                    icon: Icons.local_offer,
                    iconBgColor: const Color(0xFFFFF7ED),
                    iconColor: const Color(0xFFEA580C),
                    title: 'Flash Sale: Giảm đến 50% đồ gia dụng',
                    description:
                        'Cơ hội sở hữu các sản phẩm gia dụng cao cấp với mức giá không tưởng. Mở app mua...',
                    time: '1 giờ trước',
                    isUnread: true,
                  ),
                  _buildNotificationItem(
                    icon: Icons.security,
                    iconBgColor: const Color(0xFFF3F4F6),
                    iconColor: const Color(0xFF4B5563),
                    title: 'Đăng nhập thành công từ thiết bị mới',
                    description:
                        'Tài khoản của bạn vừa đăng nhập thành công trên iPhone 14 Pro lúc 14:30. Nếu không phả...',
                    time: 'Hôm qua, 14:30',
                    isUnread: false,
                  ),
                  _buildNotificationItem(
                    icon: Icons.check_circle_rounded,
                    iconBgColor: const Color(0xFFF3F4F6),
                    iconColor: const Color(0xFF4B5563),
                    title: 'Giao hàng thành công',
                    description:
                        'Đơn hàng #ZNZ-8490 đã được giao thành công. Vui lòng đánh giá sản phẩm để nhận x...',
                    time: 'Hôm qua, 09:15',
                    isUnread: false,
                  ),
                  _buildNotificationItem(
                    icon: Icons.card_giftcard,
                    iconBgColor: const Color(0xFFF3F4F6),
                    iconColor: const Color(0xFF4B5563),
                    title: 'Tặng bạn Voucher 50K',
                    description:
                        'Mừng sinh nhật Zanzibar, tặng bạn voucher 50K áp dụng cho mọi đơn hàng từ 200K. Hạ...',
                    time: '20/11/2023',
                    isUnread: false,
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    required String description,
    required String time,
    required bool isUnread,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isUnread ? const Color(0xFFF0F7FA) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                    ),
                    if (isUnread) ...[
                      const SizedBox(width: 8),
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(top: 4),
                        decoration: const BoxDecoration(
                          color: Color(0xFF03425F),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  time,
                  style: const TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
