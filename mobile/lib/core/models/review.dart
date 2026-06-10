class Review {
  final String id;
  final String productId;
  final String orderId;
  final String buyerId;
  final int rating;
  final String title;
  final String body;
  final List<String> imageUrls;
  final String status;
  final int helpfulCount;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.productId,
    required this.orderId,
    required this.buyerId,
    required this.rating,
    required this.title,
    required this.body,
    required this.imageUrls,
    required this.status,
    required this.helpfulCount,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id']?.toString() ?? '',
      productId: json['productId']?.toString() ?? '',
      orderId: json['orderId']?.toString() ?? '',
      buyerId: json['buyerId']?.toString() ?? 'Khách hàng',
      rating: json['rating'] ?? 5,
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      status: json['status'] ?? 'ACTIVE',
      helpfulCount: json['helpfulCount'] ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }
}
