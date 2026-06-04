import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';

class SellerNotifications extends StatefulWidget {
  const SellerNotifications({super.key});

  @override
  State<SellerNotifications> createState() => _SellerNotificationsState();
}

class _ChatTabWithBadge {
  final String label;
  final int count;

  _ChatTabWithBadge(this.label, this.count);
}

class _SellerNotificationsState extends State<SellerNotifications> {
  String _activeTab = 'Tất cả';

  final List<_ChatTabWithBadge> _tabs = [
    _ChatTabWithBadge('Tất cả', 12),
    _ChatTabWithBadge('Đơn hàng', 6),
    _ChatTabWithBadge('Sản phẩm', 3),
    _ChatTabWithBadge('Khách hàng', 3),
    _ChatTabWithBadge('Hệ thống', 1),
  ];

  final List<Map<String, dynamic>> _notifications = [
    {
      'title': 'Đơn hàng mới',
      'tag': 'MỚI',
      'content': 'Bạn vừa có đơn hàng mới #DH2405190001\nTổng tiền 1.280.000đ',
      'time': '2 phút trước',
      'type': 'order',
      'unread': true,
    },
    {
      'title': 'Yêu cầu hoàn hàng',
      'content':
          'Đơn hàng #DH2405180002 đang được yêu cầu hoàn hàng bởi khách.',
      'time': '15 phút trước',
      'type': 'return',
      'unread': true,
    },
    {
      'title': 'Đánh giá mới',
      'content':
          'Nguyễn Văn An vừa đánh giá 5 sao cho sản phẩm Nike Air Max 270.',
      'time': '1 giờ trước',
      'type': 'review',
      'unread': true,
    },
    {
      'title': 'Sản phẩm sắp hết hàng',
      'content': 'Sản phẩm Adidas Ultraboost chỉ còn 5 sản phẩm trong kho.',
      'time': '2 giờ trước',
      'type': 'stock',
      'unread': true,
    },
    {
      'title': 'Đơn hàng đã giao',
      'content':
          'Đơn hàng #DH2405170003 đã được giao thành công cho khách hàng.',
      'time': '3 giờ trước',
      'type': 'delivered',
      'unread': false,
    },
    {
      'title': 'Thanh toán thành công',
      'content':
          'Bạn đã nhận được thanh toán cho đơn hàng #DH2405160004 qua Ví ShopeePay.',
      'time': '5 giờ trước',
      'type': 'payment',
      'unread': false,
    },
    {
      'title': 'Khách hàng mới',
      'content':
          'Bạn vừa có một khách hàng mới: Trần Thị Mai đã theo dõi cửa hàng của bạn.',
      'time': 'Hôm qua',
      'type': 'customer',
      'unread': false,
    },
    {
      'title': 'Cập nhật từ hệ thống',
      'content':
          'Phí vận chuyển sẽ được cập nhật từ ngày 01/06/2024. Vui lòng kiểm tra chi tiết.',
      'time': '2 ngày trước',
      'type': 'system',
      'unread': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Thông báo',
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.settings_outlined,
              color: AppColors.textDark,
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // 1. Horizontal Scrollable Tabs with Red Badges
          Container(
            height: 48,
            padding: const EdgeInsets.only(left: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _tabs.length,
              itemBuilder: (context, index) {
                final tab = _tabs[index];
                final isSelected = _activeTab == tab.label;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _activeTab = tab.label;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 20),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: isSelected
                              ? AppColors.primary
                              : Colors.transparent,
                          width: 2.5,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          tab.label,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w500,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textGrey,
                          ),
                        ),
                        const SizedBox(width: 6),
                        // Tab Badge Count
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.alertRed,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${tab.count}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1, color: AppColors.border),

          // 2. Notification list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final note = _notifications[index];
                return _buildNotificationTile(note);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationTile(Map<String, dynamic> note) {
    IconData icon;
    Color iconColor;
    Color iconBg;

    switch (note['type']) {
      case 'order':
        icon = Icons.shopping_cart_outlined;
        iconColor = AppColors.iconGreen;
        iconBg = const Color(0xFFEAF8EE);
        break;
      case 'return':
        icon = Icons.assignment_return_outlined;
        iconColor = AppColors.accent;
        iconBg = const Color(0xFFFFF2EE);
        break;
      case 'review':
        icon = Icons.star_outline;
        iconColor = const Color(0xFF3B82F6);
        iconBg = const Color(0xFFECEFFF);
        break;
      case 'stock':
        icon = Icons.warning_amber_outlined;
        iconColor = AppColors.accent;
        iconBg = const Color(0xFFFFF2EE);
        break;
      case 'delivered':
        icon = Icons.local_shipping_outlined;
        iconColor = const Color(0xFF8B5CF6);
        iconBg = const Color(0xFFF5F3FF);
        break;
      case 'payment':
        icon = Icons.account_balance_wallet_outlined;
        iconColor = AppColors.iconGreen;
        iconBg = const Color(0xFFEAF8EE);
        break;
      case 'customer':
        icon = Icons.person_add_alt_1_outlined;
        iconColor = const Color(0xFFEC4899);
        iconBg = const Color(0xFFFDF2F8);
        break;
      case 'system':
      default:
        icon = Icons.volume_up_outlined;
        iconColor = const Color(0xFF3B82F6);
        iconBg = const Color(0xFFECEFFF);
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.01),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            // Text Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            note['title'],
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                          if (note['tag'] != null) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFECE5),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                note['tag'],
                                style: const TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.accent,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      Text(
                        note['time'],
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    note['content'],
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textGrey,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            if (note['unread']) ...[
              const SizedBox(width: 8),
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.iconGreen,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
