class ChatMessage {
  final String id;
  final String senderName;
  final String senderImageUrl;
  final String messageText;
  final String time;
  final bool isMe;
  final bool isRead;

  const ChatMessage({
    required this.id,
    required this.senderName,
    required this.senderImageUrl,
    required this.messageText,
    required this.time,
    required this.isMe,
    this.isRead = true,
  });
}

class ChatRoom {
  final String id;
  final String name;
  final String imageUrl;
  final String lastMessage;
  final String time;
  final int unreadCount;
  final bool isActive;
  final List<ChatMessage> messages;

  const ChatRoom({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.lastMessage,
    required this.time,
    required this.unreadCount,
    this.isActive = false,
    required this.messages,
  });
}
