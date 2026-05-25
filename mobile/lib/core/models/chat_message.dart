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

// Mock chat messages and rooms matching the designs
final List<ChatRoom> mockChatRooms = [
  ChatRoom(
    id: 'c1',
    name: 'Trần Minh',
    imageUrl:
        'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150&auto=format&fit=crop&q=80',
    lastMessage: 'Cảm ơn bạn!',
    time: '10:28 SA',
    unreadCount: 1,
    isActive: true,
    messages: [
      ChatMessage(
        id: 'm1',
        senderName: 'Trần Minh',
        senderImageUrl:
            'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150&auto=format&fit=crop&q=80',
        messageText: 'Xin chào! Mình có thể giúp gì cho bạn?',
        time: '09:41',
        isMe: false,
      ),
      ChatMessage(
        id: 'm2',
        senderName: 'Jane Doe',
        senderImageUrl: '',
        messageText: 'Mình muốn hỏi về đơn hàng của mình.',
        time: '09:42',
        isMe: true,
      ),
      ChatMessage(
        id: 'm3',
        senderName: 'Trần Minh',
        senderImageUrl:
            'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150&auto=format&fit=crop&q=80',
        messageText: 'Dạ vâng, bạn vui lòng cung cấp mã đơn hàng giúp mình nhé.',
        time: '09:42',
        isMe: false,
      ),
      ChatMessage(
        id: 'm4',
        senderName: 'Jane Doe',
        senderImageUrl: '',
        messageText: '#DH1234567890',
        time: '09:43',
        isMe: true,
      ),
      ChatMessage(
        id: 'm5',
        senderName: 'Trần Minh',
        senderImageUrl:
            'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150&auto=format&fit=crop&q=80',
        messageText: 'Dạ mình kiểm tra đơn hàng cho bạn ngay ạ...',
        time: '09:43',
        isMe: false,
      ),
      ChatMessage(
        id: 'm6',
        senderName: 'Trần Minh',
        senderImageUrl:
            'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150&auto=format&fit=crop&q=80',
        messageText: 'Cảm ơn bạn!',
        time: '10:28 SA',
        isMe: false,
      ),
    ],
  ),
  ChatRoom(
    id: 'c2',
    name: 'Cửa hàng Sneaker',
    imageUrl:
        'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&auto=format&fit=crop&q=80',
    lastMessage: 'Chúng tôi có thể giúp gì cho bạn?',
    time: '10:21 SA',
    unreadCount: 2,
    messages: [
      ChatMessage(
        id: 'mc1',
        senderName: 'Cửa hàng Sneaker',
        senderImageUrl: '',
        messageText: 'Chúng tôi có thể giúp gì cho bạn?',
        time: '10:21 SA',
        isMe: false,
      ),
    ],
  ),
  ChatRoom(
    id: 'c3',
    name: 'John Smith',
    imageUrl:
        'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?w=150&auto=format&fit=crop&q=80',
    lastMessage: 'Dạ vâng, không có vấn đề gì.',
    time: '09:15 SA',
    unreadCount: 0,
    messages: [
      ChatMessage(
        id: 'ms1',
        senderName: 'John Smith',
        senderImageUrl: '',
        messageText: 'Dạ vâng, không có vấn đề gì.',
        time: '09:15 SA',
        isMe: false,
      ),
    ],
  ),
  ChatRoom(
    id: 'c4',
    name: 'Mike Lee',
    imageUrl:
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&auto=format&fit=crop&q=80',
    lastMessage: 'Đơn hàng ở đâu rồi bạn?',
    time: 'Hôm qua',
    unreadCount: 0,
    messages: [
      ChatMessage(
        id: 'ml1',
        senderName: 'Mike Lee',
        senderImageUrl: '',
        messageText: 'Đơn hàng ở đâu rồi bạn?',
        time: 'Hôm qua',
        isMe: false,
      ),
    ],
  ),
  ChatRoom(
    id: 'c5',
    name: 'Anna White',
    imageUrl:
        'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150&auto=format&fit=crop&q=80',
    lastMessage: 'Cảm ơn bạn nhiều nhé!',
    time: 'Hôm qua',
    unreadCount: 0,
    messages: [
      ChatMessage(
        id: 'ma1',
        senderName: 'Anna White',
        senderImageUrl: '',
        messageText: 'Cảm ơn bạn nhiều nhé!',
        time: 'Hôm qua',
        isMe: false,
      ),
    ],
  ),
];
