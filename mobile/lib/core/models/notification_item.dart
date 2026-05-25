enum NotificationType { order, promotion, voucher, message, system }

class NotificationItem {
  final String id;
  final String title;
  final String content;
  final String time;
  final String group; // 'Hôm nay', 'Hôm qua', 'Trước đó'
  final NotificationType type;
  final bool isUnread;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.content,
    required this.time,
    required this.group,
    required this.type,
    this.isUnread = false,
  });
}

// Mock notifications matching the Common_Sceen/1.png design
final List<NotificationItem> mockNotifications = [
  NotificationItem(
    id: 'n1',
    title: 'Đơn hàng đã được giao',
    content:
        'Đơn hàng #SE2405150001 của bạn đã được giao thành công. Cảm ơn bạn đã mua sắm!',
    time: '10:30 AM',
    group: 'Hôm nay',
    type: NotificationType.order,
    isUnread: true,
  ),
  NotificationItem(
    id: 'n2',
    title: 'Đơn hàng đang được vận chuyển',
    content: 'Đơn hàng #SE2405180005 của bạn đang trên đường giao đến bạn.',
    time: '09:15 AM',
    group: 'Hôm nay',
    type: NotificationType.order,
    isUnread: false,
  ),
  NotificationItem(
    id: 'n3',
    title: 'ShopEase Official đã trả lời bạn',
    content:
        'ShopEase Official: Cảm ơn bạn đã liên hệ! Chúng tôi sẽ hỗ trợ bạn sớm nhất.',
    time: '08:45 AM',
    group: 'Hôm nay',
    type: NotificationType.message,
    isUnread: true,
  ),
  NotificationItem(
    id: 'n4',
    title: 'Flash Sale sắp diễn ra!',
    content: 'Flash Sale 6.6 bắt đầu sau 2 giờ nữa. Săn deal cực sốc lên đến 70%!',
    time: '08:00 AM',
    group: 'Hôm nay',
    type: NotificationType.promotion,
    isUnread: false,
  ),
  NotificationItem(
    id: 'n5',
    title: 'Bạn có voucher mới!',
    content: 'Nhận ngay mã giảm 50K cho đơn từ 500K. Áp dụng đến 10/06/2024.',
    time: 'Hôm qua',
    group: 'Hôm qua',
    type: NotificationType.voucher,
    isUnread: true,
  ),
  NotificationItem(
    id: 'n6',
    title: 'Sản phẩm bạn yêu thích đang giảm giá',
    content: 'Nike Air Max 270 đang giảm 15% chỉ trong hôm nay. Đừng bỏ lỡ!',
    time: 'Hôm qua',
    group: 'Hôm qua',
    type: NotificationType.promotion,
    isUnread: false,
  ),
  NotificationItem(
    id: 'n7',
    title: 'Cập nhật chính sách bảo mật',
    content: 'Chúng tôi đã cập nhật chính sách bảo mật. Xem chi tiết tại đây.',
    time: '06/05/2024',
    group: 'Trước đó',
    type: NotificationType.system,
    isUnread: false,
  ),
  NotificationItem(
    id: 'n8',
    title: 'Chào mừng đến với ShopEase!',
    content:
        'Cảm ơn bạn đã đăng ký tài khoản. Bắt đầu mua sắm ngay nhé!',
    time: '05/05/2024',
    group: 'Trước đó',
    type: NotificationType.system,
    isUnread: false,
  ),
];
