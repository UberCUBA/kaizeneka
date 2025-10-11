import 'message.dart';

class ChatSession {
  final String id;
  final String title;
  final List<Message> messages;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String model;

  ChatSession({
    required this.id,
    required this.title,
    required this.messages,
    required this.createdAt,
    required this.updatedAt,
    required this.model,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'messages': messages.map((msg) => {
        'id': msg.id,
        'content': msg.content,
        'isUser': msg.isUser,
        'timestamp': msg.timestamp.toIso8601String(),
        'model': msg.model,
      }).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'model': model,
    };
  }

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      id: json['id'],
      title: json['title'],
      messages: (json['messages'] as List).map((msg) => Message(
        id: msg['id'],
        content: msg['content'],
        isUser: msg['isUser'],
        timestamp: DateTime.parse(msg['timestamp']),
        model: msg['model'],
      )).toList(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      model: json['model'],
    );
  }

  String get preview => messages.isNotEmpty ? messages.first.content : 'Nueva conversación';
}