class ChatMessage {
  final String id;
  final String userId;
  final String userName;
  final String? userAvatar;
  final String content;
  final DateTime createdAt;
  final MessageType type;
  final String? replyToMessageId;
  final String? voiceUrl;
  final int? voiceDuration;
  final bool isOwn;

  const ChatMessage({
    required this.id,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.content,
    required this.createdAt,
    this.type = MessageType.text,
    this.replyToMessageId,
    this.voiceUrl,
    this.voiceDuration,
    this.isOwn = false,
  });
}

enum MessageType {
  text,
  voice,
  image,
  file,
}