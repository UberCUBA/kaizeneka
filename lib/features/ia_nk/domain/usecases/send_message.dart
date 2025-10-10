import '../repositories/chat_repository.dart';
import '../entities/message.dart';

class SendMessage {
  final ChatRepository repository;

  SendMessage(this.repository);

  Future<Message> call(String userMessage, String model) async {
    return await repository.sendMessage(userMessage, model);
  }
}