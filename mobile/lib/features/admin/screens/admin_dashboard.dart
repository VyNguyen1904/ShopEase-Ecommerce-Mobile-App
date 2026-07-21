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
                const AdminDashboardHeader(),
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
                  AdminOverviewGrid(stats: _stats!),
                  const SizedBox(height: 32),

                  // 3. Double Chart Grid Row (Bar Chart & Donut Chart)
                  AdminChartsGrid(stats: _stats!),
                  const SizedBox(height: 24),

                  // 4. Line Chart Section (User Growth)
                  AdminUserGrowthCard(stats: _stats!),
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
                  AdminQuickActionsGrid(
                    onSettings: () => _showSettingsDialog(context),
                    onLogs: () => _showLogsDialog(context),
                  ),
                  const SizedBox(height: 40),
                ],
              ],
            ),
          ),
        ),
      ),
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
}
