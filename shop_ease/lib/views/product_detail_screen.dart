import 'package:flutter/material.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _currentImageIndex = 0;
  int _selectedColorIndex = 0;

  final List<String> _images = [
    'https://images.unsplash.com/photo-1618366712010-f4ae9c647dcb?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1546435770-a3e426bf472b?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1583394838336-acd977736f90?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1523275335684-37898b6baf30?auto=format&fit=crop&w=800&q=80',
  ];

  final List<Color> _colors = [
    const Color(0xFF1F2937), // Black
    const Color(0xFFF3F4F6), // White/Silver
    const Color(0xFF1E3A8A), // Navy Blue
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2937)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border_rounded, color: Color(0xFF1F2937)),
            onPressed: () {},
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Carousel
            Stack(
              children: [
                SizedBox(
                  height: 380,
                  width: double.infinity,
                  child: PageView.builder(
                    itemCount: _images.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentImageIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return Image.network(
                        _images[index],
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ),
                Positioned(
                  bottom: 16,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _images.length,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentImageIndex == index ? 8 : 6,
                        height: _currentImageIndex == index ? 8 : 6,
                        decoration: BoxDecoration(
                          color: _currentImageIndex == index
                              ? const Color(0xFF1F2937)
                              : Colors.grey.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  const Text(
                    'Tai nghe chống ồn Sony WH-1000XM5',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Ratings
                  Row(
                    children: [
                      Row(
                        children: List.generate(5, (index) => const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 16)),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        '4.8 (1,245 đánh giá)',
                        style: TextStyle(color: Color(0xFF6B7280), fontSize: 13),
                      ),
                      const SizedBox(width: 12),
                      Container(width: 4, height: 4, decoration: const BoxDecoration(color: Color(0xFFD1D5DB), shape: BoxShape.circle)),
                      const SizedBox(width: 12),
                      const Text(
                        'Đã bán 5.2k',
                        style: TextStyle(color: Color(0xFF6B7280), fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Price
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        '7.990.000đ',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFDC2626),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        '9.500.000đ',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF9CA3AF),
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          '-16%',
                          style: TextStyle(
                            color: Color(0xFFDC2626),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  const Divider(color: Color(0xFFF3F4F6), thickness: 1),
                  const SizedBox(height: 16),

                  // Colors
                  Row(
                    children: [
                      const Text(
                        'Màu sắc:',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF374151)),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _selectedColorIndex == 0 ? 'Đen' : (_selectedColorIndex == 1 ? 'Bạc' : 'Xanh'),
                        style: const TextStyle(fontSize: 15, color: Color(0xFF1F2937)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: List.generate(
                      _colors.length,
                      (index) => GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedColorIndex = index;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _selectedColorIndex == index ? const Color(0xFF2E6582) : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: _colors[index],
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.black.withValues(alpha: 0.1), width: 1),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Divider(color: Color(0xFFF3F4F6), thickness: 1),
                  const SizedBox(height: 16),

                  // Product details text
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'Chi tiết sản phẩm',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                      ),
                      Row(
                        children: [
                          Text('Xem thêm', style: TextStyle(color: Color(0xFF2E6582), fontSize: 13, fontWeight: FontWeight.w500)),
                          Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF2E6582), size: 16),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Tai nghe chống ồn Sony WH-1000XM5 với 2 bộ xử lý điều khiển 8 micrô giúp khả năng chống ồn vượt trội chưa từng có và chất lượng cuộc gọi vượt trội. Thiết...',
                    style: TextStyle(fontSize: 14, color: Color(0xFF4B5563), height: 1.5),
                  ),
                  const SizedBox(height: 12),
                  _buildDetailBullet('Chống ồn cực đỉnh với Auto NC Optimizer'),
                  _buildDetailBullet('Thời lượng pin lên đến 30 giờ'),
                  _buildDetailBullet('Sạc nhanh 3 phút sạc cho 3 giờ phát'),
                  
                  const SizedBox(height: 24),
                  const Divider(color: Color(0xFFF3F4F6), thickness: 1),
                  const SizedBox(height: 16),

                  // Reviews
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'Đánh giá khách hàng',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                      ),
                      Row(
                        children: [
                          Text('Xem tất cả (1,245)', style: TextStyle(color: Color(0xFF2E6582), fontSize: 13, fontWeight: FontWeight.w500)),
                          Icon(Icons.chevron_right_rounded, color: Color(0xFF2E6582), size: 16),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Single Review Item
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CircleAvatar(
                        radius: 16,
                        backgroundImage: NetworkImage('https://images.unsplash.com/photo-1599566150163-29194dcaad36?auto=format&fit=crop&w=100&q=80'),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Text('Nguyễn Văn A', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                                Text('7 ngày trước', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 12)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: List.generate(5, (index) => const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 14)),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Chống ồn cực kỳ tốt, đeo lâu không bị đau tai. Đáng đồng tiền bát gạo! Giao hàng siêu nhanh.',
                              style: TextStyle(fontSize: 13, color: Color(0xFF4B5563), height: 1.4),
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                'https://images.unsplash.com/photo-1618366712010-f4ae9c647dcb?auto=format&fit=crop&w=200&q=80',
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),

                  const SizedBox(height: 30),
                  const Text(
                    'Sản phẩm tương tự',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                  ),
                  const SizedBox(height: 16),
                  
                  // Similar Products Horizontal List
                  SizedBox(
                    height: 180,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      children: [
                        _buildSimilarProduct('Sony WH-CH720N', '2.990.000đ', 'https://images.unsplash.com/photo-1546435770-a3e426bf472b?auto=format&fit=crop&w=300&q=80'),
                        _buildSimilarProduct('Bose QuietComfort', '8.490.000đ', 'https://images.unsplash.com/photo-1583394838336-acd977736f90?auto=format&fit=crop&w=300&q=80'),
                        _buildSimilarProduct('Sennheiser Momentum', '8.990.000đ', 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?auto=format&fit=crop&w=300&q=80'),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: 80, // Fixed height for bottom nav
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE5E7EB)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.chat_outlined, color: Color(0xFF4B5563), size: 24),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF2E6582)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: const [
                  Icon(Icons.add_shopping_cart_rounded, color: Color(0xFF2E6582), size: 20),
                  SizedBox(width: 6),
                  Text(
                    'Thêm vào giỏ',
                    style: TextStyle(color: Color(0xFF2E6582), fontWeight: FontWeight.bold, fontSize: 13),
                  )
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF97316),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    'Mua ngay',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDetailBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: CircleAvatar(radius: 2, backgroundColor: Color(0xFF9CA3AF)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimilarProduct(String name, String price, String imageUrl) {
    return Container(
      width: 130,
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 130,
            width: 130,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(imageUrl, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF1F2937)),
          ),
          const SizedBox(height: 4),
          Text(
            price,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFFDC2626)),
          ),
        ],
      ),
    );
  }
}
