import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/product.dart';
import '../../../core/widgets/product_card.dart';
import '../widgets/seller_stats_card.dart';

class SellerShopProfile extends StatefulWidget {
  const SellerShopProfile({super.key});

  @override
  State<SellerShopProfile> createState() => _SellerShopProfileState();
}

class _SellerShopProfileState extends State<SellerShopProfile>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Product> _featuredProducts = [
    Product(
      id: '1',
      name: 'Nike Air Max 270',
      price: 160.00,
      originalPrice: 200.00,
      imageUrl:
          'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400&auto=format&fit=crop&q=80',
      category: 'Giày Nam',
      rating: 4.8,
      reviewsCount: 172,
      salesCount: 256,
      colors: [0xFF000000, 0xFFFFFFFF, 0xFFFF0000],
      sizes: ['7', '8', '9', '10', '11'],
      description: 'Giày Nike Air Max 270 chính hãng',
    ),
    Product(
      id: '2',
      name: 'Adidas Ultraboost',
      price: 160.00,
      originalPrice: 180.00,
      imageUrl:
          'https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?w=400&auto=format&fit=crop&q=80',
      category: 'Giày Nam',
      rating: 4.9,
      reviewsCount: 210,
      salesCount: 340,
      colors: [0xFF000000, 0xFFFFFFFF],
      sizes: ['8', '9', '10'],
      description: 'Giày Adidas Ultraboost chính hãng',
    ),
    Product(
      id: '3',
      name: 'Puma RS-X',
      price: 160.00,
      originalPrice: 200.00,
      imageUrl:
          'https://images.unsplash.com/photo-1552346154-21d32810aba3?w=400&auto=format&fit=crop&q=80',
      category: 'Giày Nam',
      rating: 4.7,
      reviewsCount: 150,
      salesCount: 200,
      colors: [0xFF000000, 0xFFFFFFFF],
      sizes: ['7', '8', '9'],
      description: 'Giày Puma RS-X chính hãng',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Custom dark background color matching the design
    const Color headerColor = Color(0xFF044851);

    return Scaffold(
      backgroundColor: Colors.white,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              backgroundColor: headerColor,
              expandedHeight: 280,
              pinned: true,
              leading: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                onPressed: () => context.pop(),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 40,
                      left: 20,
                      right: 20,
                      bottom: 60,
                    ),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Avatar
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.iconTeal,
                                  width: 2,
                                ),
                                image: const DecorationImage(
                                  image: NetworkImage(
                                    'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=200&auto=format&fit=crop&q=80',
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Name and Status
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Sneaker House',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: AppColors.iconGreen,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      const Text(
                                        'Online 2 giờ trước',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Ratings & Followers
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              '4.9',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const Text(
                              ' (2.3k đánh giá)',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Container(
                              width: 1,
                              height: 16,
                              color: Colors.white24,
                            ),
                            const SizedBox(width: 16),
                            const Icon(
                              Icons.people_alt,
                              color: Colors.white70,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              '2.3k',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const Text(
                              ' Người theo dõi',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Action Buttons
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.add, size: 18),
                                label: const Text('Theo dõi'),
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: headerColor,
                                  side: const BorderSide(color: Colors.white),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {},
                                icon: const Icon(
                                  Icons.chat_bubble_outline,
                                  size: 18,
                                ),
                                label: const Text('Chat'),
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: headerColor,
                                  side: const BorderSide(color: Colors.white),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: Container(
                  color: Colors.white,
                  child: TabBar(
                    controller: _tabController,
                    indicatorColor: AppColors.primary,
                    indicatorWeight: 3,
                    labelColor: AppColors.primary,
                    unselectedLabelColor: AppColors.textGrey,
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 14,
                    ),
                    tabs: const [
                      Tab(text: 'Shop'),
                      Tab(text: 'Sản phẩm'),
                      Tab(text: 'Danh mục'),
                      Tab(text: 'Đánh giá'),
                    ],
                  ),
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildShopTab(),
            const Center(child: Text('Sản phẩm')),
            const Center(child: Text('Danh mục')),
            const Center(child: Text('Đánh giá')),
          ],
        ),
      ),
    );
  }

  Widget _buildShopTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Giới thiệu shop
          const Text(
            'Giới thiệu shop',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.verified_outlined,
                size: 20,
                color: AppColors.textGrey,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Chuyên nhập và kinh doanh giày chính hãng',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textGrey,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: const [
              Icon(
                Icons.calendar_today_outlined,
                size: 20,
                color: AppColors.textGrey,
              ),
              SizedBox(width: 8),
              Text(
                'Tham gia từ 09/2022',
                style: TextStyle(fontSize: 14, color: AppColors.textGrey),
              ),
            ],
          ),

          // Stats Card
          const SellerStatsCard(),
          const SizedBox(height: 32),

          // Sản phẩm nổi bật
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Sản phẩm nổi bật',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              GestureDetector(
                onTap: () {
                  _tabController.animateTo(1); // Chuyển sang tab Sản phẩm
                },
                child: Row(
                  children: const [
                    Text(
                      'Xem tất cả',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      size: 18,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Horizontal Product List
          SizedBox(
            height: 240, // Height for vertical ProductCard
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _featuredProducts.length,
              itemBuilder: (context, index) {
                final product = _featuredProducts[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: SizedBox(
                    width: 160,
                    child: ProductCard(
                      product: product,
                      heroTag: 'featured_${product.id}',
                      onTap: () {
                        context.push('/product/${product.id}');
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
