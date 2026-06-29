package com.shopease.chat.controller;

import com.shopease.chat.model.ChatMessage;
import com.shopease.chat.model.ChatRoom;
import com.shopease.chat.repository.ChatMessageRepository;
import com.shopease.chat.repository.ChatRoomRepository;
import com.shopease.common.dto.ApiResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.web.bind.annotation.*;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/chats")
public class ChatController {

    @Autowired
    private ChatRoomRepository chatRoomRepository;

    @Autowired
    private ChatMessageRepository chatMessageRepository;

    @GetMapping
    public ApiResponse<List<ChatRoom>> getMyChats(@RequestHeader("X-User-Id") String userId) {
        return ApiResponse.ok(chatRoomRepository.findByParticipant1IdOrParticipant2IdOrderByLastMessageAtDesc(userId, userId));
    }

    @PostMapping("/room")
    public ApiResponse<ChatRoom> getOrCreateRoom(@RequestHeader("X-User-Id") String userId, @RequestParam String targetUserId) {
        return ApiResponse.ok(chatRoomRepository.findByParticipant1IdAndParticipant2Id(userId, targetUserId)
            .orElseGet(() -> chatRoomRepository.findByParticipant1IdAndParticipant2Id(targetUserId, userId)
                .orElseGet(() -> chatRoomRepository.save(ChatRoom.builder()
                        .participant1Id(userId)
                        .participant2Id(targetUserId)
                        .createdAt(Instant.now())
                        .lastMessageAt(Instant.now())
                        .build()))));
    }

    @GetMapping("/{roomId}/messages")
    public ApiResponse<List<ChatMessage>> getMessages(@PathVariable UUID roomId) {
        return ApiResponse.ok(chatMessageRepository.findByRoomIdOrderBySentAtAsc(roomId));
    }

    @Autowired
    private org.springframework.messaging.simp.SimpMessagingTemplate messagingTemplate;

    @PostMapping("/{roomId}/messages")
    public ApiResponse<ChatMessage> sendMessage(
            @RequestHeader("X-User-Id") String userId,
            @PathVariable UUID roomId,
            @RequestBody String messageText) {
        
        ChatRoom room = chatRoomRepository.findById(roomId)
                .orElseThrow(() -> new RuntimeException("Room not found"));
        
        ChatMessage msg = ChatMessage.builder()
                .roomId(roomId)
                .senderId(userId)
                .messageText(messageText)
                .sentAt(Instant.now())
                .isRead(false)
                .build();
        
        chatMessageRepository.save(msg);
        
        room.setLastMessage(messageText);
        room.setLastMessageAt(Instant.now());
        chatRoomRepository.save(room);
        
        // Broadcast to websocket topic
        messagingTemplate.convertAndSend("/topic/chat/" + roomId, msg);
        
        return ApiResponse.ok(msg);
    }

    @org.springframework.messaging.handler.annotation.MessageMapping("/chat/{roomId}/typing")
    public void sendTypingIndicator(@org.springframework.messaging.handler.annotation.DestinationVariable UUID roomId, String senderId) {
        messagingTemplate.convertAndSend("/topic/chat/" + roomId + "/typing", senderId);
    }
}
