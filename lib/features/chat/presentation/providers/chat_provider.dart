import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/chat_conversation.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/usecases/get_conversations.dart';
import '../../domain/usecases/send_message.dart';
import '../../domain/usecases/get_messages.dart';
import '../../domain/usecases/create_conversation.dart';
import '../../domain/repositories/chat_repository.dart';

class ChatProvider extends ChangeNotifier {
  final GetConversations _getConversations;
  final SendMessage _sendMessage;
  final GetMessages _getMessages;
  final CreateConversation _createConversation;
  final ChatRepository _repository;
  final AuthProvider _authProvider;

  List<ChatConversation> _conversations = [];
  List<ChatMessage> _currentMessages = [];
  ChatConversation? _selectedConversation;
  bool _isLoading = false;
  bool _isConnected = false;
  String? _searchQuery;

  // Streams
  StreamSubscription<List<ChatConversation>>? _conversationsSubscription;
  StreamSubscription<List<ChatMessage>>? _messagesSubscription;
  StreamSubscription<bool>? _connectionSubscription;

  // Getters
  List<ChatConversation> get conversations => _conversations;
  List<ChatMessage> get currentMessages => _currentMessages;
  ChatConversation? get selectedConversation => _selectedConversation;
  bool get isLoading => _isLoading;
  bool get isConnected => _isConnected;
  String? get searchQuery => _searchQuery;

  List<ChatConversation> get filteredConversations {
    if (_searchQuery == null || _searchQuery!.isEmpty) {
      return _conversations;
    }
    return _conversations.where((conv) =>
      conv.name.toLowerCase().contains(_searchQuery!.toLowerCase())
    ).toList();
  }

  ChatProvider(
    this._getConversations,
    this._sendMessage,
    this._getMessages,
    this._createConversation,
    this._repository,
    this._authProvider,
  ) {
    _initialize();
  }

  void _initialize() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Connect to repository
      await _repository.connect();

      // Start listening to conversations
      _conversationsSubscription = _getConversations().listen(
        (conversations) {
          _conversations = conversations;
          _isLoading = false;
          notifyListeners();
        },
        onError: (error) {
          _isLoading = false;
          notifyListeners();
        },
      );

      // Start listening to connection status
      _connectionSubscription = _repository.getConnectionStatus().listen(
        (connected) {
          _isConnected = connected;
          notifyListeners();
        },
      );

    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectConversation(ChatConversation conversation) async {
    if (_selectedConversation?.id == conversation.id) return;

    _selectedConversation = conversation;
    
    // Mark conversation as read
    await _repository.markAsRead(conversation.id);
    
    // Load messages for this conversation
    _messagesSubscription?.cancel();
    _messagesSubscription = _getMessages(conversation.id).listen(
      (messages) {
        _currentMessages = messages;
        notifyListeners();
      },
      onError: (error) {
        _currentMessages = [];
        notifyListeners();
      },
    );

    notifyListeners();
  }

  void clearSelectedConversation() {
    _selectedConversation = null;
    _currentMessages = [];
    _messagesSubscription?.cancel();
    notifyListeners();
  }

  Future<void> sendTextMessage(String text) async {
    if (_selectedConversation == null || text.trim().isEmpty) return;

    final message = ChatMessage(
      id: _generateId(),
      userId: _authProvider.userProfile?.id ?? 'current_user',
      userName: _authProvider.userProfile?.name ?? 'Usuario',
      content: text.trim(),
      createdAt: DateTime.now(),
      isOwn: true,
    );

    try {
      await _sendMessage(_selectedConversation!.id, message);
    } catch (e) {
      // Handle error (could show snackbar or log)
      debugPrint('Error sending message: $e');
    }
  }

  Future<void> sendVoiceMessage(String audioPath, int duration) async {
    if (_selectedConversation == null) return;

    final message = ChatMessage(
      id: _generateId(),
      userId: _authProvider.userProfile?.id ?? 'current_user',
      userName: _authProvider.userProfile?.name ?? 'Usuario',
      content: 'Mensaje de voz',
      createdAt: DateTime.now(),
      type: MessageType.voice,
      voiceUrl: audioPath,
      voiceDuration: duration,
      isOwn: true,
    );

    try {
      await _sendMessage(_selectedConversation!.id, message);
    } catch (e) {
      debugPrint('Error sending voice message: $e');
    }
  }

  Future<void> createNewConversation(String userName, String userId) async {
    try {
      final newConversation = ChatConversation(
        id: _generateId(),
        name: userName,
        isGroup: false,
        lastMessageTime: DateTime.now(),
      );

      await _createConversation(newConversation);
      
      // The conversation will appear automatically through the stream
    } catch (e) {
      debugPrint('Error creating conversation: $e');
    }
  }

  void searchConversations(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = null;
    notifyListeners();
  }

  String formatMessageTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return '${dateTime.day}/${dateTime.month}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'Ahora';
    }
  }

  String formatLastSeen(DateTime? lastSeen) {
    if (lastSeen == null) return '';

    final now = DateTime.now();
    final difference = now.difference(lastSeen);

    if (difference.inMinutes < 1) {
      return 'En línea';
    } else if (difference.inMinutes < 60) {
      return 'Últ. vez hace ${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return 'Últ. vez hace ${difference.inHours}h';
    } else {
      return 'Últ. vez hace ${difference.inDays}d';
    }
  }

  String _generateId() {
    return '${DateTime.now().millisecondsSinceEpoch}_${_authProvider.userProfile?.id ?? 'user'}';
  }

  @override
  void dispose() {
    _conversationsSubscription?.cancel();
    _messagesSubscription?.cancel();
    _connectionSubscription?.cancel();
    super.dispose();
  }
}