import 'chat_message.dart';

class ChatConversation {
  final String id;
  final String name;
  final String? avatar;
  final bool isGroup;
  final DateTime lastMessageTime;
  final String? lastMessagePreview;
  final int unreadCount;
  final List<ChatMessage> messages;
  final bool isOnline;
  final DateTime? lastSeen;

  const ChatConversation({
    required this.id,
    required this.name,
    this.avatar,
    this.isGroup = false,
    required this.lastMessageTime,
    this.lastMessagePreview,
    this.unreadCount = 0,
    this.messages = const [],
    this.isOnline = false,
    this.lastSeen,
  });

  ChatConversation copyWith({
    String? id,
    String? name,
    String? avatar,
    bool? isGroup,
    DateTime? lastMessageTime,
    String? lastMessagePreview,
    int? unreadCount,
    List<ChatMessage>? messages,
    bool? isOnline,
    DateTime? lastSeen,
  }) {
    return ChatConversation(
      id: id ?? this.id,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      isGroup: isGroup ?? this.isGroup,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      lastMessagePreview: lastMessagePreview ?? this.lastMessagePreview,
      unreadCount: unreadCount ?? this.unreadCount,
      messages: messages ?? this.messages,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }
}