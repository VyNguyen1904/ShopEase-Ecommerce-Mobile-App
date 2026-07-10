import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/chat_message.dart';

class ChatMessageBubble extends StatelessWidget {
  final ChatMessage msg;

  const ChatMessageBubble({super.key, required this.msg});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: msg.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment: msg.isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
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
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  msg.time,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textLight,
                  ),
                ),
                if (msg.isMe) ...[
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.done_all,
                    color: AppColors.primary,
                    size: 14,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
