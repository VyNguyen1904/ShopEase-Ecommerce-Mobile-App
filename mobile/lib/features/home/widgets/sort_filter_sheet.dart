import 'package:flutter/material.dart';
import '../../../core/constants/app_strings.dart';

class SortFilterSheet extends StatefulWidget {
  final String currentSortBy;
  final String currentSortDir;
  final Function(String sortBy, String sortDir) onApply;

  const SortFilterSheet({
    super.key,
    required this.currentSortBy,
    required this.currentSortDir,
    required this.onApply,
  });

  @override
  State<SortFilterSheet> createState() => _SortFilterSheetState();
}

class _SortFilterSheetState extends State<SortFilterSheet> {
  late String sortBy;
  late String sortDir;

  @override
  void initState() {
    super.initState();
    sortBy = widget.currentSortBy;
    sortDir = widget.currentSortDir;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Sắp xếp theo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 16),
          _buildRadio('createdAt', 'desc', 'Mới nhất'),
          _buildRadio('price', 'asc', 'Giá thấp đến cao'),
          _buildRadio('price', 'desc', 'Giá cao đến thấp'),
          _buildRadio('soldCount', 'desc', 'Bán chạy nhất'),
          _buildRadio('avgRating', 'desc', 'Đánh giá cao nhất'),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                widget.onApply(sortBy, sortDir);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text(AppStrings.apply),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildRadio(String by, String dir, String label) {
    return RadioListTile<String>(
      title: Text(label),
      value: '${by}_$dir',
      groupValue: '${sortBy}_$sortDir',
      onChanged: (value) {
        setState(() {
          sortBy = by;
          sortDir = dir;
        });
      },
    );
  }
}
