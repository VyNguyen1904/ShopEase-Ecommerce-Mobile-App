enum OrderStatus {
  PENDING,
  CONFIRMED,
  PACKED,
  SHIPPED,
  DELIVERED,
  CANCELLED
}

enum PaymentStatus {
  PENDING,
  PAID,
  FAILED,
  REFUNDED
}

class OrderItemRequest {
  final int productId;
  final int quantity;
  final String? color;
  final String? size;

  OrderItemRequest({required this.productId, required this.quantity, this.color, this.size});

  Map<String, dynamic> toJson() => {
    'productId': productId,
    'quantity': quantity,
    if (color != null) 'color': color,
    if (size != null) 'size': size,
  };
}

class CreateOrderRequest {
  final List<OrderItemRequest> items;
  final String shipRecipient;
  final String shipPhone;
  final String shipStreet;
  final String shipDistrict;
  final String shipCity;
  final String paymentMethod;
  final String note;

  CreateOrderRequest({
    required this.items,
    required this.shipRecipient,
    required this.shipPhone,
    required this.shipStreet,
    required this.shipDistrict,
    required this.shipCity,
    required this.paymentMethod,
    this.note = '',
  });

  Map<String, dynamic> toJson() => {
    'items': items.map((e) => e.toJson()).toList(),
    'shipRecipient': shipRecipient,
    'shipPhone': shipPhone,
    'shipStreet': shipStreet,
    'shipDistrict': shipDistrict,
    'shipCity': shipCity,
    'paymentMethod': paymentMethod,
    'note': note,
  };
}

class OrderItemResponse {
  final int id;
  final int productId;
  final String productName;
  final String productImage;
  final double unitPrice;
  final int quantity;
  final double subtotal;
  final String? color;
  final String? size;

  OrderItemResponse({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.unitPrice,
    required this.quantity,
    required this.subtotal,
    this.color,
    this.size,
  });

  factory OrderItemResponse.fromJson(Map<String, dynamic> json) {
    return OrderItemResponse(
      id: json['id'] ?? 0,
      productId: json['productId'] ?? 0,
      productName: json['productName'] ?? '',
      productImage: json['productImage'] ?? '',
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
      quantity: json['quantity'] ?? 0,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      color: json['color']?.toString(),
      size: json['size']?.toString(),
    );
  }
}

class OrderResponse {
  final String id;
  final String buyerId;
  final OrderStatus status;
  final PaymentStatus paymentStatus;
  final List<OrderItemResponse> items;
  final double subtotal;
  final double shippingFee;
  final double discountAmount;
  final double totalAmount;
  final String paymentMethod;
  final String shipRecipient;
  final String shipPhone;
  final String shipStreet;
  final String shipDistrict;
  final String shipCity;
  final String note;
  final DateTime createdAt;

  OrderResponse({
    required this.id,
    required this.buyerId,
    required this.status,
    required this.paymentStatus,
    required this.items,
    required this.subtotal,
    required this.shippingFee,
    required this.discountAmount,
    required this.totalAmount,
    required this.paymentMethod,
    required this.shipRecipient,
    required this.shipPhone,
    required this.shipStreet,
    required this.shipDistrict,
    required this.shipCity,
    required this.note,
    required this.createdAt,
  });

  factory OrderResponse.fromJson(Map<String, dynamic> json) {
    return OrderResponse(
      id: json['id']?.toString() ?? '',
      buyerId: json['buyerId'] ?? '',
      status: OrderStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => OrderStatus.PENDING,
      ),
      paymentStatus: PaymentStatus.values.firstWhere(
        (e) => e.name == json['paymentStatus'],
        orElse: () => PaymentStatus.PENDING,
      ),
      items: (json['items'] as List?)
              ?.map((e) => OrderItemResponse.fromJson(e))
              .toList() ??
          [],
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      shippingFee: (json['shippingFee'] as num?)?.toDouble() ?? 0.0,
      discountAmount: (json['discountAmount'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: json['paymentMethod'] ?? '',
      shipRecipient: json['shipRecipient'] ?? '',
      shipPhone: json['shipPhone'] ?? '',
      shipStreet: json['shipStreet'] ?? '',
      shipDistrict: json['shipDistrict'] ?? '',
      shipCity: json['shipCity'] ?? '',
      note: json['note'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }
}
