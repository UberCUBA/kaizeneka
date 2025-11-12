import 'dart:async';
import '../repositories/chat_repository.dart';
import '../entities/chat_message.dart';

class GetMessages {
  final ChatRepository repository;

  GetMessages(this.repository);

  Stream<List<ChatMessage>> call(String conversationId) {
    return repository.getMessages(conversationId);
  }
}