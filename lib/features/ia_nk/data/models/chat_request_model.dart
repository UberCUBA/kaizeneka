class ChatRequestModel {
  final String model;
  final List<ChatMessage> messages;

  ChatRequestModel({
    required this.model,
    required this.messages,
  });

  Map<String, dynamic> toJson() {
    return {
      'model': model,
      'messages': messages.map((msg) => msg.toJson()).toList(),
    };
  }
}

class FileAttachment {
  final String name;
  final String mimeType;
  final List<int> bytes;

  FileAttachment({
    required this.name,
    required this.mimeType,
    required this.bytes,
  });

  int get sizeInMB => (bytes.length / (1024 * 1024)).round();
}

class ChatMessage {
  final String role;
  final dynamic content; // String or List for multimodal

  ChatMessage({
    required this.role,
    required this.content,
  });

  Map<String, dynamic> toJson() {
    return {
      'role': role,
      'content': content,
    };
  }
}