import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';


class AdminUsers extends StatefulWidget {
  const AdminUsers({super.key});

  @override
  State<AdminUsers> createState() => _AdminUsersState();
}

class _AdminUsersState extends State<AdminUsers> {
  String _activeTab = 'Tất cả (48)';

  final List<String> _tabs = [
    'Tất cả (48)',
    'Quản trị viên (6)',
    'Nhân viên (30)',
    'Khách (12)',
  ];

  final List<Map<String, dynamic>> _users = [
    {
      'name': 'John Doe',
      'email': 'johndoe@gmail.com',
      'role': 'Quản trị viên',
      'roleColor': const Color(0xFFEAF5F6),
      'iconColor': AppColors.primary,
      'status': 'Đang hoạt động',
      'avatar': 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150&auto=format&fit=crop&q=80',
    },
    {
      'name': 'John Smith',
      'email': 'johns@gmail.com',
      'role': 'Nhân viên',
      'roleColor': const Color(0xFFEEF2F6),
      'iconColor': const Color(0xFF3B82F6),
      'status': 'Đang hoạt động',
      'avatar': 'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?w=150&auto=format&fit=crop&q=80',
    },
    {
      'name': 'Mike Lee',
      'email': 'mike@gmail.com',
      'role': 'Nhân viên',
      'roleColor': const Color(0xFFEEF2F6),
      'iconColor': const Color(0xFF3B82F6),
      'status': 'Đang hoạt động',
      'avatar': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&auto=format&fit=crop&q=80',
    },
    {
      'name': 'Tom Brown',
      'email': 'tom@gmail.com',
      'role': 'Khách',
      'roleColor': const Color(0xFFFFECE5),
      'iconColor': AppColors.accent,
      'status': 'Bị vô hiệu',
      'avatar': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150&auto=format&fit=crop&q=80',
    },
    {
      'name': 'Emma Wilson',
      'email': 'emma@gmail.com',
      'role': 'Nhân viên',
      'roleColor': const Color(0xFFEEF2F6),
      'iconColor': const Color(0xFF3B82F6),
      'status': 'Đang hoạt động',
      'avatar': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150&auto=format&fit=crop&q=80',
    },
    {
      'name': 'Alex Nguyen',
      'email': 'alex.nguyen@gmail.com',
      'role': 'Nhân viên',
      'roleColor': const Color(0xFFEEF2F6),
      'iconColor': const Color(0xFF3B82F6),
      'status': 'Đang hoạt động',
      'avatar': 'https://images.unsplash.com/photo-1560250097-0b93528c311a?w=150&auto=format&fit=crop&q=80',
    },
    {
      'name': 'Sophia Tran',
      'email': 'sophia.tran@gmail.com',
      'role': 'Khách',
      'roleColor': const Color(0xFFFFECE5),
      'iconColor': AppColors.accent,
      'status': 'Bị vô hiệu',
      'avatar': 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150&auto=format&fit=crop&q=80',
    },
    {
      'name': 'David Kim',
      'email': 'david.kim@gmail.com',
      'role': 'Nhân viên',
      'roleColor': const Color(0xFFEEF2F6),
      'iconColor': const Color(0xFF3B82F6),
      'status': 'Đang hoạt động',
      'avatar': 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&auto=format&fit=crop&q=80',
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
          'Quản lý người dùng',
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
          // 1. Tabs
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

          // 2. User list
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: _users.length,
              separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.border),
              itemBuilder: (context, index) {
                final user = _users[index];
                final isActive = user['status'] == 'Đang hoạt động';

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      // Avatar
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: NetworkImage(user['avatar']),
                            fit: BoxFit.cover,
                          ),
                          border: Border.all(color: AppColors.border, width: 1),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  user['name'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textDark,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Role Badge
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: user['roleColor'],
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    user['role'],
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: user['iconColor'],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user['email'],
                              style: const TextStyle(fontSize: 13, color: AppColors.textGrey),
                            ),
                          ],
                        ),
                      ),
                      // Status Dot
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: isActive ? AppColors.iconGreen : AppColors.alertRed,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            user['status'],
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isActive ? AppColors.iconGreen : AppColors.alertRed,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      // More icon
                      IconButton(
                        icon: const Icon(Icons.more_vert, color: AppColors.textLight, size: 20),
                        onPressed: () {},
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // 3. Export button "Xuất danh sách"
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
                icon: const Icon(Icons.download, size: 20),
                label: const Text(
                  'Xuất danh sách',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
