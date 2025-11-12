import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../domain/entities/chat_conversation.dart';
import '../../domain/entities/chat_message.dart';
import '../providers/chat_provider.dart';

class ChatDetailPage extends StatefulWidget {
  final ChatConversation conversation;

  const ChatDetailPage({
    super.key,
    required this.conversation,
  });

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isRecording = false;
  int _recordingDuration = 0;

  @override
  void initState() {
    super.initState();
    _scrollToBottom();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _startRecording() {
    setState(() {
      _isRecording = true;
      _recordingDuration = 0;
    });
    
    // Simulate recording timer
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted && _isRecording) {
        setState(() {
          _recordingDuration++;
        });
        return true;
      }
      return false;
    });
  }

  void _stopRecording() {
    setState(() {
      _isRecording = false;
    });
    
    // Simulate sending voice message
    if (_recordingDuration > 0) {
      final fakePath = 'path_to_audio_${DateTime.now().millisecondsSinceEpoch}.mp3';
      context.read<ChatProvider>().sendVoiceMessage(fakePath, _recordingDuration);
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();
    final themeProvider = context.watch<ThemeProvider>();

    // Select the conversation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (chatProvider.selectedConversation?.id != widget.conversation.id) {
        chatProvider.selectConversation(widget.conversation);
      }
    });

    return Scaffold(
      backgroundColor: themeProvider.isDarkMode ? const Color(0xFF0F1419) : const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: themeProvider.isDarkMode ? const Color(0xFF0F1419) : Colors.white,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: const Color(0xFF00FF7F),
              child: widget.conversation.avatar != null
                ? ClipOval(
                    child: Image.network(
                      widget.conversation.avatar!,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildInitialsAvatar(widget.conversation.name);
                      },
                    ),
                  )
                : _buildInitialsAvatar(widget.conversation.name),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.conversation.name,
                    style: TextStyle(
                      color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (widget.conversation.isOnline)
                    Text(
                      'En línea',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                      ),
                    )
                  else if (widget.conversation.lastSeen != null)
                    Text(
                      chatProvider.formatLastSeen(widget.conversation.lastSeen),
                      style: TextStyle(
                        color: themeProvider.isDarkMode ? Colors.white54 : Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.phone,
              color: themeProvider.isDarkMode ? Colors.white : Colors.black54,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(
              Icons.videocam,
              color: themeProvider.isDarkMode ? Colors.white : Colors.black54,
            ),
            onPressed: () {},
          ),
          PopupMenuButton<String>(
            color: themeProvider.isDarkMode ? const Color(0xFF1C1C1C) : Colors.white,
            onSelected: (value) {
              switch (value) {
                case 'view_info':
                  break;
                case 'search':
                  break;
                case 'clear':
                  break;
                case 'delete':
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'view_info',
                child: Text(
                  'Ver información',
                  style: TextStyle(
                    color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              PopupMenuItem(
                value: 'search',
                child: Text(
                  'Buscar',
                  style: TextStyle(
                    color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              PopupMenuItem(
                value: 'clear',
                child: Text(
                  'Limpiar chat',
                  style: TextStyle(
                    color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Text(
                  'Eliminar chat',
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages area
          Expanded(
            child: chatProvider.currentMessages.isEmpty
              ? _buildEmptyChat(themeProvider)
              : _buildMessagesList(chatProvider, themeProvider),
          ),
          
          // Input area
          _buildMessageInput(chatProvider, themeProvider),
        ],
      ),
    );
  }

  Widget _buildMessagesList(ChatProvider chatProvider, ThemeProvider themeProvider) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: chatProvider.currentMessages.length,
      itemBuilder: (context, index) {
        final message = chatProvider.currentMessages[index];
        return _buildMessageBubble(message, chatProvider, themeProvider);
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message, ChatProvider chatProvider, ThemeProvider themeProvider) {
    final bool isOwn = message.isOwn;
    final Alignment alignment = isOwn ? Alignment.centerRight : Alignment.centerLeft;
    final Color bubbleColor = isOwn 
      ? const Color(0xFF00FF7F)
      : (themeProvider.isDarkMode ? const Color(0xFF1C1C1C) : Colors.white);

    return Container(
      alignment: alignment,
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: isOwn ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isOwn)
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFF00FF7F),
              child: message.userAvatar != null
                ? ClipOval(
                    child: Image.network(
                      message.userAvatar!,
                      width: 32,
                      height: 32,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildInitialsAvatar(message.userName);
                      },
                    ),
                  )
                : _buildInitialsAvatar(message.userName),
            ),
          
          if (!isOwn) const SizedBox(width: 8),
          
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isOwn)
                  Text(
                    message.userName,
                    style: TextStyle(
                      color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                
                if (message.type == MessageType.voice)
                  _buildVoiceMessage(message)
                else
                  Text(
                    message.content,
                    style: TextStyle(
                      color: isOwn ? Colors.black : (themeProvider.isDarkMode ? Colors.white : Colors.black87),
                      fontSize: 16,
                    ),
                  ),
                
                const SizedBox(height: 4),
                
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatTime(message.createdAt),
                      style: TextStyle(
                        color: isOwn 
                          ? Colors.black54 
                          : (themeProvider.isDarkMode ? Colors.white54 : Colors.black38),
                        fontSize: 12,
                      ),
                    ),
                    if (isOwn) ...[
                      const SizedBox(width: 4),
                      Icon(
                        Icons.done_all,
                        size: 16,
                        color: Colors.black54,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          
          if (isOwn) const SizedBox(width: 8),
          
          if (isOwn)
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFF00FF7F),
              child: message.userAvatar != null
                ? ClipOval(
                    child: Image.network(
                      message.userAvatar!,
                      width: 32,
                      height: 32,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildInitialsAvatar(message.userName);
                      },
                    ),
                  )
                : _buildInitialsAvatar(message.userName),
            ),
        ],
      ),
    );
  }

  Widget _buildVoiceMessage(ChatMessage message) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF00FF7F),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.play_arrow,
              color: Colors.black,
              size: 20,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 100,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(2),
            ),
            child: Stack(
              children: [
                Container(
                  width: (message.voiceDuration != null && message.voiceDuration! > 0) 
                    ? 30.0 
                    : 0,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${message.voiceDuration ?? 0}s',
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput(ChatProvider chatProvider, ThemeProvider themeProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode ? const Color(0xFF0F1419) : Colors.white,
        border: Border(
          top: BorderSide(
            color: themeProvider.isDarkMode 
              ? Colors.white10 
              : Colors.black12,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              Icons.attach_file,
              color: themeProvider.isDarkMode ? Colors.white54 : Colors.black54,
            ),
            onPressed: () {},
          ),
          
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: themeProvider.isDarkMode 
                  ? const Color(0xFF1C1C1C) 
                  : const Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                controller: _messageController,
                style: TextStyle(
                  color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                  fontSize: 16,
                ),
                decoration: InputDecoration(
                  hintText: 'Escribe un mensaje...',
                  hintStyle: TextStyle(
                    color: themeProvider.isDarkMode ? Colors.white54 : Colors.black38,
                    fontSize: 16,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                onSubmitted: (value) => _sendMessage(),
              ),
            ),
          ),
          
          if (_messageController.text.trim().isNotEmpty)
            IconButton(
              icon: const Icon(
                Icons.send,
                color: Color(0xFF00FF7F),
              ),
              onPressed: _sendMessage,
            )
          else
            GestureDetector(
              onLongPress: _startRecording,
              onLongPressUp: _stopRecording,
              child: IconButton(
                icon: Icon(
                  _isRecording ? Icons.stop : Icons.mic,
                  color: _isRecording ? Colors.red : (themeProvider.isDarkMode ? Colors.white54 : Colors.black54),
                ),
                onPressed: _isRecording ? _stopRecording : null,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyChat(ThemeProvider themeProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: themeProvider.isDarkMode ? Colors.white24 : Colors.black26,
          ),
          const SizedBox(height: 16),
          Text(
            'No hay mensajes aún',
            style: TextStyle(
              color: themeProvider.isDarkMode ? Colors.white54 : Colors.black54,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Envía el primer mensaje para iniciar la conversación',
            style: TextStyle(
              color: themeProvider.isDarkMode ? Colors.white38 : Colors.black38,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInitialsAvatar(String name) {
    final initials = name
        .split(' ')
        .map((word) => word.isNotEmpty ? word[0].toUpperCase() : '')
        .join()
        .substring(0, 2);
    
    return Text(
      initials.isNotEmpty ? initials : '?',
      style: const TextStyle(
        color: Colors.black,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isNotEmpty) {
      context.read<ChatProvider>().sendTextMessage(text);
      _messageController.clear();
      _scrollToBottom();
    }
  }
}