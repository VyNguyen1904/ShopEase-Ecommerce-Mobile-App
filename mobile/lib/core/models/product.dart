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

  factory Product.fromJson(Map<String, dynamic> json) {
    String imgUrl = '';
    if (json['imageUrls'] != null && (json['imageUrls'] as List).isNotEmpty) {
      imgUrl = json['imageUrls'][0].toString();
    } else if (json['images'] != null && (json['images'] as List).isNotEmpty) {
      imgUrl = json['images'][0].toString();
    } else {
      imgUrl = json['imageUrl']?.toString() ?? '';
    }

    return Product(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? json['categoryId']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      originalPrice: (json['originalPrice'] as num?)?.toDouble(),
      imageUrl: imgUrl,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewsCount: (json['reviewsCount'] as num?)?.toInt() ?? 0,
      salesCount: (json['salesCount'] as num?)?.toInt() ?? 0,
      sizes: (json['sizes'] as List?)?.map((e) => e.toString()).toList() ?? [],
      colors: (json['colors'] as List?)?.map((e) => int.tryParse(e.toString()) ?? 0).toList() ?? [],
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'name': name,
      'categoryId': category,
      'price': price,
      'originalPrice': originalPrice,
      'imageUrl': imageUrl,
      'rating': rating,
      'reviewsCount': reviewsCount,
      'salesCount': salesCount,
      'sizes': sizes,
      'colors': colors,
      'description': description,
    };
  }

  int get discountPercentage {
    if (originalPrice == null || originalPrice! <= price) return 0;
    return (((originalPrice! - price) / originalPrice!) * 100).round();
  }
}
