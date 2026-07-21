import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';

class MapSearchBar extends StatelessWidget {
  final TextEditingController searchController;
  final List<dynamic> searchResults;
  final Function(String) onChanged;
  final Function(String) onSubmitted;
  final VoidCallback onClear;
  final Function(dynamic) onResultSelected;

  const MapSearchBar({
    super.key,
    required this.searchController,
    required this.searchResults,
    required this.onChanged,
    required this.onSubmitted,
    required this.onClear,
    required this.onResultSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 10,
      left: 16,
      right: 16,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: AppStrings.searchAddressHint,
                border: InputBorder.none,
                prefixIcon: const Icon(Icons.search, color: AppColors.textGrey),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear, color: AppColors.textGrey),
                  onPressed: onClear,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 15),
              ),
              onChanged: onChanged,
              onSubmitted: onSubmitted,
            ),
          ),
          if (searchResults.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 10),
                ],
              ),
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: searchResults.length,
                itemBuilder: (context, index) {
                  final result = searchResults[index];
                  return ListTile(
                    leading: const Icon(
                      Icons.location_city,
                      color: AppColors.textGrey,
                    ),
                    title: Text(
                      result['display_name'],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13),
                    ),
                    onTap: () => onResultSelected(result),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
