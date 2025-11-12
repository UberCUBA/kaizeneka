import 'dart:async';
import 'dart:math';
import '../../domain/entities/chat_conversation.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  static ChatRepositoryImpl? _instance;
  final List<ChatConversation> _mockConversations = [];
  final Map<String, List<ChatMessage>> _mockMessages = {};
  final StreamController<List<ChatConversation>> _conversationsController = StreamController<List<ChatConversation>>.broadcast();
  final StreamController<List<ChatMessage>> _messagesController = StreamController<List<ChatMessage>>.broadcast();
  final StreamController<bool> _connectionController = StreamController<bool>.broadcast();

  factory ChatRepositoryImpl() {
    _instance ??= ChatRepositoryImpl._internal();
    return _instance!;
  }

  ChatRepositoryImpl._internal() {
    _initializeMockData();
  }

  void _initializeMockData() {
    // Mock conversations
    _mockConversations.addAll([
      ChatConversation(
        id: '1',
        name: 'Ana García',
        avatar: null,
        isGroup: false,
        lastMessageTime: DateTime.now().subtract(const Duration(minutes: 5)),
        lastMessagePreview: '¿Cómo va el proyecto?',
        unreadCount: 2,
        isOnline: true,
      ),
      ChatConversation(
        id: '2',
        name: 'Carlos López',
        avatar: null,
        isGroup: false,
        lastMessageTime: DateTime.now().subtract(const Duration(hours: 1)),
        lastMessagePreview: 'Nos vemos mañana',
        unreadCount: 0,
        isOnline: false,
        lastSeen: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      ChatConversation(
        id: '3',
        name: 'Equipo de Trabajo',
        avatar: null,
        isGroup: true,
        lastMessageTime: DateTime.now().subtract(const Duration(hours: 3)),
        lastMessagePreview: 'Reunión a las 3 PM',
        unreadCount: 5,
        isOnline: false,
      ),
    ]);

    // Mock messages
    _mockMessages['1'] = [
      ChatMessage(
        id: '1',
        userId: '2',
        userName: 'Ana García',
        content: '¡Hola! ¿Cómo vas?',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        isOwn: false,
      ),
      ChatMessage(
        id: '2',
        userId: 'current_user',
        userName: 'Tú',
        content: '¡Hola Ana! Todo bien, ¿y tú?',
        createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 1)),
        isOwn: true,
      ),
      ChatMessage(
        id: '3',
        userId: '2',
        userName: 'Ana García',
        content: 'Genial! ¿Cómo va el proyecto?',
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        isOwn: false,
      ),
    ];

    _mockMessages['2'] = [
      ChatMessage(
        id: '4',
        userId: '3',
        userName: 'Carlos López',
        content: '¿Te parece bien el plan?',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        isOwn: false,
      ),
      ChatMessage(
        id: '5',
        userId: 'current_user',
        userName: 'Tú',
        content: 'Sí, me parece perfecto',
        createdAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
        isOwn: true,
      ),
      ChatMessage(
        id: '6',
        userId: '3',
        userName: 'Carlos López',
        content: 'Nos vemos mañana',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        isOwn: false,
      ),
    ];

    _mockMessages['3'] = [
      ChatMessage(
        id: '7',
        userId: '4',
        userName: 'María Rodríguez',
        content: 'Buenos días equipo',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        isOwn: false,
      ),
      ChatMessage(
        id: '8',
        userId: 'current_user',
        userName: 'Tú',
        content: '¡Buenos días!',
        createdAt: DateTime.now().subtract(const Duration(hours: 4, minutes: 45)),
        isOwn: true,
      ),
      ChatMessage(
        id: '9',
        userId: '5',
        userName: 'Pedro Martínez',
        content: 'Reunión a las 3 PM',
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        isOwn: false,
      ),
    ];
  }

  // Gestión de conversaciones
  @override
  Stream<List<ChatConversation>> getConversations() {
    _conversationsController.add(List.from(_mockConversations));
    return _conversationsController.stream;
  }

  @override
  Future<ChatConversation?> getConversation(String conversationId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      return _mockConversations.firstWhere(
        (conv) => conv.id == conversationId,
        orElse: () => throw Exception('Conversation not found'),
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> createConversation(ChatConversation conversation) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      _mockConversations.add(conversation);
      _mockMessages[conversation.id] = [];
      _conversationsController.add(List.from(_mockConversations));
    } catch (e) {
      throw Exception('Failed to create conversation: $e');
    }
  }

  @override
  Future<void> updateConversation(ChatConversation conversation) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      final index = _mockConversations.indexWhere((conv) => conv.id == conversation.id);
      if (index != -1) {
        _mockConversations[index] = conversation;
        _conversationsController.add(List.from(_mockConversations));
      }
    } catch (e) {
      throw Exception('Failed to update conversation: $e');
    }
  }

  @override
  Future<void> deleteConversation(String conversationId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      _mockConversations.removeWhere((conv) => conv.id == conversationId);
      _mockMessages.remove(conversationId);
      _conversationsController.add(List.from(_mockConversations));
    } catch (e) {
      throw Exception('Failed to delete conversation: $e');
    }
  }

  // Gestión de mensajes
  @override
  Stream<List<ChatMessage>> getMessages(String conversationId) {
    final messages = _mockMessages[conversationId] ?? [];
    _messagesController.add(messages);
    return _messagesController.stream;
  }

  @override
  Future<void> sendMessage(String conversationId, ChatMessage message) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      
      // Add message to the conversation
      final messages = _mockMessages[conversationId] ?? [];
      messages.add(message);
      _mockMessages[conversationId] = messages;
      
      // Update conversation's last message
      final convIndex = _mockConversations.indexWhere((conv) => conv.id == conversationId);
      if (convIndex != -1) {
        final updatedConv = _mockConversations[convIndex].copyWith(
          lastMessageTime: DateTime.now(),
          lastMessagePreview: message.type == MessageType.voice
            ? '🎤 Mensaje de voz'
            : message.content,
        );
        _mockConversations[convIndex] = updatedConv;
      }
      
      // Notify listeners
      _messagesController.add(List.from(messages));
      _conversationsController.add(List.from(_mockConversations));
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  @override
  Future<void> deleteMessage(String messageId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      
      for (final messages in _mockMessages.values) {
        messages.removeWhere((msg) => msg.id == messageId);
      }
      
      // Update messages stream
      for (final conversationId in _mockMessages.keys) {
        _messagesController.add(_mockMessages[conversationId] ?? []);
      }
    } catch (e) {
      throw Exception('Failed to delete message: $e');
    }
  }

  @override
  Future<void> markAsRead(String conversationId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 200));
      
      final convIndex = _mockConversations.indexWhere((conv) => conv.id == conversationId);
      if (convIndex != -1) {
        _mockConversations[convIndex] = _mockConversations[convIndex].copyWith(
          unreadCount: 0,
        );
        _conversationsController.add(List.from(_mockConversations));
      }
    } catch (e) {
      throw Exception('Failed to mark as read: $e');
    }
  }

  // Búsqueda y usuarios
  @override
  Future<List<String>> searchUsers(String query) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      
      final mockUsers = [
        'user1@example.com',
        'user2@example.com',
        'user3@example.com',
        'juan.perez@email.com',
        'maria.garcia@email.com'
      ];
      
      return mockUsers
          .where((user) => user.toLowerCase().contains(query.toLowerCase()))
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> inviteUserToConversation(String conversationId, String userId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      // Mock implementation - in real implementation would add user to conversation
    } catch (e) {
      throw Exception('Failed to invite user: $e');
    }
  }

  @override
  Future<void> leaveConversation(String conversationId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      _mockConversations.removeWhere((conv) => conv.id == conversationId);
      _mockMessages.remove(conversationId);
      _conversationsController.add(List.from(_mockConversations));
    } catch (e) {
      throw Exception('Failed to leave conversation: $e');
    }
  }

  // Estados de conexión
  @override
  Stream<bool> getConnectionStatus() {
    _connectionController.add(true); // Always connected in mock
    return _connectionController.stream;
  }

  @override
  Future<void> connect() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    _connectionController.add(true);
  }

  @override
  Future<void> disconnect() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _connectionController.add(false);
  }

  // Utility method to generate unique IDs
  String _generateId() {
    return '${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(10000)}';
  }

  void dispose() {
    _conversationsController.close();
    _messagesController.close();
    _connectionController.close();
  }
}