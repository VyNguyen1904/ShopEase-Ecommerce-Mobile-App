import 'package:flutter/material.dart';
import 'widgets/custom_bottom_nav.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final List<Map<String, dynamic>> _cartItems = [
    {
      'id': '1',
      'name': 'Tai nghe Bluetooth Sony WH...',
      'variant': 'Black',
      'price': 6490000,
      'quantity': 1,
      'image':
          'https://images.unsplash.com/photo-1618366712010-f4ae9c647dcb?auto=format&fit=crop&w=400&q=80',
      'selected': true,
    },
    {
      'id': '2',
      'name': 'Giày Chạy Bộ Nam Air Zoom...',
      'variant': 'Red/White, Size 42',
      'price': 2450000,
      'quantity': 1,
      'image':
          'https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&w=400&q=80',
      'selected': true,
    },
  ];

  void _toggleSelection(int index) {
    setState(() {
      _cartItems[index]['selected'] = !_cartItems[index]['selected'];
    });
  }

  void _updateQuantity(int index, int delta) {
    setState(() {
      final newQuantity = _cartItems[index]['quantity'] + delta;
      if (newQuantity > 0) {
        _cartItems[index]['quantity'] = newQuantity;
      }
    });
  }

  void _removeItem(int index) {
    setState(() {
      _cartItems.removeAt(index);
    });
  }

  int get _calculateTotal {
    int total = 0;
    for (var item in _cartItems) {
      if (item['selected']) {
        total += (item['price'] as int) * (item['quantity'] as int);
      }
    }
    return total;
  }

  int get _selectedCount {
    return _cartItems.where((item) => item['selected'] as bool).length;
  }

  String _formatCurrency(int amount) {
    final str = amount.toString();
    String result = '';
    for (int i = str.length - 1; i >= 0; i--) {
      result = str[i] + result;
      if ((str.length - i) % 3 == 0 && i != 0) {
        result = '.$result';
      }
    }
    return '$resultđ';
  }

  @override
  Widget build(BuildContext context) {
    final total = _calculateTotal;
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading:
            false, // Managed by bottom nav or custom leading if needed
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2937)),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: const Text(
          'Giỏ hàng',
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Color(0xFF1F2937)),
            onPressed: () {},
          ),
        ],
      ),
      body: _cartItems.isEmpty
          ? const Center(child: Text('Giỏ hàng trống'))
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Cart Items
                          ...List.generate(_cartItems.length, (index) {
                            final item = _cartItems[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.02),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Checkbox
                                  Checkbox(
                                    value: item['selected'],
                                    onChanged: (value) =>
                                        _toggleSelection(index),
                                    activeColor: const Color(0xFF2E6582),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  // Image
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      item['image'],
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                item['name'],
                                                style: const TextStyle(
                                                  color: Color(0xFF1F2937),
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () => _removeItem(index),
                                              child: const Icon(
                                                Icons.delete_outline,
                                                color: Color(0xFF9CA3AF),
                                                size: 20,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          item['variant'],
                                          style: const TextStyle(
                                            color: Color(0xFF6B7280),
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              _formatCurrency(item['price']),
                                              style: const TextStyle(
                                                color: Color(0xFF2E6582),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            // Quantity Selector
                                            Container(
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFF3F4F6),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: Row(
                                                children: [
                                                  InkWell(
                                                    onTap: () =>
                                                        _updateQuantity(
                                                          index,
                                                          -1,
                                                        ),
                                                    child: const Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                            horizontal: 12,
                                                            vertical: 4,
                                                          ),
                                                      child: Icon(
                                                        Icons.remove,
                                                        size: 16,
                                                        color: Color(
                                                          0xFF4B5563,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Text(
                                                    '${item['quantity']}',
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                  InkWell(
                                                    onTap: () =>
                                                        _updateQuantity(
                                                          index,
                                                          1,
                                                        ),
                                                    child: const Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                            horizontal: 12,
                                                            vertical: 4,
                                                          ),
                                                      child: Icon(
                                                        Icons.add,
                                                        size: 16,
                                                        color: Color(
                                                          0xFF4B5563,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),

                          const SizedBox(height: 8),
                          // Discount Code
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: const [
                                    Icon(
                                      Icons.local_activity_outlined,
                                      color: Color(0xFF2E6582),
                                      size: 20,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Mã giảm giá',
                                      style: TextStyle(
                                        color: Color(0xFF1F2937),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        height: 44,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF3F4F6),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                        ),
                                        child: const TextField(
                                          decoration: InputDecoration(
                                            border: InputBorder.none,
                                            hintText: 'Nhập mã giảm giá',
                                            hintStyle: TextStyle(
                                              color: Color(0xFF9CA3AF),
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Container(
                                      height: 44,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF0F4C75),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Center(
                                        child: Text(
                                          'Áp dụng',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Footer
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 15,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Tạm tính',
                            style: TextStyle(color: Color(0xFF6B7280)),
                          ),
                          Text(
                            _formatCurrency(total),
                            style: const TextStyle(
                              color: Color(0xFF1F2937),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                            'Phí vận chuyển',
                            style: TextStyle(color: Color(0xFF6B7280)),
                          ),
                          Text(
                            'Miễn phí',
                            style: TextStyle(
                              color: Color(0xFF1F2937),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Divider(color: Color(0xFFE5E7EB)),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Tổng cộng',
                            style: TextStyle(
                              color: Color(0xFF1F2937),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            _formatCurrency(total),
                            style: const TextStyle(
                              color: Color(0xFFE88B41),
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      InkWell(
                        onTap: _selectedCount > 0
                            ? () {
                                Navigator.pushNamed(context, '/checkout');
                              }
                            : null,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: _selectedCount > 0
                                ? const Color(0xFF2E6582)
                                : const Color(0xFF9CA3AF),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Thanh toán ($_selectedCount)',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.arrow_forward,
                                color: Colors.white,
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 1),
    );
  }
}
