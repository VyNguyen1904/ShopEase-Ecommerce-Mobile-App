import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class AccountSectionTitle extends StatelessWidget {
  final String title;

  const AccountSectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: AppColors.textGrey,
      ),
    );
  }
}
