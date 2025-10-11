import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../../domain/entities/chat_session.dart';

class ChatHistoryPage extends StatelessWidget {
  const ChatHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Historial de Chats', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Consumer<ChatProvider>(
        builder: (context, provider, child) {
          if (provider.chatSessions.isEmpty) {
            return const Center(
              child: Text(
                'No hay conversaciones guardadas',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.chatSessions.length,
            itemBuilder: (context, index) {
              final session = provider.chatSessions[index];
              return _buildSessionCard(context, session, provider);
            },
          );
        },
      ),
    );
  }

  Widget _buildSessionCard(BuildContext context, ChatSession session, ChatProvider provider) {
    return Card(
      color: const Color(0xFF1C1C1C),
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(
          session.title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${session.messages.length} mensajes',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            Text(
              'Modelo: ${session.model}',
              style: const TextStyle(color: Color(0xFF00FF7F), fontSize: 12),
            ),
            Text(
              'Última actualización: ${_formatDate(session.updatedAt)}',
              style: const TextStyle(color: Colors.white54, fontSize: 10),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () {
            _showDeleteDialog(context, session, provider);
          },
        ),
        onTap: () {
          provider.loadSession(session.id);
          Navigator.of(context).pop(); // Volver a la página del chat
        },
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, ChatSession session, ChatProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        title: const Text('Eliminar conversación', style: TextStyle(color: Color(0xFF00FF7F))),
        content: Text(
          '¿Estás seguro de que quieres eliminar "${session.title}"?',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () {
              provider.deleteSession(session.id);
              Navigator.of(context).pop();
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Hoy ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Ayer ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} días atrás';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}