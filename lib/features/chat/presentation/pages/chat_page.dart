import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../domain/entities/chat_conversation.dart';
import '../providers/chat_provider.dart';
import 'chat_detail_page.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    context.read<ChatProvider>().searchConversations(_searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      backgroundColor: themeProvider.isDarkMode ? const Color(0xFF0F1419) : const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: themeProvider.isDarkMode ? const Color(0xFF0F1419) : Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Chat NK',
              style: TextStyle(
                color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (chatProvider.conversations.isNotEmpty)
              Text(
                '${chatProvider.conversations.length} conversaciones',
                style: TextStyle(
                  color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54,
                  fontSize: 12,
                ),
              ),
          ],
        ),
        iconTheme: IconThemeData(
          color: themeProvider.isDarkMode ? Colors.white : Colors.black54,
        ),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              height: 36,
              decoration: BoxDecoration(
                color: themeProvider.isDarkMode 
                  ? const Color(0xFF1C1C1C) 
                  : const Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(18),
              ),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                style: TextStyle(
                  color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  hintText: 'Buscar conversaciones...',
                  hintStyle: TextStyle(
                    color: themeProvider.isDarkMode ? Colors.white54 : Colors.black38,
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: themeProvider.isDarkMode ? Colors.white54 : Colors.black38,
                    size: 20,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
          ),
        ),
      ),
      body: chatProvider.isLoading
        ? Center(
            child: CircularProgressIndicator(
              color: const Color(0xFF00FF7F),
            ),
          )
        : _buildConversationsList(chatProvider, themeProvider),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNewChatDialog(themeProvider),
        backgroundColor: const Color(0xFF00FF7F),
        child: const Icon(Icons.chat_bubble_outline, color: Colors.black),
      ),
    );
  }

  Widget _buildConversationsList(ChatProvider chatProvider, ThemeProvider themeProvider) {
    if (chatProvider.filteredConversations.isEmpty) {
      return _buildEmptyState(themeProvider);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: chatProvider.filteredConversations.length,
      itemBuilder: (context, index) {
        final conversation = chatProvider.filteredConversations[index];
        return _buildConversationTile(conversation, chatProvider, themeProvider);
      },
    );
  }

  Widget _buildConversationTile(
    ChatConversation conversation, 
    ChatProvider chatProvider, 
    ThemeProvider themeProvider
  ) {
    final bool isSelected = chatProvider.selectedConversation?.id == conversation.id;
    final bool hasUnread = conversation.unreadCount > 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openChat(conversation),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected 
                ? (themeProvider.isDarkMode 
                  ? const Color(0xFF1C1C1C) 
                  : const Color(0xFFF0F0F0))
                : null,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                // Avatar con indicador online
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: const Color(0xFF00FF7F),
                      child: conversation.avatar != null
                        ? ClipOval(
                            child: Image.network(
                              conversation.avatar!,
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return _buildInitialsAvatar(conversation.name);
                              },
                            ),
                          )
                        : _buildInitialsAvatar(conversation.name),
                    ),
                    if (conversation.isOnline)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            border: Border.all(
                              color: themeProvider.isDarkMode 
                                ? const Color(0xFF0F1419) 
                                : Colors.white,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                
                // Contenido de la conversación
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nombre y hora
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              conversation.name,
                              style: TextStyle(
                                color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                                fontSize: 16,
                                fontWeight: hasUnread ? FontWeight.w600 : FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            chatProvider.formatMessageTime(conversation.lastMessageTime),
                            style: TextStyle(
                              color: themeProvider.isDarkMode ? Colors.white54 : Colors.black38,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      
                      // Última vista y preview
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              conversation.lastMessagePreview ?? 'Sin mensajes',
                              style: TextStyle(
                                color: themeProvider.isDarkMode 
                                  ? (hasUnread ? Colors.white : Colors.white70)
                                  : (hasUnread ? Colors.black87 : Colors.black54),
                                fontSize: 14,
                                fontWeight: hasUnread ? FontWeight.w500 : FontWeight.normal,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (hasUnread)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: const BoxDecoration(
                                color: Color(0xFF00FF7F),
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                conversation.unreadCount.toString(),
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
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
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildEmptyState(ThemeProvider themeProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: themeProvider.isDarkMode ? Colors.white24 : Colors.black26,
          ),
          const SizedBox(height: 16),
          Text(
            'No hay conversaciones',
            style: TextStyle(
              color: themeProvider.isDarkMode ? Colors.white54 : Colors.black54,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Toca el botón + para iniciar una nueva conversación',
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

  void _openChat(ChatConversation conversation) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChatDetailPage(conversation: conversation),
      ),
    );
  }

  void _showNewChatDialog(ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: themeProvider.isDarkMode 
          ? const Color(0xFF0F1419) 
          : Colors.white,
        title: Text(
          'Nueva Conversación',
          style: TextStyle(
            color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        content: Text(
          'Función para crear nuevas conversaciones estará disponible próximamente',
          style: TextStyle(
            color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'OK',
              style: TextStyle(
                color: const Color(0xFF00FF7F),
              ),
            ),
          ),
        ],
      ),
    );
  }
}