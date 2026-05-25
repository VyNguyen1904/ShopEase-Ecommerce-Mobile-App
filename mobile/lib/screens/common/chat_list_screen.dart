import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../models/chat_message.dart';

class ChatListScreen extends StatefulWidget {
  final VoidCallback onBack;

  const ChatListScreen({super.key, required this.onBack});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  ChatRoom? _selectedRoom;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _chatScrollController = ScrollController();

  // Helper state to allow sending messages in demo chat room
  late List<ChatRoom> _chatRooms;

  @override
  void initState() {
    super.initState();
    // Copy the mock chat rooms into mutable state so the user can interact
    _chatRooms = List.from(mockChatRooms);
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty || _selectedRoom == null) return;

    final newMessage = ChatMessage(
      id: DateTime.now().toString(),
      senderName: 'Jane Doe',
      senderImageUrl: '',
      messageText: text,
      time: '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}',
      isMe: true,
    );

    setState(() {
      // Find the index of current active room
      final roomIndex = _chatRooms.indexWhere((r) => r.id == _selectedRoom!.id);
      if (roomIndex != -1) {
        final currentRoom = _chatRooms[roomIndex];
        final updatedMessages = List<ChatMessage>.from(currentRoom.messages)..add(newMessage);
        
        final updatedRoom = ChatRoom(
          id: currentRoom.id,
          name: currentRoom.name,
          imageUrl: currentRoom.imageUrl,
          lastMessage: text,
          time: 'Vừa xong',
          unreadCount: 0,
          isActive: currentRoom.isActive,
          messages: updatedMessages,
        );

        _chatRooms[roomIndex] = updatedRoom;
        _selectedRoom = updatedRoom;
      }
    });

    _messageController.clear();
    
    // Auto scroll to bottom
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_chatScrollController.hasClients) {
        _chatScrollController.animateTo(
          _chatScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedRoom != null) {
      return _buildChatRoomView();
    }
    return _buildChatListView();
  }

  // 1. Chat List View (Common_Sceen/6.png)
  Widget _buildChatListView() {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: widget.onBack,
        ),
        title: const Text(
          'Tin nhắn',
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search box (Common_Sceen/6.png)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(
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
                            'Tìm kiếm cuộc trò chuyện...',
                            style: TextStyle(color: AppColors.textLight, fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.bgLight,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(Icons.notifications_none, color: AppColors.textDark, size: 22),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Rooms List
          Expanded(
            child: ListView.separated(
              itemCount: _chatRooms.length,
              separatorBuilder: (context, index) => const Divider(
                height: 1,
                indent: 80,
                endIndent: 16,
                color: AppColors.border,
              ),
              itemBuilder: (context, index) {
                final room = _chatRooms[index];
                return ListTile(
                  onTap: () {
                    setState(() {
                      _selectedRoom = room;
                    });
                  },
                  leading: Stack(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: NetworkImage(room.imageUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      if (room.isActive)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: AppColors.iconGreen,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                    ],
                  ),
                  title: Text(
                    room.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  subtitle: Text(
                    room.lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      color: room.unreadCount > 0 ? AppColors.textDark : AppColors.textGrey,
                      fontWeight: room.unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        room.time,
                        style: const TextStyle(fontSize: 11, color: AppColors.textLight),
                      ),
                      const SizedBox(height: 6),
                      if (room.unreadCount > 0)
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${room.unreadCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // 2. Chat Room Conversation View (Common_Sceen/7.png)
  Widget _buildChatRoomView() {
    final room = _selectedRoom!;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textDark, size: 20),
          onPressed: () {
            setState(() {
              _selectedRoom = null;
            });
          },
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            // Header avatar with active indicator status
            Stack(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: NetworkImage(room.imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                if (room.isActive)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 11,
                      height: 11,
                      decoration: BoxDecoration(
                        color: AppColors.iconGreen,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  room.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  room.isActive ? 'Đang hoạt động' : 'Ngoại tuyến',
                  style: TextStyle(
                    fontSize: 11,
                    color: room.isActive ? AppColors.iconGreen : AppColors.textLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.call, color: AppColors.textDark, size: 22),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: AppColors.textDark, size: 22),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          const Divider(height: 1, color: AppColors.border),
          // Chat history bubbles
          Expanded(
            child: ListView.builder(
              controller: _chatScrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              itemCount: room.messages.length,
              itemBuilder: (context, index) {
                final msg = room.messages[index];
                return _buildMessageBubble(msg);
              },
            ),
          ),
          // Bottom send row (Common_Sceen/7.png)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Input panel
                Expanded(
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.bgLight,
                      borderRadius: BorderRadius.circular(26),
                      border: Border.all(color: AppColors.border),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            style: const TextStyle(fontSize: 15, color: AppColors.textDark),
                            decoration: const InputDecoration(
                              hintText: 'Nhập tin nhắn...',
                              hintStyle: TextStyle(color: AppColors.textLight),
                              border: InputBorder.none,
                            ),
                            onSubmitted: (_) => _sendMessage(),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.sentiment_satisfied_alt_outlined, color: AppColors.textGrey, size: 24),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Orange Send Button
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: const BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(Icons.send, color: Colors.white, size: 20),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg) {
    return Align(
      alignment: msg.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment: msg.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // Bubble box
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: msg.isMe ? AppColors.primary : AppColors.bgLight,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(msg.isMe ? 16 : 4),
                  bottomRight: Radius.circular(msg.isMe ? 4 : 16),
                ),
              ),
              child: Text(
                msg.messageText,
                style: TextStyle(
                  color: msg.isMe ? Colors.white : AppColors.textDark,
                  fontSize: 15,
                  height: 1.3,
                ),
              ),
            ),
            const SizedBox(height: 4),
            // Timestamp with checkmark if me
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  msg.time,
                  style: const TextStyle(fontSize: 11, color: AppColors.textLight),
                ),
                if (msg.isMe) ...[
                  const SizedBox(width: 4),
                  const Icon(Icons.done_all, color: AppColors.primary, size: 14),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
