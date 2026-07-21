import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class SettingsItemTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? trailingText;
  final VoidCallback onTap;
  final bool showChevronDown;

  const SettingsItemTile({
    super.key,
    required this.icon,
    required this.title,
    this.trailingText,
    required this.onTap,
    this.showChevronDown = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
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
              if (trailingText != null) ...[
                Text(
                  trailingText!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textGrey,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Icon(
                showChevronDown
                    ? Icons.keyboard_arrow_down
                    : Icons.chevron_right,
                color: AppColors.textLight,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
