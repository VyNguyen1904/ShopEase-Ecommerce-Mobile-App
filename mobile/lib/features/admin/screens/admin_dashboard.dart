import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/services/admin_user_service.dart';
import '../../../core/models/admin_stats_model.dart';
import '../../../core/constants/app_strings.dart';
import '../widgets/admin_dashboard_widgets.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final AdminUserService _adminUserService = AdminUserService();
  CombinedAdminStats? _stats;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final stats = await _adminUserService.getCombinedStats();
      if (!mounted) return;
      setState(() {
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const SystemSettingsDialog(),
    );
  }

  void _showLogsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const SystemLogsDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchStats,
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Header Section
                _buildHeader(context),
                const SizedBox(height: 32),

                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 140),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                  )
                else if (_error != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 100),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline_rounded,
                            size: 48,
                            color: AppColors.alertRed,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '${AppStrings.loadDataErrorPrefix}$_error',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textGrey,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _fetchStats,
                            icon: const Icon(Icons.refresh),
                            label: const Text(AppStrings.retry),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else ...[
                  // 2. Overview Statistics Section
                  const Text(
                    AppStrings.activityOverview,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildOverviewGrid(),
                  const SizedBox(height: 32),

                  // 3. Double Chart Grid Row (Bar Chart & Donut Chart)
                  _buildChartsGrid(),
                  const SizedBox(height: 24),

                  // 4. Line Chart Section (User Growth)
                  _buildUserGrowthCard(),
                  const SizedBox(height: 36),

                  // 5. Quick Actions / Management Modules
                  const Text(
                    AppStrings.adminFunctions,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildQuickActionsGrid(context),
                  const SizedBox(height: 40),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: const DecorationImage(
                image: NetworkImage(
                  'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150&auto=format&fit=crop&q=80',
                ),
                fit: BoxFit.cover,
              ),
              border: Border.all(color: AppColors.border, width: 1.5),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    AppStrings.welcomeAdmin,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Image.network(
                    'https://fonts.gstatic.com/s/e/notoemoji/latest/1f44b/512.webp',
                    width: 20,
                    height: 20,
                    errorBuilder: (context, error, stackTrace) =>
                        const Text('👋'),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              const Text(
                AppStrings.adminGreeting,
                style: TextStyle(fontSize: 12, color: AppColors.textGrey),
              ),
            ],
          ),
        ),

        // Return to Storefront button in Header
        TextButton.icon(
          onPressed: () => context.go('/home'),
          icon: const Icon(
            Icons.storefront_rounded,
            size: 18,
            color: AppColors.primary,
          ),
          label: const Text(
            AppStrings.storefront,
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          style: TextButton.styleFrom(
            backgroundColor: AppColors.primary.withValues(alpha: 0.08),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
        const SizedBox(width: 12),

        // Bell Icon
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.border),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Icon(
                Icons.notifications_none,
                color: AppColors.textDark,
                size: 22,
              ),
              Positioned(
                right: 12,
                top: 12,
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
        ),
      ],
    );
  }

  Widget _buildOverviewGrid() {
    final oStats = _stats!.orderStats;
    final uStats = _stats!.userStats;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 750;
        return GridView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isWide ? 4 : 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            mainAxisExtent: 88,
          ),
          children: [
            _buildOverviewCard(
              icon: Icons.attach_money,
              iconColor: AppColors.primary,
              iconBg: const Color(0xFFEAF5F6),
              title: AppStrings.revenue,
              value: '\$${oStats.totalRevenue.toStringAsFixed(2)}',
              percentage: 'Live',
              isIncrease: true,
            ),
            _buildOverviewCard(
              icon: Icons.shopping_bag_outlined,
              iconColor: Colors.teal,
              iconBg: const Color(0xFFE6FFFA),
              title: AppStrings.orders,
              value: oStats.totalOrders.toString(),
              percentage: 'Live',
              isIncrease: true,
            ),
            _buildOverviewCard(
              icon: Icons.people_outline_rounded,
              iconColor: Colors.indigo,
              iconBg: const Color(0xFFEBF4FF),
              title: AppStrings.members,
              value: uStats.totalUsers.toString(),
              percentage: '${uStats.activeUsers}${AppStrings.activeStatus}',
              isIncrease: true,
            ),
            _buildOverviewCard(
              icon: Icons.analytics_rounded,
              iconColor: Colors.orange,
              iconBg: const Color(0xFFFFF3CD),
              title: AppStrings.aov,
              value: '\$${oStats.aov.toStringAsFixed(2)}',
              percentage: 'Live',
              isIncrease: true,
            ),
          ],
        );
      },
    );
  }

  Widget _buildChartsGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 850;
        return isWide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: _buildBarChartCard()),
                  const SizedBox(width: 24),
                  Expanded(flex: 2, child: _buildDonutChartCard()),
                ],
              )
            : Column(
                children: [
                  _buildBarChartCard(),
                  const SizedBox(height: 24),
                  _buildDonutChartCard(),
                ],
              );
      },
    );
  }

  Widget _buildBarChartCard() {
    final sales = _stats!.orderStats.dailySales;

    // Dynamically calculate maximum height bounds for rendering
    double maxRev = sales
        .map((s) => s.revenue)
        .fold(1.0, (m, v) => v > m ? v : m);
    double maxOrd = sales
        .map((s) => s.ordersCount.toDouble())
        .fold(1.0, (m, v) => v > m ? v : m);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.01),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                AppStrings.salesAndOrders,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: const [
                    Text(
                      AppStrings.last7Days,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.keyboard_arrow_down,
                      size: 14,
                      color: AppColors.textGrey,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildLegendDot(AppColors.primary, AppStrings.revenue),
              const SizedBox(width: 16),
              _buildLegendDot(const Color(0xFFCBECE8), AppStrings.orders),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 180,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: sales.map((s) {
                // Scale value height between 10 and 140
                double revH = maxRev > 0 ? (s.revenue / maxRev) * 120 + 10 : 10;
                double ordH = maxOrd > 0
                    ? (s.ordersCount / maxOrd) * 120 + 10
                    : 10;
                return _buildDoubleBar(
                  s.date,
                  revenueHeight: revH,
                  orderHeight: ordH,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDonutChartCard() {
    final categories = _stats!.orderStats.categoryBreakdown;
    final List<double> values = categories.map((c) => c.percentage).toList();
    final List<Color> colors = [
      const Color(0xFF3B82F6), // Blue
      const Color(0xFFEC4899), // Pink
      const Color(0xFF10B981), // Green
      const Color(0xFFF59E0B), // Amber
    ];

    int totalSales = categories
        .map((c) => c.salesCount)
        .fold(0, (sum, count) => sum + count);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.01),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            AppStrings.popularCategories,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: SizedBox(
              width: 120,
              height: 120,
              child: Stack(
                children: [
                  CustomPaint(
                    size: const Size(120, 120),
                    painter: DonutChartPainter(values, colors),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          totalSales.toString(),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        const Text(
                          'Items',
                          style: TextStyle(
                            fontSize: 9,
                            color: AppColors.textGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          for (int i = 0; i < categories.length; i++) ...[
            if (i > 0) const SizedBox(height: 6),
            _buildCategoryLegend(
              categories[i].name,
              '${categories[i].percentage.toStringAsFixed(0)}%',
              colors[i % colors.length],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCategoryLegend(String name, String percentage, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(
              name,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textGrey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Text(
          percentage,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildUserGrowthCard() {
    final growth = _stats!.userStats.userGrowth;
    final List<double> dataPoints = growth
        .map((g) => g.count.toDouble())
        .toList();
    final List<String> labels = growth.map((g) => g.month).toList();

    // Map point values proportionally to canvas height
    double maxVal = dataPoints.fold(1.0, (m, v) => v > m ? v : m);
    final scaledPoints = dataPoints
        .map((v) => maxVal > 0 ? (v / maxVal) : 0.0)
        .toList();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.01),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            AppStrings.memberGrowth,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Monthly growth analytics of active client base',
            style: TextStyle(fontSize: 11.5, color: AppColors.textGrey),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 160,
            width: double.infinity,
            child: CustomPaint(
              painter: LineChartPainter(
                scaledPoints,
                const Color(0xFF3B82F6),
                const Color(0xFF3B82F6).withValues(alpha: 0.06),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: labels.map((label) {
              return Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textGrey,
                  fontWeight: FontWeight.bold,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsGrid(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 750;
        return GridView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isWide ? 4 : 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            mainAxisExtent: 88,
          ),
          children: [
            _buildMenuCard(
              context: context,
              icon: Icons.people_alt_rounded,
              color: Colors.indigo,
              title: AppStrings.manageUsers,
              subtitle: 'Manage accounts',
              onTap: () => context.push(AppRoutes.adminUsers),
            ),
            _buildMenuCard(
              context: context,
              icon: Icons.settings_suggest_rounded,
              color: Colors.orange,
              title: AppStrings.systemConfig,
              subtitle: 'Environment settings',
              onTap: () => _showSettingsDialog(context),
            ),
            _buildMenuCard(
              context: context,
              icon: Icons.terminal_rounded,
              color: Colors.purple,
              title: AppStrings.systemLogs,
              subtitle: 'Gateway trace logs',
              onTap: () => _showLogsDialog(context),
            ),
            _buildMenuCard(
              context: context,
              icon: Icons.storefront_rounded,
              color: AppColors.primary,
              title: AppStrings.returnToHome,
              subtitle: 'Exit admin panel',
              onTap: () => context.go('/home'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMenuCard({
    required BuildContext context,
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return HoverMenuCard(
      icon: icon,
      color: color,
      title: title,
      subtitle: subtitle,
      onTap: onTap,
    );
  }

  Widget _buildOverviewCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String value,
    required String percentage,
    required bool isIncrease,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.01),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textGrey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        percentage,
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                          color: isIncrease
                              ? AppColors.iconGreen
                              : AppColors.alertRed,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
  }

  Widget _buildLegendDot(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textGrey,
          ),
        ),
      ],
    );
  }

  Widget _buildDoubleBar(
    String date, {
    required double revenueHeight,
    required double orderHeight,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              width: 10,
              height: revenueHeight,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ),
            const SizedBox(width: 4),
            Container(
              width: 10,
              height: orderHeight,
              decoration: const BoxDecoration(
                color: Color(0xFFCBECE8),
                borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          date,
          style: const TextStyle(
            fontSize: 9,
            color: AppColors.textGrey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
