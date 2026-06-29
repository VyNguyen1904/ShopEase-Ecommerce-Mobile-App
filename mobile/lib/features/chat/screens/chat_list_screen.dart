import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/services/chat_service.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final ApiChatService _chatService = ApiChatService();
  List<dynamic> _chatRooms = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChats();
  }

  Future<void> _loadChats() async {
    try {
      final rooms = await _chatService.getMyChats();
      setState(() {
        _chatRooms = rooms;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể tải danh sách chat: $e')),
        );
      }
    }
  }

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
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
        title: const Text(
          AppStrings.messages,
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.bgLight,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.border),
              ),
              child: const Row(
                children: [
                  Icon(Icons.search, color: AppColors.textGrey, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      AppStrings.searchChat,
                      style: TextStyle(
                        color: AppColors.textLight,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _chatRooms.isEmpty
                    ? const Center(
                        child: Text(
                          'Chưa có đoạn chat nào',
                          style: TextStyle(color: AppColors.textLight),
                        ),
                      )
                    : ListView.separated(
                        itemCount: _chatRooms.length,
                        separatorBuilder: (context, index) => const Divider(
                          height: 1,
                          indent: 80,
                          endIndent: 16,
                          color: AppColors.border,
                        ),
                        itemBuilder: (context, index) {
                          final room = _chatRooms[index];
                          final p1 = room['participant1Id'];
                          final p2 = room['participant2Id'];
                          final otherUserId = (p1 != null && p1 != 'SYSTEM') ? p1 : p2;
                          final roomName = otherUserId != null ? 'User ${otherUserId.toString().substring(0, 5)}' : 'Khách';
                          final lastMessage = 'Chat ID: ${room['id'].toString().substring(0, 5)}';
                          // For now, no unread count from API
                          final unreadCount = 0;

                          return ListTile(
                            onTap: () {
                              context.push('/chats/${room['id']}');
                            },
                            leading: const CircleAvatar(
                              radius: 24,
                              backgroundColor: AppColors.bgLight,
                              child: Icon(
                                Icons.person,
                                color: AppColors.textGrey,
                                size: 28,
                              ),
                            ),
                            title: Text(
                              roomName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                              ),
                            ),
                            subtitle: Text(
                              lastMessage,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14,
                                color: unreadCount > 0 ? AppColors.textDark : AppColors.textGrey,
                                fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
