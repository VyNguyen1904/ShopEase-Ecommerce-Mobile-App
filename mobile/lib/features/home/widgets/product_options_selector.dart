import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class ProductOptionsSelector extends StatefulWidget {
  final List<String> sizes;

  const ProductOptionsSelector({super.key, required this.sizes});

  @override
  State<ProductOptionsSelector> createState() => _ProductOptionsSelectorState();
}

class _ProductOptionsSelectorState extends State<ProductOptionsSelector> {
  int _selectedColorIndex = 1;
  String _selectedSize = '9';

  final List<Map<String, dynamic>> _colorOptions = [
    {'name': 'Trắng', 'color': Colors.white, 'hasBorder': true},
    {'name': 'Xanh Ngọc', 'color': AppColors.primary, 'hasBorder': false},
    {'name': 'Đen', 'color': Colors.black, 'hasBorder': false},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.sizes.isNotEmpty) {
      _selectedSize = widget.sizes.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Màu sắc: ${_colorOptions[_selectedColorIndex]['name']}',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(
              _colorOptions.length,
              (index) => GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedColorIndex = index;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  margin: const EdgeInsets.only(right: 12),
                  width: _selectedColorIndex == index ? 42 : 38,
                  height: _selectedColorIndex == index ? 42 : 38,
                  decoration: BoxDecoration(
                    color: _colorOptions[index]['color'],
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _selectedColorIndex == index
                          ? AppColors.primary
                          : (_colorOptions[index]['hasBorder']
                              ? AppColors.border
                              : Colors.transparent),
                      width: _selectedColorIndex == index ? 3.0 : 1,
                    ),
                    boxShadow: _selectedColorIndex == index
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: _selectedColorIndex == index
                        ? Icon(
                            Icons.check,
                            key: const ValueKey('checked'),
                            color: _colorOptions[index]['color'] == Colors.white
                                ? AppColors.primary
                                : Colors.white,
                            size: 20,
                          )
                        : const SizedBox.shrink(key: ValueKey('empty')),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Kích thước',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: widget.sizes.map((size) {
              final isSelected = _selectedSize == size;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedSize = size;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  margin: const EdgeInsets.only(right: 12),
                  width: isSelected ? 48 : 42,
                  height: isSelected ? 48 : 42,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.accent : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? AppColors.accent : AppColors.border,
                      width: 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.accent.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    size,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : AppColors.textDark,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}
