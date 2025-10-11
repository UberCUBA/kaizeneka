import '../repositories/chat_repository.dart';
import '../entities/ai_model.dart';

class GetAvailableModels {
  final ChatRepository repository;

  GetAvailableModels(this.repository);

  Future<List<AIModel>> call() async {
    return await repository.getAvailableModels();
  }
}