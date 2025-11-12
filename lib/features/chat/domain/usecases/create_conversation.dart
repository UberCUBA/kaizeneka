import '../repositories/chat_repository.dart';
import '../entities/chat_conversation.dart';

class CreateConversation {
  final ChatRepository repository;

  CreateConversation(this.repository);

  Future<void> call(ChatConversation conversation) {
    return repository.createConversation(conversation);
  }
}