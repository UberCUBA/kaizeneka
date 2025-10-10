import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/repositories/chat_repository.dart';
import '../../domain/entities/message.dart' as domain_message;
import '../models/chat_request_model.dart';
import '../models/chat_response_model.dart' as response_model;

class ChatRepositoryImpl implements ChatRepository {
  static const String _baseUrl = 'https://openrouter.ai/api/v1';
  static const String _apiKey = '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';
  static const String _defaultModel = 'x-ai/grok-code-fast-1';

  @override
  Future<domain_message.Message> sendMessage(String userMessage, String model) async {
    try {
      final request = ChatRequestModel(
        model: model.isNotEmpty ? model : _defaultModel,
        messages: [
          ChatMessage(role: 'user', content: userMessage),
        ],
      );

      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final chatResponse = response_model.ChatResponseModel.fromJson(responseData);

        if (chatResponse.choices.isNotEmpty) {
          final aiMessage = chatResponse.choices.first.message;
          return domain_message.Message(
            id: chatResponse.id,
            content: aiMessage.content,
            isUser: false,
            timestamp: DateTime.now(),
            model: chatResponse.model,
          );
        } else {
          throw Exception('No response from AI');
        }
      } else {
        throw Exception('Failed to get response: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error sending message: $e');
    }
  }
}