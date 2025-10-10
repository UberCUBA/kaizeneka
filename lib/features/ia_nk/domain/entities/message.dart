class Message {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final String? model; // Para respuestas de IA

  Message({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.model,
  });
}