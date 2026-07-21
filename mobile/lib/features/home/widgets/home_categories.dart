import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/providers/product_provider.dart';
import 'section_title.dart';

class HomeCategories extends ConsumerWidget {
  const HomeCategories({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        SectionTitle(
          title: 'Danh mục',
          onViewAll: () => context.go(AppRoutes.category),
        ),
        const SizedBox(height: 12),
        ref
            .watch(categoriesProvider)
            .when(
              data: (categories) {
                if (categories.isEmpty) return const SizedBox();
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    children: categories.map((cat) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 12.0),
                        child: GestureDetector(
                          onTap: () => context.go(AppRoutes.category),
                          child: _buildCategoryPill(
                            cat.name,
                            isActive: cat.id == categories.first.id,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => const SizedBox(),
            ),
      ],
    );
  }

  Widget _buildCategoryPill(String label, {bool isActive = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isActive ? Colors.transparent : Colors.grey.shade300,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : [],
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isActive ? Colors.black : Colors.black87,
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      ),
    );
  }
}
