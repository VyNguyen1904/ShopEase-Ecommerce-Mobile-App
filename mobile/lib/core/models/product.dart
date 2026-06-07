class Product {
  final String id;
  final String name;
  final String category;
  final double price;
  final double? originalPrice;
  final String imageUrl;
  final double rating;
  final int reviewsCount;
  final int salesCount;
  final List<String> sizes;
  final List<int> colors; // List of ARGB hex values
  final String description;

  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    this.originalPrice,
    required this.imageUrl,
    required this.rating,
    required this.reviewsCount,
    required this.salesCount,
    required this.sizes,
    required this.colors,
    required this.description,
  });

  int get discountPercentage {
    if (originalPrice == null || originalPrice! <= price) return 0;
    return (((originalPrice! - price) / originalPrice!) * 100).round();
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    String extractImageUrl() {
      if (json['imageUrls'] != null && (json['imageUrls'] as List).isNotEmpty) {
        return json['imageUrls'][0].toString();
      } else if (json['images'] != null && (json['images'] as List).isNotEmpty) {
        return json['images'][0].toString();
      }
      return 'https://via.placeholder.com/600';
    }

    String categoryName = 'Chưa phân loại';
    if (json['category'] != null) {
      if (json['category'] is String) {
        categoryName = json['category'];
      } else if (json['category'] is Map && json['category']['name'] != null) {
        categoryName = json['category']['name'];
      }
    }

    double basePrice = (json['basePrice'] ?? json['price'] ?? 0.0).toDouble();
    double? salePrice = json['salePrice'] != null ? (json['salePrice']).toDouble() : null;
    
    double finalPrice = salePrice ?? basePrice;
    double? origPrice = salePrice != null ? basePrice : (json['originalPrice'] != null ? (json['originalPrice']).toDouble() : null);

    return Product(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      category: categoryName,
      price: finalPrice,
      originalPrice: origPrice,
      imageUrl: extractImageUrl(),
      rating: (json['avgRating'] ?? json['rating'] ?? 5.0).toDouble(),
      reviewsCount: json['reviewCount'] ?? json['reviewsCount'] ?? 0,
      salesCount: json['soldCount'] ?? json['salesCount'] ?? 0,
      sizes: json['sizes'] != null ? List<String>.from(json['sizes']) : ['Mặc định'],
      colors: [0xFF000000],
      description: json['description'] ?? '',
    );
  }
}

final List<Product> mockProducts = [
  Product(
    id: 'p1',
    name: 'Nike Air Max 270',
    category: 'Giày Nam',
    price: 3160000,
    originalPrice: 3950000,
    imageUrl:
        'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=600&auto=format&fit=crop&q=80',
    rating: 4.8,
    reviewsCount: 122,
    salesCount: 254,
    sizes: ['7', '8', '9', '10', '11'],
    colors: [0xFFFFFFFF, 0xFF0A6F75, 0xFF000000],
    description:
        'Giày Nike Air Max 270 mang lại sự thoải mái tối đa nhờ túi khí Max Air lớn nhất ở gót chân từ trước đến nay. Phối màu Trắng - Xanh Ngọc trẻ trung, hiện đại, thích hợp cho cả hoạt động thể thao và dạo phố hàng ngày.',
  ),
  Product(
    id: 'p2',
    name: 'Adidas Ultraboost',
    category: 'Giày Nam',
    price: 3160000,
    originalPrice: 3950000,
    imageUrl:
        'https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?w=600&auto=format&fit=crop&q=80',
    rating: 4.9,
    reviewsCount: 140,
    salesCount: 310,
    sizes: ['7', '8', '9', '10', '11'],
    colors: [0xFF000000, 0xFFFF3B30, 0xFFFFFFFF],
    description:
        'Adidas Ultraboost cung cấp sự đàn hồi vượt trội nhờ đệm Boost trứ danh. Thân giày Primeknit ôm sát bàn chân giúp di chuyển tự nhiên và thông thoáng.',
  ),
  Product(
    id: 'p3',
    name: 'Puma RS-X',
    category: 'Giày Nam',
    price: 3110000,
    originalPrice: 3880000,
    imageUrl:
        'https://images.unsplash.com/photo-1552346154-21d32810aba3?w=600&auto=format&fit=crop&q=80',
    rating: 4.6,
    reviewsCount: 90,
    salesCount: 185,
    sizes: ['7', '8', '9', '10'],
    colors: [0xFF000000, 0xFFFF5D2E, 0xFFE2E8F0],
    description:
        'Puma RS-X tái hiện phong cách retro của những năm 80 với thiết kế hầm hố, phối màu năng động cá tính. Đệm Running System tạo cảm giác thoải mái khi di chuyển.',
  ),
  Product(
    id: 'p4',
    name: 'Converse Chuck 70',
    category: 'Giày Unisex',
    price: 995000,
    originalPrice: 1250000,
    imageUrl:
        'https://images.unsplash.com/photo-1607522370275-f14206abe5d3?w=600&auto=format&fit=crop&q=80',
    rating: 4.7,
    reviewsCount: 56,
    salesCount: 420,
    sizes: ['5', '6', '7', '8', '9', '10'],
    colors: [0xFF1E3A1E, 0xFFFFFFFF, 0xFF000000],
    description:
        'Converse Chuck 70 Classic Cổ Cao màu xanh rêu là biểu tượng thời trang vintage không bao giờ lỗi thời. Vải canvas dày dặn, đệm bọt êm ái chống mỏi.',
  ),
  Product(
    id: 'p5',
    name: 'Balo SimpleCarry City',
    category: 'Phụ kiện',
    price: 750000,
    originalPrice: 950000,
    imageUrl:
        'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=600&auto=format&fit=crop&q=80',
    rating: 4.5,
    reviewsCount: 38,
    salesCount: 92,
    sizes: ['Standard'],
    colors: [0xFF000000, 0xFF64748B],
    description:
        'Balo SimpleCarry City được làm từ vải trượt nước cao cấp, thiết kế tối giản, nhiều ngăn chứa đồ thông minh, bảo vệ máy tính xách tay của bạn an toàn.',
  ),
  Product(
    id: 'p6',
    name: 'Apple AirPods Pro 2',
    category: 'Điện tử',
    price: 5490000,
    originalPrice: 6990000,
    imageUrl:
        'https://images.unsplash.com/photo-1588449668338-d15168836f43?w=600&auto=format&fit=crop&q=80',
    rating: 4.9,
    reviewsCount: 320,
    salesCount: 850,
    sizes: ['One Size'],
    colors: [0xFFFFFFFF],
    description:
        'Apple AirPods Pro 2 với chip H2 đem lại khả năng chống ồn chủ động vượt trội, thời lượng pin ấn tượng và âm thanh vòm sống động.',
  ),
];
