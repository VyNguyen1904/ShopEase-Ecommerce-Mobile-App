import 'package:flutter/material.dart';

class VariantSelectionGroup extends StatelessWidget {
  final String title;
  final List<String> items;
  final String? selectedItem;
  final ValueChanged<String?> onSelected;

  const VariantSelectionGroup({
    super.key,
    required this.title,
    required this.items,
    required this.selectedItem,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: items.map((item) {
            final isSelected = selectedItem == item;
            return ChoiceChip(
              label: Text(item),
              selected: isSelected,
              onSelected: (selected) {
                onSelected(selected ? item : null);
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
