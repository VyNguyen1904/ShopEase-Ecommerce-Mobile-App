import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class AccountMenuGroup extends StatelessWidget {
  final List<Widget> children;

  const AccountMenuGroup({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Column(
          children: children.asMap().entries.map((entry) {
            final int index = entry.key;
            final Widget item = entry.value;
            if (index != children.length - 1) {
              return Column(
                children: [
                  item,
                  const Divider(
                    height: 1,
                    indent: 56,
                    endIndent: 20,
                    color: AppColors.border,
                  ),
                ],
              );
            }
            return item;
          }).toList(),
        ),
      ),
    );
  }
}
