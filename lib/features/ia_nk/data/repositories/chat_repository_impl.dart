import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../domain/entities/message.dart' as domain_message;
import '../../domain/entities/ai_model.dart' as domain_model;
import '../models/chat_request_model.dart';
import '../models/chat_response_model.dart' as response_model;
import '../models/models_response_model.dart' as models_response;

// Custom exception for initialization errors
class NotInitializedError extends Error {
  final String message;
  NotInitializedError(this.message);

  @override
  String toString() => 'NotInitializedError: $message';
}

class ChatRepositoryImpl implements ChatRepository {
  static const String _baseUrl = 'https://openrouter.ai/api/v1';
  static const String _defaultModel = 'glm-4-9b-chat';

  // API Key - será inicializada después de cargar dotenv
  static String? _apiKey;

  // Método para inicializar la API key
  static Future<void> initialize() async {
    try {
      // dotenv ya está cargado en main.dart, solo necesitamos acceder a la variable
      _apiKey = dotenv.env['OPENROUTER_API_KEY'];
      if (_apiKey == null || _apiKey!.isEmpty) {
        throw NotInitializedError('OPENROUTER_API_KEY not found in environment variables');
      }
      print('ChatRepository initialized successfully with API key: ${_apiKey!.substring(0, 10)}...');
    } catch (e) {
      print('Error initializing ChatRepository: $e');
      rethrow;
    }
  }

  // Getter para obtener la API key
  static String get apiKey {
    if (_apiKey == null) {
      throw Exception('ChatRepository not initialized. Call initialize() first.');
    }
    return _apiKey!;
  }

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
          'Authorization': 'Bearer $apiKey',
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
        // Verificar si es un error de pago para modelos pagos
        if (response.statusCode == 402 || response.statusCode == 429) {
          // Determinar si el modelo es pago basado en el ID
          final isPaidModel = model.contains('gpt') || model.contains('claude') || model.contains('paid');
          if (isPaidModel) {
            throw Exception('¡Upsss!! Modelo IA de Pago!! Pruebe con uno Gratis...');
          }
        }
        throw Exception('Failed to get response: ${response.statusCode}');
      }
    } catch (e) {
      // Verificar si es un error de conexión a internet
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection refused') ||
          e.toString().contains('Failed host lookup') ||
          e.toString().contains('Network is unreachable') ||
          e.toString().contains('Connection timeout')) {
        throw Exception('¡Upsss!! Algo va Mal!! Revise su conexión a Internet!!');
      } else {
        throw Exception('Error sending message: $e');
      }
    }
  }

  @override
  Future<List<domain_model.AIModel>> getAvailableModels() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/models'),
        headers: {
          'Authorization': 'Bearer $apiKey',
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
      // Verificar si es un error de conexión a internet
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection refused') ||
          e.toString().contains('Failed host lookup') ||
          e.toString().contains('Network is unreachable') ||
          e.toString().contains('Connection timeout')) {
        throw Exception('¡Upsss!! Algo va Mal!! Revise su conexión a Internet!!');
      } else {
        throw Exception('Error getting models: $e');
      }
    }
  }
}