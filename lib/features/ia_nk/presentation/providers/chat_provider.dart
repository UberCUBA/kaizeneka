import 'package:flutter/material.dart';
import '../../domain/usecases/send_message.dart';
import '../../domain/entities/message.dart';

class ChatProvider with ChangeNotifier {
  final SendMessage sendMessage;
  List<Message> _messages = [];
  bool _isLoading = false;
  String? _error;

  ChatProvider(this.sendMessage);

  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> sendUserMessage(String userMessage, String model) async {
    // Añadir mensaje del usuario
    final userMsg = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: userMessage,
      isUser: true,
      timestamp: DateTime.now(),
    );
    _messages.add(userMsg);
    notifyListeners();

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final aiMessage = await sendMessage.call(userMessage, model);
      _messages.add(aiMessage);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearMessages() {
    _messages.clear();
    _error = null;
    notifyListeners();
  }
}