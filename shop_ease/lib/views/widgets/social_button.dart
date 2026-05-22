import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class SocialButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const SocialButton({super.key, required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap ?? () {},
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 28, color: AppColors.primaryDark),
        ),
      ),
    );
  }
}
