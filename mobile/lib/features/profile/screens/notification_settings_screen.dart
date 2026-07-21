import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool _orderUpdates = true;
  bool _promotions = true;
  bool _chatMessages = true;
  bool _systemAlerts = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textDark),
        title: const Text(
          AppStrings.notificationSettings,
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        children: [
          _buildSwitchTile(
            title: 'Cập nhật đơn hàng',
            subtitle:
                'Thông báo về trạng thái giao hàng, đơn hàng thành công hoặc bị hủy.',
            value: _orderUpdates,
            onChanged: (val) => setState(() => _orderUpdates = val),
          ),
          const SizedBox(height: 16),
          _buildSwitchTile(
            title: 'Khuyến mãi & Ưu đãi',
            subtitle:
                'Nhận thông tin về các chương trình giảm giá, voucher mới nhất.',
            value: _promotions,
            onChanged: (val) => setState(() => _promotions = val),
          ),
          const SizedBox(height: 16),
          _buildSwitchTile(
            title: 'Tin nhắn Chat',
            subtitle:
                'Thông báo khi có tin nhắn mới từ cửa hàng hoặc khách hàng.',
            value: _chatMessages,
            onChanged: (val) => setState(() => _chatMessages = val),
          ),
          const SizedBox(height: 16),
          _buildSwitchTile(
            title: 'Cảnh báo hệ thống',
            subtitle:
                'Thông báo về bảo mật tài khoản và các thay đổi hệ thống quan trọng.',
            value: _systemAlerts,
            onChanged: (val) => setState(() => _systemAlerts = val),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            subtitle,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textGrey,
              height: 1.4,
            ),
          ),
        ),
        value: value,
        activeThumbColor: AppColors.primary,
        onChanged: onChanged,
      ),
    );
  }
}
