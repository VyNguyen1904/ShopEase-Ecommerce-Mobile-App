import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/providers/product_provider.dart';
import '../widgets/home_product_card.dart';
import '../widgets/promo_card.dart';
import '../widgets/category_pill.dart';
import '../widgets/home_icon_button.dart';
import '../../../core/providers/notification_provider.dart';
import '../widgets/section_header.dart';

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
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => context.push(AppRoutes.search),
                        child: Container(
                          height: 48,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: AppColors.bgLight,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.search,
                                color: AppColors.textLight,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  AppStrings.searchHomeHint,
                                  style: TextStyle(
                                    color: AppColors.textLight,
                                    fontSize: 14,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ref.watch(unreadNotificationCountProvider).when(
                      data: (count) => HomeIconButton(
                        icon: Icons.notifications_outlined,
                        onTap: () => context.push(AppRoutes.notifications),
                        showBadge: count > 0,
                      ),
                      loading: () => HomeIconButton(
                        icon: Icons.notifications_outlined,
                        onTap: () => context.push(AppRoutes.notifications),
                        showBadge: false,
                      ),
                      error: (_, __) => HomeIconButton(
                        icon: Icons.notifications_outlined,
                        onTap: () => context.push(AppRoutes.notifications),
                        showBadge: false,
                      ),
                    ),
                    const SizedBox(width: 10),
                    HomeIconButton(
                      icon: Icons.chat_bubble_outline,
                      onTap: () => context.push(AppRoutes.chats),
                      showBadge: false,
                    ),
                    const SizedBox(width: 10),
                    HomeIconButton(icon: Icons.qr_code_scanner, onTap: () {}),
                  ],
                ),
              ),

              // 2. Banner / Promotions
              SizedBox(
                height: 250,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    PromoCard(
                      title: AppStrings.promo1Title,
                      subtitle: AppStrings.promo1Subtitle,
                      description: AppStrings.promo1Desc,
                      buttonText: AppStrings.buyNow,
                      image:
                          'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?auto=format&fit=crop&q=80&w=400',
                      color: const Color(0xFF1A1A1A), // Đen tuyền sang trọng
                    ),
                    const SizedBox(width: 16),
                    PromoCard(
                      title: AppStrings.promo2Title,
                      subtitle: AppStrings.promo2Subtitle,
                      description: AppStrings.promo2Desc,
                      buttonText: AppStrings.viewCollection,
                      image:
                          'https://images.unsplash.com/photo-1544441893-675973e31985?auto=format&fit=crop&q=80&w=400',
                      color: const Color(0xFF4A3E3D), // Nâu tây sang trọng
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // 3. Categories
              const SectionHeader(title: AppStrings.navCategory),
              const SizedBox(height: 12),
              SizedBox(
                height: 40,
                child: ref.watch(categoriesProvider).when(
                      data: (categories) {
                        final selectedCat = ref.watch(selectedCategoryHomeProvider);
                        return ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          itemCount: categories.length + 1,
                          separatorBuilder: (context, _) => const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              final isAll = selectedCat == null;
                              return GestureDetector(
                                onTap: () => ref.read(selectedCategoryHomeProvider.notifier).state = null,
                                child: CategoryPill(label: AppStrings.all, isActive: isAll),
                              );
                            }
                            final cat = categories[index - 1];
                            final isActive = selectedCat == cat.name;
                            return GestureDetector(
                              onTap: () => ref.read(selectedCategoryHomeProvider.notifier).state = cat.name,
                              child: CategoryPill(label: cat.name, isActive: isActive),
                            );
                          },
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
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
                      error: (err, stack) => Center(child: Text('${AppStrings.errorPrefix}$err')),
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
                      error: (err, stack) => Center(child: Text('${AppStrings.errorPrefix}$err')),
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
