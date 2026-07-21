class CartResponse {
  final String userId;
  final List<CartItem> items;
  final double subtotal;
  final int totalItems;

  CartResponse({
    required this.userId,
    required this.items,
    required this.subtotal,
    required this.totalItems,
  });

  factory CartResponse.fromJson(Map<String, dynamic> json) {
    return CartResponse(
      userId: json['userId']?.toString() ?? '',
      items:
          (json['items'] as List?)?.map((e) => CartItem.fromJson(e)).toList() ??
          [],
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      totalItems: json['totalItems'] ?? 0,
    );
  }
}

class CartItem {
  final String itemId;
  final int productId;
  final double price;
  int quantity;
  final double subtotal;
  final String? color;
  final String? size;

  // Local state for UI
  bool selected;
  String? productName;
  String? productImageUrl;
  String? productVariant;

  CartItem({
    required this.itemId,
    required this.productId,
    required this.price,
    required this.quantity,
    required this.subtotal,
    this.color,
    this.size,
    this.selected = true,
    this.productName,
    this.productImageUrl,
    this.productVariant,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    final parsedItemId =
        json['itemId']?.toString() ?? json['id']?.toString() ?? '';
    final fallbackId = '${json['productId']}_${json['color']}_${json['size']}';
    final finalId = parsedItemId.isNotEmpty ? parsedItemId : fallbackId;

    return CartItem(
      itemId: finalId,
      productId: json['productId'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 0,
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      color: json['color']?.toString(),
      size: json['size']?.toString(),
      selected: true,
    );
  }
}
