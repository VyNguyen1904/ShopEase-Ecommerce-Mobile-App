import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/models/chat_message.dart';

class ChatRoomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final ChatRoom room;

  const ChatRoomAppBar({super.key, required this.room});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios,
          color: AppColors.textDark,
          size: 20,
        ),
        onPressed: () => context.pop(true),
      ),
      titleSpacing: 0,
      title: Row(
        children: [
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
                room.isActive ? AppStrings.online : AppStrings.offline,
                style: TextStyle(
                  fontSize: 11,
                  color: room.isActive
                      ? AppColors.iconGreen
                      : AppColors.textLight,
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
          icon: const Icon(
            Icons.more_vert,
            color: AppColors.textDark,
            size: 22,
          ),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
