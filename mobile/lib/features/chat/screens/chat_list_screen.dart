import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/services/chat_service.dart';
import '../../../core/services/auth_service.dart';
import 'package:intl/intl.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final ApiChatService _chatService = ApiChatService();
  final AuthService _authService = AuthService();
  List<dynamic> _chatRooms = [];
  Map<String, String> _userNames = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChats();
  }

  Future<void> _loadChats() async {
    try {
      final rooms = await _chatService.getMyChats();
      final Map<String, String> names = {};
      
      for (var room in rooms) {
        final p1 = room['participant1Id'];
        final p2 = room['participant2Id'];
        final otherUserId = (p1 != null && p1 != 'SYSTEM') ? p1 : p2;
        
        if (otherUserId != null && !names.containsKey(otherUserId)) {
          try {
            final user = await _authService.getUserById(otherUserId.toString());
            names[otherUserId.toString()] = user.fullName;
          } catch (_) {
            names[otherUserId.toString()] = 'User ${otherUserId.toString().substring(0, 5)}';
          }
        }
      }

      if (mounted) {
        setState(() {
          _chatRooms = rooms;
          _userNames = names;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppStrings.loadChatsFailed}$e')),
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
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: ChatSearchBar(),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _chatRooms.isEmpty
                    ? const Center(
                        child: Text(
                          AppStrings.noChatsYet,
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
                          final otherUserId = (p1 != null && p1 != 'SYSTEM') ? p1.toString() : p2?.toString();
                          
                          final roomName = otherUserId != null ? (_userNames[otherUserId] ?? 'User ${otherUserId.substring(0, 5)}') : AppStrings.guest;
                          final lastMessage = room['lastMessage']?.toString() ?? AppStrings.noMessagesYet;
                          
                          String timeDisplay = '';
                          if (room['lastMessageAt'] != null) {
                            try {
                              final time = DateTime.parse(room['lastMessageAt']).toLocal();
                              final now = DateTime.now();
                              if (time.year == now.year && time.month == now.month && time.day == now.day) {
                                timeDisplay = DateFormat('HH:mm').format(time);
                              } else {
                                timeDisplay = DateFormat('dd/MM').format(time);
                              }
                            } catch (_) {}
                          }

                          return ChatListItem(
                            roomName: roomName,
                            lastMessage: lastMessage,
                            timeDisplay: timeDisplay,
                            onTap: () => context.push('/chats/${room['id']}'),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class ChatSearchBar extends StatelessWidget {
  const ChatSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}

class ChatListItem extends StatelessWidget {
  final String roomName;
  final String lastMessage;
  final String timeDisplay;
  final VoidCallback onTap;

  const ChatListItem({
    super.key,
    required this.roomName,
    required this.lastMessage,
    required this.timeDisplay,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
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
        style: const TextStyle(
          fontSize: 14,
          color: AppColors.textGrey,
        ),
      ),
      trailing: timeDisplay.isNotEmpty
          ? Text(
              timeDisplay,
              style: const TextStyle(fontSize: 12, color: AppColors.textLight),
            )
          : null,
    );
  }
}
