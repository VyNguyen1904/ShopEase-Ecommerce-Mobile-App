class AdminUserStats {
  final int totalUsers;
  final int activeUsers;
  final List<MonthlyGrowth> userGrowth;

  AdminUserStats({
    required this.totalUsers,
    required this.activeUsers,
    required this.userGrowth,
  });

  factory AdminUserStats.fromJson(Map<String, dynamic> json) {
    final growthList = json['userGrowth'] as List? ?? [];
    return AdminUserStats(
      totalUsers: json['totalUsers'] as int? ?? 0,
      activeUsers: json['activeUsers'] as int? ?? 0,
      userGrowth: growthList
          .map((item) => MonthlyGrowth.fromJson(item))
          .toList(),
    );
  }
}

class MonthlyGrowth {
  final String month;
  final int count;

  MonthlyGrowth({required this.month, required this.count});

  factory MonthlyGrowth.fromJson(Map<String, dynamic> json) {
    return MonthlyGrowth(
      month: json['month'] as String? ?? '',
      count: json['count'] as int? ?? 0,
    );
  }
}

class AdminOrderStats {
  final double totalRevenue;
  final int totalOrders;
  final double aov;
  final List<DailySales> dailySales;
  final List<CategoryBreakdown> categoryBreakdown;

  AdminOrderStats({
    required this.totalRevenue,
    required this.totalOrders,
    required this.aov,
    required this.dailySales,
    required this.categoryBreakdown,
  });

  factory AdminOrderStats.fromJson(Map<String, dynamic> json) {
    final salesList = json['dailySales'] as List? ?? [];
    final categoryList = json['categoryBreakdown'] as List? ?? [];
    return AdminOrderStats(
      totalRevenue: (json['totalRevenue'] as num? ?? 0.0).toDouble(),
      totalOrders: json['totalOrders'] as int? ?? 0,
      aov: (json['aov'] as num? ?? 0.0).toDouble(),
      dailySales: salesList.map((item) => DailySales.fromJson(item)).toList(),
      categoryBreakdown: categoryList
          .map((item) => CategoryBreakdown.fromJson(item))
          .toList(),
    );
  }
}

class DailySales {
  final String date;
  final double revenue;
  final int ordersCount;

  DailySales({
    required this.date,
    required this.revenue,
    required this.ordersCount,
  });

  factory DailySales.fromJson(Map<String, dynamic> json) {
    return DailySales(
      date: json['date'] as String? ?? '',
      revenue: (json['revenue'] as num? ?? 0.0).toDouble(),
      ordersCount: json['ordersCount'] as int? ?? 0,
    );
  }
}

class CategoryBreakdown {
  final String name;
  final int salesCount;
  final double percentage;

  CategoryBreakdown({
    required this.name,
    required this.salesCount,
    required this.percentage,
  });

  factory CategoryBreakdown.fromJson(Map<String, dynamic> json) {
    return CategoryBreakdown(
      name: json['name'] as String? ?? '',
      salesCount: json['salesCount'] as int? ?? 0,
      percentage: (json['percentage'] as num? ?? 0.0).toDouble(),
    );
  }
}

class CombinedAdminStats {
  final AdminUserStats userStats;
  final AdminOrderStats orderStats;

  CombinedAdminStats({required this.userStats, required this.orderStats});
}
