import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/product_provider.dart';
import 'home_product_card.dart';
import 'section_title.dart';
import '../../../core/constants/app_strings.dart';

class HomeRecommendations extends ConsumerWidget {
  const HomeRecommendations({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        const SectionTitle(title: 'Gợi ý cho bạn'),
        const SizedBox(height: 12),
        SizedBox(
          height: 310,
          child: ref.watch(recommendationsProvider).when(
            data: (products) => ListView.builder(
              padding: const EdgeInsets.only(left: 20),
              scrollDirection: Axis.horizontal,
              itemCount: products.length,
              itemBuilder: (context, index) {
                return HomeProductCard(
                  ref: ref,
                  product: products[index],
                  heroPrefix: 'rec',
                );
              },
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('${AppStrings.errorPrefix}$err')),
          ),
        ),
      ],
    );
  }
}
