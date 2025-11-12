class ChatMessageModel {
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

  const ChatMessageModel({
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
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      userAvatar: json['userAvatar'] as String?,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      type: MessageType.values.firstWhere(
        (type) => type.toString().split('.').last == json['type'],
        orElse: () => MessageType.text,
      ),
      replyToMessageId: json['replyToMessageId'] as String?,
      voiceUrl: json['voiceUrl'] as String?,
      voiceDuration: json['voiceDuration'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'type': type.toString().split('.').last,
      'replyToMessageId': replyToMessageId,
      'voiceUrl': voiceUrl,
      'voiceDuration': voiceDuration,
    };
  }
}

enum MessageType {
  text,
  voice,
  image,
  file,
}