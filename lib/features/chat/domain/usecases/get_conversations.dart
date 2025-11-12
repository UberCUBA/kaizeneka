import 'dart:async';
import '../repositories/chat_repository.dart';
import '../entities/chat_conversation.dart';

class GetConversations {
  final ChatRepository repository;

  GetConversations(this.repository);

  Stream<List<ChatConversation>> call() {
    return repository.getConversations();
  }
}