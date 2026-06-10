class OrderModel {
  final String id;
  final String buyerId;
  final String status;
  final String paymentStatus;
  final List<OrderItemModel> items;
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
  final String? note;
  final DateTime createdAt;

  OrderModel({
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
    this.note,
    required this.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] ?? '',
      buyerId: json['buyerId'] ?? '',
      status: json['status'] ?? 'PENDING',
      paymentStatus: json['paymentStatus'] ?? 'PENDING',
      items: (json['items'] as List?)
              ?.map((item) => OrderItemModel.fromJson(item))
              .toList() ??
          [],
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      shippingFee: (json['shippingFee'] ?? 0).toDouble(),
      discountAmount: (json['discountAmount'] ?? 0).toDouble(),
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      paymentMethod: json['paymentMethod'] ?? 'COD',
      shipRecipient: json['shipRecipient'] ?? '',
      shipPhone: json['shipPhone'] ?? '',
      shipStreet: json['shipStreet'] ?? '',
      shipDistrict: json['shipDistrict'] ?? '',
      shipCity: json['shipCity'] ?? '',
      note: json['note'],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
    );
  }
}

class OrderItemModel {
  final int id;
  final int productId;
  final String productName;
  final String? productImage;
  final double unitPrice;
  final int quantity;
  final double subtotal;

  OrderItemModel({
    required this.id,
    required this.productId,
    required this.productName,
    this.productImage,
    required this.unitPrice,
    required this.quantity,
    required this.subtotal,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'] ?? 0,
      productId: json['productId'] ?? 0,
      productName: json['productName'] ?? '',
      productImage: json['productImage'],
      unitPrice: (json['unitPrice'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 0,
      subtotal: (json['subtotal'] ?? 0).toDouble(),
    );
  }
}
