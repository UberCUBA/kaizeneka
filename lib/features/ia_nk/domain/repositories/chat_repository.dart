import '../entities/message.dart';
import '../entities/ai_model.dart';
import '../../data/models/chat_request_model.dart';

abstract class ChatRepository {
  Future<Message> sendMessage(String userMessage, String model, {FileAttachment? file});
  Future<List<AIModel>> getAvailableModels();
}