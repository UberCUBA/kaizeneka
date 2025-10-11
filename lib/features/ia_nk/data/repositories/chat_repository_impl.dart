import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../domain/repositories/chat_repository.dart';
import '../../domain/entities/message.dart' as domain_message;
import '../../domain/entities/ai_model.dart' as domain_model;
import '../models/chat_request_model.dart';
import '../models/chat_response_model.dart' as response_model;
import '../models/models_response_model.dart' as models_response;

class ChatRepositoryImpl implements ChatRepository {
  static const String _baseUrl = 'https://openrouter.ai/api/v1';
  static const String _apiKey = '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';
  static const String _defaultModel = 'x-ai/grok-code-fast-1';

  @override
  Future<domain_message.Message> sendMessage(String userMessage, String model, {FileAttachment? file}) async {
    try {
      // Preparar el contenido del mensaje
      dynamic messageContent = userMessage;

      // Si hay un archivo, preparar contenido multimodal
      if (file != null) {
        if (file.mimeType.startsWith('image/')) {
          // Para imágenes, convertir a base64 y usar formato multimodal
          final base64Image = base64Encode(file.bytes);
          messageContent = [
            {"type": "text", "text": userMessage.isNotEmpty ? userMessage : "Analiza esta imagen"},
            {
              "type": "image_url",
              "image_url": {"url": "data:${file.mimeType};base64,$base64Image"}
            }
          ];
        } else {
          // Para otros archivos, por ahora solo agregar el nombre
          messageContent = "$userMessage\n[Archivo adjunto: ${file.name}]";
        }
      }

      final request = ChatRequestModel(
        model: model.isNotEmpty ? model : _defaultModel,
        messages: [
          ChatMessage(role: 'user', content: messageContent),
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

  @override
  Future<List<domain_model.AIModel>> getAvailableModels() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/models'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // Debug: print response structure
        print('Models API Response: $responseData');

        final modelsResponse = models_response.ModelsResponseModel.fromJson(responseData);

        return modelsResponse.data.map((model) {
          return domain_model.AIModel(
            id: model.id,
            name: model.name,
            description: model.description,
            isFree: model.isFree,
            isPaid: model.isPaid,
          );
        }).toList();
      } else {
        print('Models API Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to get models: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting models: $e');
      throw Exception('Error getting models: $e');
    }
  }
}