package com.shopease.chat.repository;

import com.shopease.chat.model.ChatRoom;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Repository
public interface ChatRoomRepository extends JpaRepository<ChatRoom, UUID> {
    List<ChatRoom> findByParticipant1IdOrParticipant2IdOrderByLastMessageAtDesc(String p1, String p2);
    Optional<ChatRoom> findByParticipant1IdAndParticipant2Id(String p1, String p2);
}
