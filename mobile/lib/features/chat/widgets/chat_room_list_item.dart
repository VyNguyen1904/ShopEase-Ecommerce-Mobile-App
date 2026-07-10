import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/chat_message.dart';

class ChatRoomListItem extends StatelessWidget {
  final ChatRoom room;
  final VoidCallback onTap;

  const ChatRoomListItem({
    super.key,
    required this.room,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
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
        room.lastMessage.isEmpty ? 'Gửi tin nhắn...' : room.lastMessage,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 14,
          color: room.unreadCount > 0 ? AppColors.textDark : AppColors.textGrey,
          fontWeight: room.unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            room.time,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textLight,
            ),
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
  }
}
