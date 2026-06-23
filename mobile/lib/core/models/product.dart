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
  final List<String> colors;
  final String description;
  final String? material;
  final String? fit;
  final String? careInstructions;
  final List<String> features;
  final int stockQuantity;

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
    this.material,
    this.fit,
    this.careInstructions,
    this.features = const [],
    this.stockQuantity = 0,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    String imgUrl = '';
    if (json['imageUrls'] != null && (json['imageUrls'] as List).isNotEmpty) {
      imgUrl = json['imageUrls'][0].toString();
    } else if (json['images'] != null && (json['images'] as List).isNotEmpty) {
      imgUrl = json['images'][0].toString();
    } else {
      imgUrl = json['thumbnailUrl']?.toString() ?? json['imageUrl']?.toString() ?? '';
    }

    String categoryStr = '';
    if (json['category'] is Map) {
      categoryStr = json['category']['name']?.toString() ?? json['category']['id']?.toString() ?? '';
    } else {
      categoryStr = json['category']?.toString() ?? json['categoryId']?.toString() ?? '';
    }

    return Product(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      category: categoryStr,
      price: (json['salePrice'] as num?)?.toDouble() ?? (json['price'] as num?)?.toDouble() ?? (json['basePrice'] as num?)?.toDouble() ?? 0.0,
      originalPrice: (json['basePrice'] as num?)?.toDouble() ?? (json['originalPrice'] as num?)?.toDouble(),
      imageUrl: imgUrl,
      rating: (json['avgRating'] as num?)?.toDouble() ?? (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewsCount: (json['reviewCount'] as num?)?.toInt() ?? (json['reviewsCount'] as num?)?.toInt() ?? 0,
      salesCount: (json['soldCount'] as num?)?.toInt() ?? (json['salesCount'] as num?)?.toInt() ?? 0,
      sizes: (json['sizes'] as List?)?.map((e) => e.toString()).toList() ?? [],
      colors: (json['colors'] as List?)?.map((e) => e.toString()).toList() ?? [],
      description: json['description'] ?? '',
      material: json['material']?.toString(),
      fit: json['fit']?.toString(),
      careInstructions: json['careInstructions']?.toString(),
      features: (json['features'] as List?)?.map((e) => e.toString()).toList() ?? [],
      stockQuantity: (json['stockQuantity'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'name': name,
      'categoryId': category,
      'basePrice': price,
      'salePrice': originalPrice ?? price,
      'thumbnailUrl': imageUrl,
      'imageUrls': [imageUrl],
      'rating': rating,
      'reviewsCount': reviewsCount,
      'salesCount': salesCount,
      'sizes': sizes,
      'colors': colors,
      'description': description,
      'material': material,
      'fit': fit,
      'careInstructions': careInstructions,
      'features': features,
      'stockQuantity': stockQuantity,
    };
  }

  int get discountPercentage {
    if (originalPrice == null || originalPrice! <= price) return 0;
    return (((originalPrice! - price) / originalPrice!) * 100).round();
  }
}
