class CheckoutPaymentRequest {
  final String orderId;
  final double amount;
  final String currency;
  final String? cardNumber;
  final String? cardHolder;
  final String? expiryDate;
  final String? cvv;
  final String paymentMethod;

  CheckoutPaymentRequest({
    required this.orderId,
    required this.amount,
    this.currency = 'VND',
    this.cardNumber,
    this.cardHolder,
    this.expiryDate,
    this.cvv,
    required this.paymentMethod,
  });

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'amount': amount,
      'currency': currency,
      'cardNumber': cardNumber,
      'cardHolder': cardHolder,
      'expiryDate': expiryDate,
      'cvv': cvv,
      'paymentMethod': paymentMethod,
    };
  }
}

class CheckoutPaymentResponse {
  final String? transactionId;
  final String orderId;
  final String status;
  final String? message;
  final String? timestamp;

  CheckoutPaymentResponse({
    this.transactionId,
    required this.orderId,
    required this.status,
    this.message,
    this.timestamp,
  });

  factory CheckoutPaymentResponse.fromJson(Map<String, dynamic> json) {
    return CheckoutPaymentResponse(
      transactionId: json['transactionId'],
      orderId: json['orderId'] ?? '',
      status: json['status'] ?? 'UNKNOWN',
      message: json['message'],
      timestamp: json['timestamp'],
    );
  }
}
