import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/services/admin_user_service.dart';
import '../../../core/models/admin_stats_model.dart';
import '../../../core/constants/app_strings.dart';

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
      builder: (context) => const _SystemSettingsDialog(),
    );
  }

  void _showLogsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const _SystemLogsDialog(),
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
                      child: CircularProgressIndicator(color: AppColors.primary),
                    ),
                  )
                else if (_error != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 100),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.alertRed),
                          const SizedBox(height: 16),
                          Text(
                            '${AppStrings.loadDataErrorPrefix}$_error',
                            style: const TextStyle(fontSize: 14, color: AppColors.textGrey, fontWeight: FontWeight.bold),
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
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                ]
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
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textGrey,
                ),
              ),
            ],
          ),
        ),
        
        // Return to Storefront button in Header
        TextButton.icon(
          onPressed: () => context.go('/home'),
          icon: const Icon(Icons.storefront_rounded, size: 18, color: AppColors.primary),
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
    double maxRev = sales.map((s) => s.revenue).fold(1.0, (m, v) => v > m ? v : m);
    double maxOrd = sales.map((s) => s.ordersCount.toDouble()).fold(1.0, (m, v) => v > m ? v : m);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.01), blurRadius: 10, offset: const Offset(0, 4))
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
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: const [
                    Text(AppStrings.last7Days, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                    SizedBox(width: 4),
                    Icon(Icons.keyboard_arrow_down, size: 14, color: AppColors.textGrey),
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
                double ordH = maxOrd > 0 ? (s.ordersCount / maxOrd) * 120 + 10 : 10;
                return _buildDoubleBar(s.date, revenueHeight: revH, orderHeight: ordH);
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

    int totalSales = categories.map((c) => c.salesCount).fold(0, (sum, count) => sum + count);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.01), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            AppStrings.popularCategories,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
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
                    painter: _DonutChartPainter(values, colors),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(totalSales.toString(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                        const Text('Items', style: TextStyle(fontSize: 9, color: AppColors.textGrey)),
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
          ]
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
            Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Text(name, style: const TextStyle(fontSize: 12, color: AppColors.textGrey, fontWeight: FontWeight.w500)),
          ],
        ),
        Text(percentage, style: const TextStyle(fontSize: 12, color: AppColors.textDark, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildUserGrowthCard() {
    final growth = _stats!.userStats.userGrowth;
    final List<double> dataPoints = growth.map((g) => g.count.toDouble()).toList();
    final List<String> labels = growth.map((g) => g.month).toList();

    // Map point values proportionally to canvas height
    double maxVal = dataPoints.fold(1.0, (m, v) => v > m ? v : m);
    final scaledPoints = dataPoints.map((v) => maxVal > 0 ? (v / maxVal) : 0.0).toList();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.01), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            AppStrings.memberGrowth,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
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
              painter: _LineChartPainter(
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
                style: const TextStyle(fontSize: 10, color: AppColors.textGrey, fontWeight: FontWeight.bold),
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
    return _HoverMenuCard(
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
                          color: isIncrease ? AppColors.iconGreen : AppColors.alertRed,
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

class _HoverMenuCard extends StatefulWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _HoverMenuCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  State<_HoverMenuCard> createState() => _HoverMenuCardState();
}

class _HoverMenuCardState extends State<_HoverMenuCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isHovered ? widget.color.withValues(alpha: 0.5) : const Color(0xFFE2E8F0),
              width: _isHovered ? 2 : 1,
            ),
            boxShadow: [
              if (_isHovered)
                BoxShadow(
                  color: widget.color.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              else
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.01),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: widget.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(widget.icon, color: widget.color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.subtitle,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textGrey,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: _isHovered ? widget.color : AppColors.textGrey,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SystemSettingsDialog extends StatefulWidget {
  const _SystemSettingsDialog();

  @override
  State<_SystemSettingsDialog> createState() => _SystemSettingsDialogState();
}

class _SystemSettingsDialogState extends State<_SystemSettingsDialog> {
  bool _maintenanceMode = false;
  bool _allowRegister = true;
  bool _sandboxPayments = true;
  bool _kafkaLogging = false;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.85, end: 1.0),
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: Opacity(
            opacity: ((scale - 0.85) / 0.15).clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titlePadding: EdgeInsets.zero,
        contentPadding: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                decoration: const BoxDecoration(
                  color: Color(0xFFF8FAFC),
                  border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          AppStrings.systemSettingsTitle,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Manage global environment parameters',
                          style: TextStyle(fontSize: 12, color: AppColors.textGrey),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20, color: AppColors.textGrey),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    SwitchListTile(
                      value: _maintenanceMode,
                      activeThumbColor: AppColors.primary,
                      title: const Text('Maintenance Mode', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: const Text('Render storefront offline for deployment activities', style: TextStyle(fontSize: 12)),
                      onChanged: (val) => setState(() => _maintenanceMode = val),
                    ),
                    const Divider(height: 24),
                    SwitchListTile(
                      value: _allowRegister,
                      activeThumbColor: AppColors.primary,
                      title: const Text('Allow Registrations', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: const Text('Allow new customer/seller registrations on auth endpoints', style: TextStyle(fontSize: 12)),
                      onChanged: (val) => setState(() => _allowRegister = val),
                    ),
                    const Divider(height: 24),
                    SwitchListTile(
                      value: _sandboxPayments,
                      activeThumbColor: AppColors.primary,
                      title: const Text('Sandbox Payments', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: const Text('Route transaction requests through simulated test gateways', style: TextStyle(fontSize: 12)),
                      onChanged: (val) => setState(() => _sandboxPayments = val),
                    ),
                    const Divider(height: 24),
                    SwitchListTile(
                      value: _kafkaLogging,
                      activeThumbColor: AppColors.primary,
                      title: const Text('Kafka Trace Debug', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: const Text('Enable trace logging for publish/subscribe microservice pipelines', style: TextStyle(fontSize: 12)),
                      onChanged: (val) => setState(() => _kafkaLogging = val),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                color: const Color(0xFFF8FAFC),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel', style: TextStyle(color: AppColors.textGrey, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Cấu hình đã được lưu thành công!'), backgroundColor: Colors.green),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      ),
                      child: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SystemLogsDialog extends StatelessWidget {
  const _SystemLogsDialog();

  @override
  Widget build(BuildContext context) {
    final List<String> mockLogs = [
      '2026-06-07T19:10:20.804Z [gateway-service] INFO - Route mapped: /api/admin/users/** -> http://user-service:8081',
      '2026-06-07T19:10:44.026Z [user-service] INFO - Connection initialized successfully with Postgres on shopease-db',
      '2026-06-07T19:10:52.608Z [authentication-service] INFO - Token validation request processed for user buyer@shopease.local',
      '2026-06-07T19:11:00.124Z [order-service] INFO - Started Saga pipeline: ReserveStockCommand for order ID SE2405150001',
      '2026-06-07T19:11:01.350Z [inventory-service] INFO - Reserved stock: Product p1 x 2 units - Transaction committed',
      '2026-06-07T19:11:02.990Z [payment-service] INFO - Processed transaction \$15.00 via mock credit card gateway - Status: SUCCESS',
      '2026-06-07T19:11:05.118Z [order-service] INFO - Completed Saga pipeline: PaymentReceivedEvent - Order SE2405150001 status -> PAID',
      '2026-06-07T19:12:30.452Z [user-service] INFO - Admin updated account details for email test_admin_mgmt_edited@shopease.local',
      '2026-06-07T19:13:00.810Z [product-service] WARN - Cache eviction triggered for product catalog due to memory bounds',
      '2026-06-07T19:14:02.100Z [gateway-service] INFO - Blocked user request: buyer@shopease.local unauthorized access to /api/admin/users',
      '2026-06-07T19:14:55.332Z [user-service] INFO - Deleted user account UUID c0974e5b-2f72-41af-8508-99d15761680b from database',
      '2026-06-07T19:15:37.012Z [gateway-service] INFO - Route matched: GET /api/admin/users (200 OK) - Time elapsed: 14ms',
    ];

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.85, end: 1.0),
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: Opacity(
            opacity: ((scale - 0.85) / 0.15).clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titlePadding: EdgeInsets.zero,
        contentPadding: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        content: SizedBox(
          width: 700,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                decoration: const BoxDecoration(
                  color: Color(0xFF1E293B),
                  border: Border(bottom: BorderSide(color: Color(0xFF334155))),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          AppStrings.gatewayLogs,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Realtime microservice routing trace logs',
                          style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20, color: Color(0xFF94A3B8)),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Container(
                color: const Color(0xFF0F172A),
                height: 350,
                padding: const EdgeInsets.all(16),
                child: ListView.builder(
                  itemCount: mockLogs.length,
                  itemBuilder: (context, index) {
                    final log = mockLogs[index];
                    Color logColor = const Color(0xFF38BDF8);
                    if (log.contains('WARN')) {
                      logColor = const Color(0xFFFBBF24);
                    } else if (log.contains('SUCCESS')) {
                      logColor = const Color(0xFF34D399);
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6.0),
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                            height: 1.4,
                          ),
                          children: [
                            TextSpan(
                              text: log.substring(0, 24),
                              style: const TextStyle(color: Color(0xFF64748B)),
                            ),
                            TextSpan(
                              text: log.substring(24),
                              style: TextStyle(color: logColor),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                color: const Color(0xFF1E293B),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF1E293B),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      ),
                      child: const Text('Close Terminal', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  final List<double> values;
  final List<Color> colors;

  _DonutChartPainter(this.values, this.colors);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final strokeWidth = radius * 0.35;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    double total = values.fold(0, (sum, value) => sum + value);
    if (total == 0) return;

    double startAngle = -3.141592653589793 / 2;
    for (int i = 0; i < values.length; i++) {
      final sweepAngle = (values[i] / total) * 3.141592653589793 * 2;
      paint.color = colors[i % colors.length];
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _LineChartPainter extends CustomPainter {
  final List<double> dataPoints;
  final Color lineColor;
  final Color fillColor;

  _LineChartPainter(this.dataPoints, this.lineColor, this.fillColor);

  @override
  void paint(Canvas canvas, Size size) {
    if (dataPoints.isEmpty) return;

    final width = size.width;
    final height = size.height;
    final stepX = dataPoints.length > 1 ? width / (dataPoints.length - 1) : width;

    final linePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..isAntiAlias = true;

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final path = Path();
    final fillPath = Path();

    final startX = 0.0;
    final startY = height - (dataPoints[0] * height * 0.8) - 10;
    path.moveTo(startX, startY);
    fillPath.moveTo(0, height);
    fillPath.lineTo(startX, startY);

    for (int i = 1; i < dataPoints.length; i++) {
      final x = i * stepX;
      final y = height - (dataPoints[i] * height * 0.8) - 10;

      final prevX = (i - 1) * stepX;
      final prevY = height - (dataPoints[i - 1] * height * 0.8) - 10;
      final controlX1 = prevX + (stepX / 2);
      final controlY1 = prevY;
      final controlX2 = prevX + (stepX / 2);
      final controlY2 = y;

      path.cubicTo(controlX1, controlY1, controlX2, controlY2, x, y);
      fillPath.cubicTo(controlX1, controlY1, controlX2, controlY2, x, y);
    }

    fillPath.lineTo(width, height);
    fillPath.close();

    final gridPaint = Paint()
      ..color = const Color(0xFFF1F5F9)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    for (int i = 1; i < 4; i++) {
      final h = (height / 4) * i;
      canvas.drawLine(Offset(0, h), Offset(width, h), gridPaint);
    }

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);

    final dotPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;
    final dotBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    for (int i = 0; i < dataPoints.length; i++) {
      final x = i * stepX;
      final y = height - (dataPoints[i] * height * 0.8) - 10;
      canvas.drawCircle(Offset(x, y), 5, dotBorderPaint);
      canvas.drawCircle(Offset(x, y), 3.5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
