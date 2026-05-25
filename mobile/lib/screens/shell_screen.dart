import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/product.dart';
import 'onboarding/splash_screen.dart';
import 'onboarding/onboarding_screen.dart';
import 'auth/register_screen.dart';
import 'customer/home_screen.dart';
import 'customer/search_results_screen.dart';
import 'customer/product_detail_screen.dart';
import 'common/category_screen.dart';
import 'common/notification_screen.dart';
import 'common/account_screen.dart';
import 'common/settings_screen.dart';
import 'common/chat_list_screen.dart';
import 'admin_seller_demo/admin_dashboard.dart';
import 'admin_seller_demo/admin_orders.dart';
import 'admin_seller_demo/admin_users.dart';
import 'admin_seller_demo/seller_order_detail.dart';
import 'admin_seller_demo/seller_notifications.dart';

class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key});

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  // Navigation States
  // 'splash' -> 'onboarding' -> 'register' -> 'main' -> 'product_detail' -> 'search_results' -> 'settings' -> 'chats'
  String _currentFlow = 'splash'; 
  int _currentTabIndex = 0; // For bottom navigation: 0 = Home, 1 = Category, 2 = Cart (stub), 3 = Orders (stub), 4 = Account / Notification
  
  Product _selectedProduct = mockProducts[0];
  String _selectedHeroTag = 'hero_flash_p1';

  void _navigateToFlow(String flow) {
    setState(() {
      _currentFlow = flow;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget activeBody;

    switch (_currentFlow) {
      case 'splash':
        activeBody = SplashScreen(onNext: () => _navigateToFlow('onboarding'));
        break;
      case 'onboarding':
        activeBody = OnboardingScreen(onNext: () => _navigateToFlow('register'));
        break;
      case 'register':
        activeBody = RegisterScreen(
          onBack: () => _navigateToFlow('onboarding'),
          onRegisterSuccess: () => _navigateToFlow('main'),
        );
        break;
      case 'product_detail':
        activeBody = ProductDetailScreen(
          product: _selectedProduct,
          heroTag: _selectedHeroTag,
          onBack: () => _navigateToFlow('main'),
        );
        break;
      case 'search_results':
        activeBody = SearchResultsScreen(
          onBack: () => _navigateToFlow('main'),
          onProductTap: (product, heroTag) {
            setState(() {
              _selectedProduct = product;
              _selectedHeroTag = heroTag;
              _currentFlow = 'product_detail';
            });
          },
        );
        break;
      case 'settings':
        activeBody = SettingsScreen(
          onBack: () => _navigateToFlow('main'),
        );
        break;
      case 'chats':
        activeBody = ChatListScreen(
          onBack: () => _navigateToFlow('main'),
        );
        break;
      case 'account':
        activeBody = AccountScreen(
          onSettingsTap: () => _navigateToFlow('settings'),
          onOrdersTap: () {
            setState(() {
              _currentTabIndex = 3;
              _currentFlow = 'main';
            });
          },
          onLogoutTap: () => _navigateToFlow('splash'),
        );
        break;
      case 'admin_dashboard':
        activeBody = AdminDashboard(
          onBack: () => _navigateToFlow('main'),
        );
        break;
      case 'admin_orders':
        activeBody = AdminOrders(
          onBack: () => _navigateToFlow('main'),
        );
        break;
      case 'admin_users':
        activeBody = AdminUsers(
          onBack: () => _navigateToFlow('main'),
        );
        break;
      case 'seller_order_detail':
        activeBody = SellerOrderDetail(
          onBack: () => _navigateToFlow('main'),
        );
        break;
      case 'seller_notifications':
        activeBody = SellerNotifications(
          onBack: () => _navigateToFlow('main'),
        );
        break;
      case 'main':
      default:
        activeBody = _buildMainBottomNavigationFlow();
        break;
    }

    return Scaffold(
      body: Stack(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            switchInCurve: Curves.easeInOutCubic,
            switchOutCurve: Curves.easeInOutCubic,
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.08, 0.0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: KeyedSubtree(
              key: ValueKey<String>('${_currentFlow}_${_currentFlow == 'main' ? _currentTabIndex : ''}'),
              child: activeBody,
            ),
          ),
          
          // Floating High-Fidelity Reviewer Panel (Incredible value-add)
          Positioned(
            bottom: 80,
            right: 16,
            child: FloatingActionButton.small(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              tooltip: 'Duyệt nhanh màn hình PNG',
              child: const Icon(Icons.developer_mode),
              onPressed: () => _showReviewPanel(context),
            ),
          ),
        ],
      ),
    );
  }

  // Build the main flow when the user is logged in, displaying the Bottom Navigation Bar
  Widget _buildMainBottomNavigationFlow() {
    Widget body;
    switch (_currentTabIndex) {
      case 1:
        body = CategoryScreen(
          onSearchTrigger: () => _navigateToFlow('search_results'),
        );
        break;
      case 2:
        body = const Center(
          child: Text(
            'Giỏ hàng (Trống)',
            style: TextStyle(fontSize: 18, color: AppColors.textGrey, fontWeight: FontWeight.w600),
          ),
        );
        break;
      case 3:
        body = const Center(
          child: Text(
            'Đơn hàng (Trống)',
            style: TextStyle(fontSize: 18, color: AppColors.textGrey, fontWeight: FontWeight.w600),
          ),
        );
        break;
      case 4:
        body = NotificationScreen(
          onSettingsTap: () => _navigateToFlow('settings'),
          onChatTap: () => _navigateToFlow('chats'),
        );
        break;
      case 0:
      default:
        body = HomeScreen(
          onProductTap: (product, heroTag) {
            setState(() {
              _selectedProduct = product;
              _selectedHeroTag = heroTag;
              _currentFlow = 'product_detail';
            });
          },
          onSearchTrigger: () => _navigateToFlow('search_results'),
          onNotificationTap: () {
            setState(() {
              _currentTabIndex = 4;
            });
          },
        );
        break;
    }

    return Scaffold(
      body: body,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentTabIndex > 4 ? 0 : _currentTabIndex,
        onTap: (index) {
          setState(() {
            _currentTabIndex = index;
            _currentFlow = 'main'; // Reset flow to main shell
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textLight,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Trang chủ',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_outlined),
            activeIcon: Icon(Icons.grid_view),
            label: 'Danh mục',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            activeIcon: Icon(Icons.shopping_cart),
            label: 'Giỏ hàng',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            activeIcon: Icon(Icons.assignment),
            label: 'Đơn hàng',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                const Icon(Icons.notifications_outlined),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.alertRed,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
            activeIcon: const Icon(Icons.notifications),
            label: 'Thông báo',
          ),
        ],
      ),
    );
  }

  // Display a highly practical bottom sheet to jump to any UI screen for direct design review
  void _showReviewPanel(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.developer_mode, color: AppColors.primary),
                  SizedBox(width: 8),
                  Text(
                    'Bảng điều khiển kiểm thử giao diện',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Chọn nhanh một màn hình từ thiết kế PNG để đối chiếu:',
                style: TextStyle(fontSize: 13, color: AppColors.textGrey),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: [
                    _buildPanelSection('1. Luồng Chào Mừng & Đăng ký', [
                      _buildPanelItem(context, 'Splash Screen (Customer/1.png)', () {
                        _navigateToFlow('splash');
                      }),
                      _buildPanelItem(context, 'Onboarding (Customer/2.png)', () {
                        _navigateToFlow('onboarding');
                      }),
                      _buildPanelItem(context, 'Register (Customer/4.png)', () {
                        _navigateToFlow('register');
                      }),
                    ]),
                    _buildPanelSection('2. Trang mua sắm chính', [
                      _buildPanelItem(context, 'Home Screen (Customer/5.png)', () {
                        setState(() {
                          _currentTabIndex = 0;
                          _currentFlow = 'main';
                        });
                      }),
                      _buildPanelItem(context, 'Search Results (Customer/6.png)', () {
                        _navigateToFlow('search_results');
                      }),
                      _buildPanelItem(context, 'Product Detail (Customer/7.png)', () {
                        setState(() {
                          _selectedProduct = mockProducts[0]; // Nike Air Max 270
                          _selectedHeroTag = 'hero_suggest_${mockProducts[0].id}';
                          _currentFlow = 'product_detail';
                        });
                      }),
                    ]),
                    _buildPanelSection('3. Màn hình chung (Common Screens)', [
                      _buildPanelItem(context, 'Categories (Common_Sceen/2.png)', () {
                        setState(() {
                          _currentTabIndex = 1;
                          _currentFlow = 'main';
                        });
                      }),
                      _buildPanelItem(context, 'Notifications (Common_Sceen/1.png)', () {
                        setState(() {
                          _currentTabIndex = 4;
                          _currentFlow = 'main';
                        });
                      }),
                      _buildPanelItem(context, 'Settings (Common_Sceen/3.png)', () {
                        _navigateToFlow('settings');
                      }),
                      _buildPanelItem(context, 'Account (Common_Sceen/4.png)', () {
                        _navigateToFlow('account');
                      }),
                      _buildPanelItem(context, 'Chat List (Common_Sceen/6.png)', () {
                        _navigateToFlow('chats');
                      }),
                    ]),
                    _buildPanelSection('4. Quản trị & Người bán (Admin & Seller)', [
                      _buildPanelItem(context, 'Admin Dashboard (Admin/1.png)', () {
                        _navigateToFlow('admin_dashboard');
                      }),
                      _buildPanelItem(context, 'Admin Orders & Stock (Admin/2.png)', () {
                        _navigateToFlow('admin_orders');
                      }),
                      _buildPanelItem(context, 'Admin User Management (Admin/3.png)', () {
                        _navigateToFlow('admin_users');
                      }),
                      _buildPanelItem(context, 'Seller Order Detail (Seller/1.png)', () {
                        _navigateToFlow('seller_order_detail');
                      }),
                      _buildPanelItem(context, 'Seller Notifications (Seller/2.png)', () {
                        _navigateToFlow('seller_notifications');
                      }),
                    ]),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPanelSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary),
          ),
        ),
        ...items,
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildPanelItem(BuildContext context, String name, VoidCallback onTap) {
    return Card(
      elevation: 0,
      color: AppColors.bgLight,
      margin: const EdgeInsets.only(bottom: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        title: Text(
          name,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark),
        ),
        dense: true,
        trailing: const Icon(Icons.arrow_forward, size: 14, color: AppColors.primary),
        onTap: () {
          Navigator.pop(context);
          onTap();
        },
      ),
    );
  }
}
