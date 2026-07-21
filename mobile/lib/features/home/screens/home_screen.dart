import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/providers/product_provider.dart';
import '../widgets/home_product_card.dart';
import '../widgets/category_pill.dart';
import '../widgets/section_header.dart';
import '../widgets/home_search_header.dart';
import '../widgets/home_promo_carousel.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Search & Action Header
              const HomeSearchHeader(),

              // 2. Banner / Promotions
              const HomePromoCarousel(),
              const SizedBox(height: 30),

              // 3. Categories
              const SectionHeader(title: AppStrings.navCategory),
              const SizedBox(height: 12),
              SizedBox(
                height: 40,
                child: ref
                    .watch(categoriesProvider)
                    .when(
                      data: (categories) {
                        final selectedCat = ref.watch(
                          selectedCategoryHomeProvider,
                        );
                        return ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          itemCount: categories.length + 1,
                          separatorBuilder: (context, _) =>
                              const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              final isAll = selectedCat == null;
                              return GestureDetector(
                                onTap: () =>
                                    ref
                                            .read(
                                              selectedCategoryHomeProvider
                                                  .notifier,
                                            )
                                            .state =
                                        null,
                                child: CategoryPill(
                                  label: AppStrings.all,
                                  isActive: isAll,
                                ),
                              );
                            }
                            final cat = categories[index - 1];
                            final isActive = selectedCat == cat.name;
                            return GestureDetector(
                              onTap: () =>
                                  ref
                                      .read(
                                        selectedCategoryHomeProvider.notifier,
                                      )
                                      .state = cat
                                      .name,
                              child: CategoryPill(
                                label: cat.name,
                                isActive: isActive,
                              ),
                            );
                          },
                        );
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (err, stack) => const SizedBox(),
                    ),
              ),
              const SizedBox(height: 30),

              // 4. New arrivals
              const SectionHeader(title: AppStrings.newArrivals),
              const SizedBox(height: 12),
              SizedBox(
                height: 280,
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
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (err, stack) =>
                          Center(child: Text('${AppStrings.errorPrefix}$err')),
                    ),
              ),
              const SizedBox(height: 30),

              // 5. Gợi ý cho bạn
              const SectionHeader(title: AppStrings.recommendations),
              const SizedBox(height: 12),
              SizedBox(
                height: 280,
                child: ref
                    .watch(recommendationsProvider)
                    .when(
                      data: (products) => ListView.builder(
                        padding: const EdgeInsets.only(left: 20),
                        scrollDirection: Axis.horizontal,
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          return HomeProductCard(
                            product: products[index],
                            heroPrefix: 'rec',
                          );
                        },
                      ),
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (err, stack) =>
                          Center(child: Text('${AppStrings.errorPrefix}$err')),
                    ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
