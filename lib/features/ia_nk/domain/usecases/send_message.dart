import '../repositories/chat_repository.dart';
import '../entities/message.dart';
import '../../data/models/chat_request_model.dart';

class SendMessage {
  final ChatRepository repository;

  SendMessage(this.repository);

  Future<Message> call(String userMessage, String model, {FileAttachment? file}) async {
    return await repository.sendMessage(userMessage, model, file: file);
  }
}