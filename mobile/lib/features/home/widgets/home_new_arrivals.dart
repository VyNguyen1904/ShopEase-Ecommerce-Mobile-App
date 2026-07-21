import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/product_provider.dart';
import 'home_product_card.dart';
import 'section_title.dart';
import '../../../core/constants/app_strings.dart';

class HomeNewArrivals extends ConsumerWidget {
  const HomeNewArrivals({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        const SectionTitle(title: 'Hàng mới về'),
        const SizedBox(height: 12),
        SizedBox(
          height: 310,
          child: ref
              .watch(newArrivalsProvider)
              .when(
                data: (products) => ListView.builder(
                  padding: const EdgeInsets.only(left: 20),
                  scrollDirection: Axis.horizontal,
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    return HomeProductCard(
                      product: products[index],
                      heroPrefix: 'new',
                      showDiscount: false,
                    );
                  },
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) =>
                    Center(child: Text('${AppStrings.errorPrefix}$err')),
              ),
        ),
      ],
    );
  }
}
