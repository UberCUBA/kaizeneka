import 'dart:async';
import '../entities/chat_conversation.dart';
import '../entities/chat_message.dart';

abstract class ChatRepository {
  // Gestión de conversaciones
  Stream<List<ChatConversation>> getConversations();
  Future<ChatConversation?> getConversation(String conversationId);
  Future<void> createConversation(ChatConversation conversation);
  Future<void> updateConversation(ChatConversation conversation);
  Future<void> deleteConversation(String conversationId);

  // Gestión de mensajes
  Stream<List<ChatMessage>> getMessages(String conversationId);
  Future<void> sendMessage(String conversationId, ChatMessage message);
  Future<void> deleteMessage(String messageId);
  Future<void> markAsRead(String conversationId);

  // Búsqueda y usuarios
  Future<List<String>> searchUsers(String query);
  Future<void> inviteUserToConversation(String conversationId, String userId);
  Future<void> leaveConversation(String conversationId);

  // Estados de conexión
  Stream<bool> getConnectionStatus();
  Future<void> connect();
  Future<void> disconnect();
}