import 'package:flutter_test/flutter_test.dart';
import 'package:shopease/core/models/cart_model.dart';

void main() {
  group('Cart Logic Unit Tests', () {
    test('Calculate subtotal of selected items in cart', () {
      final item1 = CartItem(
        productId: 1,
        price: 150000,
        quantity: 2,
        subtotal: 300000,
        selected: true,
      );
      final item2 = CartItem(
        productId: 2,
        price: 50000,
        quantity: 1,
        subtotal: 50000,
        selected: false, // Not selected, should not be included in subtotal
      );

      final items = [item1, item2];
      
      final newSubtotal = items
          .where((item) => item.selected)
          .fold(0.0, (sum, item) => sum + (item.price * item.quantity));

      expect(newSubtotal, 300000);
    });
  });
}
