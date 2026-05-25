import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class SettingsScreen extends StatelessWidget {
  final VoidCallback onBack;

  const SettingsScreen({super.key, required this.onBack});

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
          onPressed: onBack,
        ),
        title: const Text(
          'Cài đặt',
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section: Chung
            _buildSectionHeader('Chung'),
            _buildSettingsTile(
              icon: Icons.language,
              title: 'Ngôn ngữ',
              trailingText: 'Tiếng Việt',
              onTap: () {},
            ),
            _buildDivider(),
            _buildSettingsTile(
              icon: Icons.monetization_on_outlined,
              title: 'Đơn vị tiền tệ',
              trailingText: 'VND (đ)',
              onTap: () {},
            ),
            _buildDivider(),
            _buildSettingsTile(
              icon: Icons.palette_outlined,
              title: 'Giao diện',
              trailingText: 'Sáng',
              onTap: () {},
              showChevronDown: true,
            ),

            const SizedBox(height: 16),

            // Section: Hỗ trợ
            _buildSectionHeader('Hỗ trợ'),
            _buildSettingsTile(
              icon: Icons.help_outline,
              title: 'Trung tâm trợ giúp',
              onTap: () {},
            ),
            _buildDivider(),
            _buildSettingsTile(
              icon: Icons.description_outlined,
              title: 'Điều khoản & điều kiện',
              onTap: () {},
            ),
            _buildDivider(),
            _buildSettingsTile(
              icon: Icons.security_outlined,
              title: 'Chính sách bảo mật',
              onTap: () {},
            ),
            _buildDivider(),
            _buildSettingsTile(
              icon: Icons.info_outline,
              title: 'Giới thiệu ứng dụng',
              trailingText: 'Phiên bản 1.0.0',
              onTap: () {},
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.textGrey,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? trailingText,
    required VoidCallback onTap,
    bool showChevronDown = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              // Icon with circular container
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFFF1FAF9),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 16),
              // Title text
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              // Trailing block
              if (trailingText != null) ...[
                Text(
                  trailingText,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textGrey,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Icon(
                showChevronDown ? Icons.keyboard_arrow_down : Icons.chevron_right,
                color: AppColors.textLight,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.0),
      child: Divider(height: 1, color: AppColors.border),
    );
  }
}
