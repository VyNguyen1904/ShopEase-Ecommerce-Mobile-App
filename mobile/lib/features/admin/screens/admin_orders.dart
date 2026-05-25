import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';

class AdminOrders extends StatefulWidget {
  const AdminOrders({super.key});

  @override
  State<AdminOrders> createState() => _AdminOrdersState();
}

class _AdminOrdersState extends State<AdminOrders> {
  String _activeTab = 'Tất cả (136)';

  final List<String> _tabs = [
    'Tất cả (136)',
    'Đang xử lý',
    'Đang giao',
    'Đã giao',
    'Đã hủy',
  ];

  final List<Map<String, dynamic>> _inventoryItems = [
    {
      'code': '#SE2405150001',
      'name': 'Nike Air Max 270',
      'price': 160.00,
      'date': '15/05/2024 • 10:30',
      'stockText': 'Còn hàng (20)',
      'status': 'Còn hàng',
      'color': const Color(0xFFEAF5F6),
      'image': 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=200&auto=format&fit=crop&q=80',
    },
    {
      'code': '#SE2405180005',
      'name': 'Adidas Ultraboost',
      'price': 160.00,
      'date': '18/05/2024 • 09:15',
      'stockText': 'Còn hàng (15)',
      'status': 'Còn hàng',
      'color': const Color(0xFFEAF5F6),
      'image': 'https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?w=200&auto=format&fit=crop&q=80',
    },
    {
      'code': '#SE2405200023',
      'name': 'Puma RS-X',
      'price': 118.00,
      'date': '20/05/2024 • 14:20',
      'stockText': 'Sắp hết hàng (8)',
      'status': 'Sắp hết hàng',
      'color': const Color(0xFFFFF2EE),
      'image': 'https://images.unsplash.com/photo-1552346154-21d32810aba3?w=200&auto=format&fit=crop&q=80',
    },
    {
      'code': '#SE2405210036',
      'name': 'Converse Chuck 70',
      'price': 98.00,
      'date': '21/05/2024 • 16:45',
      'stockText': 'Hết hàng',
      'status': 'Hết hàng',
      'color': const Color(0xFFFFF0F0),
      'image': 'https://images.unsplash.com/photo-1607522370275-f14206abe5d3?w=200&auto=format&fit=crop&q=80',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Đơn hàng',
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppColors.textDark, size: 24),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.filter_list, color: AppColors.textDark, size: 24),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // 1. Horizontal Scrollable Tabs
          Container(
            height: 48,
            padding: const EdgeInsets.only(left: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _tabs.length,
              itemBuilder: (context, index) {
                final tab = _tabs[index];
                final isSelected = _activeTab == tab;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _activeTab = tab;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 20),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: isSelected ? AppColors.primary : Colors.transparent,
                          width: 2.5,
                        ),
                      ),
                    ),
                    child: Text(
                      tab,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? AppColors.primary : AppColors.textGrey,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1, color: AppColors.border),

          // 2. Inventory / Orders List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _inventoryItems.length,
              itemBuilder: (context, index) {
                final item = _inventoryItems[index];
                return _buildOrderInventoryTile(item);
              },
            ),
          ),

          // 3. Bottom Button "Xem tất cả đơn hàng" (Admin/2.png)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.assignment, size: 20),
                label: const Text(
                  'Xem tất cả đơn hàng',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderInventoryTile(Map<String, dynamic> item) {
    Color badgeColor;
    Color textColor;
    switch (item['status']) {
      case 'Còn hàng':
        badgeColor = const Color(0xFFEAF5F6);
        textColor = AppColors.primary;
        break;
      case 'Sắp hết hàng':
        badgeColor = const Color(0xFFFFF2EE);
        textColor = AppColors.accent;
        break;
      case 'Hết hàng':
      default:
        badgeColor = const Color(0xFFFFF0F0);
        textColor = AppColors.alertRed;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Product Image Container
          Container(
            width: 80,
            height: 80,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.bgLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                item['image'],
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Product details Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item['code'],
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textDark),
                    ),
                    // Status Badge (Còn hàng, Sắp hết hàng, Hết hàng)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: badgeColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item['status'],
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  item['name'],
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textDark),
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${item['price'].toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textDark),
                ),
                const SizedBox(height: 6),
                Text(
                  item['date'],
                  style: const TextStyle(fontSize: 12, color: AppColors.textLight),
                ),
                const SizedBox(height: 8),
                // Text status line
                Text(
                  item['stockText'],
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, color: AppColors.textLight, size: 20),
        ],
      ),
    );
  }
}
