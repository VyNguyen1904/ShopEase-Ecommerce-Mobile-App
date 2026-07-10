import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/models/chat_message.dart';
import '../../../core/services/chat_service.dart';
import '../../../core/services/auth_service.dart';
import '../widgets/chat_message_bubble.dart';
import '../widgets/chat_room_app_bar.dart';
import '../widgets/chat_input_bar.dart';

class ChatRoomScreen extends StatefulWidget {
  final String roomId;
  final ChatRoom? initialRoom; // Optional: can be passed to avoid refetching basic info

  const ChatRoomScreen({super.key, required this.roomId, this.initialRoom});

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _chatScrollController = ScrollController();
  
  ChatRoom? _room;
  bool _isLoading = true;
  String? _myUserId;
  final ApiChatService _apiChatService = ApiChatService();
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _room = widget.initialRoom;
    _loadRoomData();
  }

  @override
  void dispose() {
    _apiChatService.disconnectWebSocket();
    _messageController.dispose();
    _chatScrollController.dispose();
    super.dispose();
  }

  String _formatTime(String? isoTime) {
    if (isoTime == null || isoTime.isEmpty) return '';
    try {
      final dt = DateTime.parse(isoTime).toLocal();
      return DateFormat('HH:mm').format(dt);
    } catch (_) {
      return '';
    }
  }

  Future<void> _loadRoomData() async {
    try {
      if (_room == null) setState(() => _isLoading = true);
      
      final profile = await _authService.getProfile();
      _myUserId = profile.id;
      final rawRooms = await _apiChatService.getMyChats();
      final roomData = rawRooms.firstWhere((r) => r['id'] == widget.roomId, orElse: () => null);
      
      if (roomData == null) throw Exception('Room not found');

      final targetId = roomData['participant1Id'] == _myUserId ? roomData['participant2Id'] : roomData['participant1Id'];
      final targetUser = targetId == 'SYSTEM' ? null : await _authService.getUserById(targetId);
      
      final rawMsgs = await _apiChatService.getMessages(widget.roomId);
      List<ChatMessage> msgs = rawMsgs.map<ChatMessage>((m) {
        final isMe = m['senderId'] == _myUserId;
        return ChatMessage(
          id: m['id'],
          senderName: isMe ? AppStrings.you : (targetUser?.fullName ?? AppStrings.system),
          senderImageUrl: isMe ? '' : (targetUser?.avatar ?? 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150'),
          messageText: m['messageText'],
          time: _formatTime(m['sentAt']),
          isMe: isMe,
        );
      }).toList();

      if (mounted) {
        setState(() {
          _room = ChatRoom(
            id: roomData['id'],
            name: targetUser?.fullName ?? AppStrings.system,
            imageUrl: targetUser?.avatar ?? 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
            lastMessage: roomData['lastMessage'] ?? '',
            time: _formatTime(roomData['lastMessageAt']),
            unreadCount: 0,
            messages: msgs,
            isActive: true,
          );
          _isLoading = false;
        });
        
        // Connect WebSocket
        _apiChatService.connectWebSocket(
          widget.roomId, 
          _onMessageReceived,
          onTyping: _onTypingReceived,
        );
        
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
    } catch (e) {
      debugPrint('Error loading room: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  bool _isTyping = false;
  DateTime? _lastTypingTime;
  DateTime? _lastSentTypingTime;

  void _onMessageReceived(dynamic messageBody) {
    if (!mounted || _room == null) return;
    try {
      final Map<String, dynamic> msgMap = jsonDecode(messageBody);
      if (msgMap['senderId'] == _myUserId) return;
      
      final incomingMessage = ChatMessage(
        id: msgMap['id'] ?? DateTime.now().toString(),
        senderName: _room!.name,
        senderImageUrl: _room!.imageUrl,
        messageText: msgMap['messageText'],
        time: _formatTime(msgMap['sentAt']),
        isMe: false,
      );

      setState(() {
        _isTyping = false;
        _room = ChatRoom(
          id: _room!.id,
          name: _room!.name,
          imageUrl: _room!.imageUrl,
          lastMessage: msgMap['messageText'],
          time: AppStrings.justNow,
          unreadCount: _room!.unreadCount + 1,
          isActive: _room!.isActive,
          messages: List<ChatMessage>.from(_room!.messages)..add(incomingMessage),
        );
      });

      Future.delayed(const Duration(milliseconds: 100), () {
        if (_chatScrollController.hasClients) {
          _chatScrollController.animateTo(
            _chatScrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      debugPrint('Parse message error: $e');
    }
  }

  void _onTypingReceived(String senderId) {
    if (!mounted || senderId == _myUserId) return;
    
    setState(() {
      _isTyping = true;
      _lastTypingTime = DateTime.now();
    });

    // Auto hide typing indicator after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _lastTypingTime != null) {
        final now = DateTime.now();
        if (now.difference(_lastTypingTime!).inSeconds >= 3) {
          setState(() {
            _isTyping = false;
          });
        }
      }
    });
  }

  void _onInputChanged(String text) {
    if (_room == null || _myUserId == null) return;
    
    final now = DateTime.now();
    if (_lastSentTypingTime == null || now.difference(_lastSentTypingTime!).inSeconds >= 2) {
      _apiChatService.sendTypingEvent(_room!.id, _myUserId!);
      _lastSentTypingTime = now;
    }
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _room == null) return;
    
    _messageController.clear();
    
    try {
      final sentMsg = await _apiChatService.sendMessage(_room!.id, text);
      
      final newMessage = ChatMessage(
        id: sentMsg['id'],
        senderName: AppStrings.you,
        senderImageUrl: '',
        messageText: sentMsg['messageText'],
        time: _formatTime(sentMsg['sentAt']),
        isMe: true,
      );

      setState(() {
        _room = ChatRoom(
          id: _room!.id,
          name: _room!.name,
          imageUrl: _room!.imageUrl,
          lastMessage: text,
          time: AppStrings.justNow,
          unreadCount: 0,
          isActive: _room!.isActive,
          messages: List<ChatMessage>.from(_room!.messages)..add(newMessage),
        );
      });

      Future.delayed(const Duration(milliseconds: 100), () {
        if (_chatScrollController.hasClients) {
          _chatScrollController.animateTo(
            _chatScrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      debugPrint('Error sending message: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_room == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: AppColors.textDark),
            onPressed: () => context.pop(),
          ),
        ),
        body: const Center(child: Text(AppStrings.roomNotFound)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: ChatRoomAppBar(room: _room!),
      body: Column(
        children: [
          const Divider(height: 1, color: AppColors.border),
          Expanded(
            child: ListView.builder(
              controller: _chatScrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              itemCount: _room!.messages.length,
              itemBuilder: (context, index) {
                final msg = _room!.messages[index];
                return ChatMessageBubble(msg: msg);
              },
            ),
          ),
          if (_isTyping)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.bgLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        AppStrings.typing,
                        style: TextStyle(
                          color: AppColors.textGrey,
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          SafeArea(
            bottom: true,
            child: ChatInputBar(
              controller: _messageController,
              onSend: _sendMessage,
              onChanged: _onInputChanged,
            ),
          ),
        ],
      ),
    );
  }
}
