import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_routes.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> _tabs = [
    'Tất cả',
    'Chờ xác nhận',
    'Đang giao',
    'Đã giao',
    'Đã huỷ',
  ];

  final List<Map<String, dynamic>> _orders = [
    {
      'id': 'ORD-1092',
      'status': 'Đã giao',
      'date': '20 Tha 5, 2026',
      'total': 480000.0,
      'items': [
        {
          'name': 'Nike Air Max 270',
          'image':
              'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400&q=80',
          'variant': 'Trắng - Xanh Ngọc / Size 9',
          'qty': 1,
          'price': 3160000.0,
        }
      ]
    },
    {
      'id': 'ORD-1093',
      'status': 'Đang giao',
      'date': '28 Tha 5, 2026',
      'total': 820000.0,
      'items': [
        {
          'name': 'Adidas Ultraboost',
          'image':
              'https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?w=400&q=80',
          'variant': 'Đen / Size 8',
          'qty': 1,
          'price': 3160000.0,
        },
        {
          'name': 'Converse Chuck 70',
          'image':
              'https://images.unsplash.com/photo-1607522370275-f14206abe5d3?w=400&q=80',
          'variant': 'Rêu / Size 7',
          'qty': 1,
          'price': 995000.0,
        }
      ]
    },
    {
      'id': 'ORD-1085',
      'status': 'Đã huỷ',
      'date': '15 Tha 5, 2026',
      'total': 1500000.0,
      'items': [
        {
          'name': 'Puma RS-X',
          'image':
              'https://images.unsplash.com/photo-1552346154-21d32810aba3?w=400&q=80',
          'variant': 'Trắng - Cam / Size 9',
          'qty': 1,
          'price': 3110000.0,
        }
      ]
    }
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Đã giao':
        return Colors.green;
      case 'Đang giao':
        return Colors.orange;
      case 'Đã huỷ':
        return AppColors.alertRed;
      default:
        return AppColors.primary;
    }
  }

  String _formatCurrency(double amount) {
    return amount.toInt().toString().replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Đơn hàng của tôi',
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Container(
            alignment: Alignment.centerLeft,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              padding: EdgeInsets.zero,
              labelPadding: const EdgeInsets.symmetric(horizontal: 16),
              dividerColor: Colors.transparent,
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorPadding: EdgeInsets.zero,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textGrey,
              labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
              splashFactory: NoSplash.splashFactory,
              overlayColor: MaterialStateProperty.all(Colors.transparent),
              tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _tabs.map((tab) {
          final filteredOrders = tab == 'Tất cả'
              ? _orders
              : _orders.where((o) => o['status'] == tab).toList();

          if (filteredOrders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long_outlined,
                      size: 64, color: AppColors.textLight.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  const Text(
                    'Chưa có đơn hàng nào',
                    style: TextStyle(
                      color: AppColors.textGrey,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 120),
            itemCount: filteredOrders.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final order = filteredOrders[index];
              final items = order['items'] as List<dynamic>;
              final statusColor = _getStatusColor(order['status']);

              return GestureDetector(
                onTap: () {
                  final orderId = order['id']?.toString().replaceAll('ORD-', 'SE240515000') ?? 'SE2405150001';
                  context.push(AppRoutes.orderDetailPath(orderId));
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Mã ĐH: ${order['id']}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textDark,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            order['status'],
                            style: TextStyle(
                              fontSize: 12,
                              color: statusColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      order['date'],
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textGrey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(height: 1, color: AppColors.border),
                    ),
                    ...items.map((item) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: AppColors.border.withOpacity(0.5)),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(11),
                                child: Image.network(
                                  item['image'],
                                  width: 72,
                                  height: 72,
                                  fit: BoxFit.cover,
                                  cacheWidth: 144,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                    width: 72,
                                    height: 72,
                                    color: AppColors.bgLight,
                                    child: const Icon(Icons.image_not_supported,
                                        color: AppColors.textGrey),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['name'],
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textDark,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Phân loại: ${item['variant']}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textGrey,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${_formatCurrency(item['price'])} đ',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.textDark,
                                        ),
                                      ),
                                      Text(
                                        'x${item['qty']}',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.textGrey,
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
                    }).toList(),
                    const Padding(
                      padding: EdgeInsets.only(top: 4, bottom: 12),
                      child: Divider(height: 1, color: AppColors.border),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${items.length} sản phẩm',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textGrey,
                          ),
                        ),
                        Row(
                          children: [
                            const Text(
                              'Thành tiền: ',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textDark,
                              ),
                            ),
                            Text(
                              '${_formatCurrency(order['total'])} đ',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (order['status'] == 'Đã giao')
                          OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.border),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            ),
                            child: const Text('Đánh giá',
                                style: TextStyle(
                                    color: AppColors.textDark,
                                    fontWeight: FontWeight.w600)),
                          ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: order['status'] == 'Đang giao'
                                ? AppColors.primary
                                : AppColors.textDark,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          ),
                          child: Text(
                            order['status'] == 'Đang giao'
                                ? 'Theo dõi đơn'
                                : 'Mua lại',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            );
          },
          );
        }).toList(),
      ),
    );
  }
}