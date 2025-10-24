import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import '../../domain/usecases/send_message.dart';
import '../../domain/usecases/get_available_models.dart';
import '../../domain/entities/message.dart';
import '../../domain/entities/ai_model.dart';
import '../../domain/entities/chat_session.dart';
import '../../data/models/chat_request_model.dart';

class ChatProvider with ChangeNotifier {
  final SendMessage sendMessage;
  final GetAvailableModels getAvailableModels;
  List<Message> _messages = [];
  bool _isLoading = false;
  String? _error;
  List<AIModel> _availableModels = [];
  bool _isLoadingModels = false;
  String _selectedModel = 'x-ai/grok-code-fast-1';
  List<ChatSession> _chatSessions = [];
  String? _currentSessionId;
  FileAttachment? _attachedFile;

  ChatProvider(this.sendMessage, this.getAvailableModels);

  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<AIModel> get availableModels => _availableModels;
  bool get isLoadingModels => _isLoadingModels;
  String get selectedModel => _selectedModel;
  List<ChatSession> get chatSessions => _chatSessions;
  String? get currentSessionId => _currentSessionId;
  FileAttachment? get attachedFile => _attachedFile;

  Future<void> loadAvailableModels() async {
    _isLoadingModels = true;
    notifyListeners();

    try {
      // Asegurarse de que dotenv esté inicializado
      _availableModels = await getAvailableModels.call();

      // Si no hay modelos, agregar algunos por defecto
      if (_availableModels.isEmpty) {
        _availableModels = [
          AIModel(
            id: 'x-ai/grok-code-fast-1',
            name: 'Grok Code Fast 1',
            description: 'Modelo rápido de código de xAI',
            isFree: true,
            isPaid: false,
          ),
          AIModel(
            id: 'openai/gpt-3.5-turbo',
            name: 'GPT-3.5 Turbo',
            description: 'Modelo versátil de OpenAI',
            isFree: false,
            isPaid: true,
          ),
        ];
      }
    } catch (e) {
      print('Error loading models: $e');
      // Verificar si es un error de conexión a internet
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection refused') ||
          e.toString().contains('Failed host lookup') ||
          e.toString().contains('Network is unreachable') ||
          e.toString().contains('Connection timeout')) {
        _error = '¡Upsss!! Algo va Mal!! Revise su conexión a Internet!!';
      } else {
        _error = 'Error al cargar modelos: $e';
      }

      // Fallback a modelos por defecto
      _availableModels = [
        AIModel(
          id: 'x-ai/grok-code-fast-1',
          name: 'Grok Code Fast 1',
          description: 'Modelo rápido de código de xAI',
          isFree: true,
          isPaid: false,
        ),
      ];
    } finally {
      _isLoadingModels = false;
      notifyListeners();
    }
  }

  void setSelectedModel(String model) {
    _selectedModel = model;
    notifyListeners();
  }

  Future<void> sendUserMessage(String userMessage) async {
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
      final aiMessage = await sendMessage.call(userMessage, _selectedModel, file: _attachedFile);
      _messages.add(aiMessage);
      // Limpiar el archivo adjunto después de enviarlo
      _attachedFile = null;
    } catch (e) {
      // Verificar si es un error de conexión a internet
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection refused') ||
          e.toString().contains('Failed host lookup') ||
          e.toString().contains('Network is unreachable') ||
          e.toString().contains('Connection timeout')) {
        _error = '¡Upsss!! Algo va Mal!! Revise su conexión a Internet!!';
      } else if (e.toString().contains('payment') || e.toString().contains('billing') || e.toString().contains('quota') || e.toString().contains('insufficient')) {
        // Verificar si es un modelo pago y hay error de pago
        final selectedModel = _availableModels.firstWhere(
          (model) => model.id == _selectedModel,
          orElse: () => AIModel(id: '', name: '', description: '', isFree: true, isPaid: false),
        );
        if (selectedModel.isPaid) {
          _error = '¡Upsss!! Modelo IA de Pago!! Pruebe con uno Gratis...';
        } else {
          _error = e.toString();
        }
      } else {
        _error = e.toString();
      }
    } finally {
      _isLoading = false;
      _saveCurrentSession();
      notifyListeners();
    }
  }

  void clearMessages() {
    _messages.clear();
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> pickFile() async {
    try {
      // Solicitar permisos de almacenamiento
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        status = await Permission.storage.request();
        if (!status.isGranted) {
          _error = 'Se necesitan permisos de almacenamiento para seleccionar archivos';
          notifyListeners();
          return;
        }
      }

      // Usar file_picker para seleccionar cualquier tipo de archivo
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final fileSize = await file.length();
        final fileSizeMB = fileSize / (1024 * 1024);

        if (fileSizeMB > 5) {
          _error = 'El archivo no puede ser mayor a 5MB';
          notifyListeners();
          return;
        }

        // Almacenar el archivo para enviarlo con el próximo mensaje
        _attachedFile = FileAttachment(
          name: result.files.single.name,
          bytes: await file.readAsBytes(),
          mimeType: result.files.single.extension != null
              ? 'application/${result.files.single.extension}'
              : 'application/octet-stream',
        );

        // Mostrar indicador visual de archivo adjunto (sin context por ahora)
        _error = 'Archivo adjunto: ${result.files.single.name}';
        notifyListeners();
      }
    } catch (e) {
      _error = 'Error al seleccionar archivo: $e';
      notifyListeners();
    }
  }

  Future<void> recordAudio() async {
    // TODO: Implementar grabación de audio
    _error = 'Grabación de audio próximamente disponible';
    notifyListeners();
  }

  Future<void> loadChatSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionsJson = prefs.getStringList('chat_sessions') ?? [];

    _chatSessions = sessionsJson
        .map((json) => ChatSession.fromJson(jsonDecode(json)))
        .toList();

    // Limpiar sesiones antiguas (más de 7 días)
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    _chatSessions.removeWhere((session) => session.updatedAt.isBefore(sevenDaysAgo));

    await _saveSessionsToPrefs();
    notifyListeners();
  }

  Future<void> createNewSession() async {
    await _saveCurrentSession();
    _currentSessionId = DateTime.now().millisecondsSinceEpoch.toString();
    _messages.clear();
    notifyListeners();
  }

  Future<void> loadSession(String sessionId) async {
    await _saveCurrentSession();
    final session = _chatSessions.firstWhere((s) => s.id == sessionId);
    _currentSessionId = session.id;
    _messages = List.from(session.messages);
    _selectedModel = session.model;
    notifyListeners();
  }

  Future<void> deleteSession(String sessionId) async {
    _chatSessions.removeWhere((s) => s.id == sessionId);
    await _saveSessionsToPrefs();
    if (_currentSessionId == sessionId) {
      _currentSessionId = null;
      _messages.clear();
    }
    notifyListeners();
  }

  Future<void> _saveCurrentSession() async {
    if (_messages.isNotEmpty && _currentSessionId != null) {
      final existingIndex = _chatSessions.indexWhere((s) => s.id == _currentSessionId);
      final session = ChatSession(
        id: _currentSessionId!,
        title: _messages.first.content.length > 50
            ? '${_messages.first.content.substring(0, 50)}...'
            : _messages.first.content,
        messages: List.from(_messages),
        createdAt: existingIndex >= 0 ? _chatSessions[existingIndex].createdAt : DateTime.now(),
        updatedAt: DateTime.now(),
        model: _selectedModel,
      );

      if (existingIndex >= 0) {
        _chatSessions[existingIndex] = session;
      } else {
        _chatSessions.add(session);
      }

      await _saveSessionsToPrefs();
    }
  }

  Future<void> _saveSessionsToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionsJson = _chatSessions.map((s) => jsonEncode(s.toJson())).toList();
    await prefs.setStringList('chat_sessions', sessionsJson);
  }
}