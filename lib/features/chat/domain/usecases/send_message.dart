import '../repositories/chat_repository.dart';
import '../entities/chat_message.dart';

class SendMessage {
  final ChatRepository repository;

  SendMessage(this.repository);

  Future<void> call(String conversationId, ChatMessage message) {
    return repository.sendMessage(conversationId, message);
  }
}