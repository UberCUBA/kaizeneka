import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/chat_provider.dart';

class IaNkPage extends StatefulWidget {
  const IaNkPage({super.key});

  @override
  State<IaNkPage> createState() => _IaNkPageState();
}

class _IaNkPageState extends State<IaNkPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().loadAvailableModels();
      context.read<ChatProvider>().loadChatSessions();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isNotEmpty) {
      context.read<ChatProvider>().sendUserMessage(message);
      _messageController.clear();
      // Scroll to bottom after sending
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('IA NK', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFF00FF7F)),
            onPressed: () {
              context.read<ChatProvider>().createNewSession();
            },
          ),
          IconButton(
            icon: const Icon(Icons.history, color: Color(0xFF00FF7F)),
            onPressed: () {
              Navigator.of(context).pushNamed('/ia_nk_history');
            },
          ),
          IconButton(
            icon: const Icon(Icons.clear, color: Color(0xFF00FF7F)),
            onPressed: () {
              context.read<ChatProvider>().clearMessages();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, provider, child) {
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.messages.length + (provider.isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index < provider.messages.length) {
                      final message = provider.messages[index];
                      return _buildMessageBubble(message);
                    } else {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00FF7F)),
                          ),
                        ),
                      );
                    }
                  },
                );
              },
            ),
          ),
          if (context.watch<ChatProvider>().error != null)
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3CD), // Color amarillo suave
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFFEAA7)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Color(0xFF856404),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '¡Ups! Parece que algo salió mal.\n${context.watch<ChatProvider>().error}',
                      style: const TextStyle(
                        color: Color(0xFF856404),
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Color(0xFF856404),
                      size: 20,
                    ),
                    onPressed: () {
                      // Limpiar el error
                      context.read<ChatProvider>().clearError();
                    },
                  ),
                ],
              ),
            ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(message) {
    final isUser = message.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: () => _showMessageOptions(message),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.all(12),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          decoration: BoxDecoration(
            color: isUser ? const Color(0xFF00FF7F) : Colors.grey[800],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message.content,
                style: TextStyle(
                  color: isUser ? Colors.black : Colors.white,
                  fontSize: 16,
                ),
              ),
              if (message.model != null && !isUser)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'Modelo: ${message.model}',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMessageOptions(message) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.copy, color: Color(0xFF00FF7F)),
              title: const Text('Copiar', style: TextStyle(color: Colors.white)),
              onTap: () {
                Clipboard.setData(ClipboardData(text: message.content));
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Mensaje copiado al portapapeles')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.share, color: Color(0xFF00FF7F)),
              title: const Text('Compartir', style: TextStyle(color: Colors.white)),
              onTap: () {
                Share.share(message.content);
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF1C1C1C),
      ),
      child: Column(
        children: [
          // Dropdown de modelos en la parte inferior (30% más pequeño)
          Consumer<ChatProvider>(
            builder: (context, provider, child) {
              return Container(
                height: 40, // 30% más pequeño que el original
                margin: const EdgeInsets.only(bottom: 8),
                child: DropdownButton<String>(
                  value: provider.selectedModel,
                  dropdownColor: Colors.black,
                  style: const TextStyle(color: Color(0xFF00FF7F), fontSize: 14),
                  icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF00FF7F), size: 20),
                  underline: Container(),
                  isExpanded: true,
                  items: provider.availableModels.map((model) {
                    return DropdownMenuItem<String>(
                      value: model.id,
                      child: Text(
                        '${model.name} ${model.isFree ? '(Gratis)' : '(Pago)'}',
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      provider.setSelectedModel(value);
                    }
                  },
                ),
              );
            },
          ),
          // Área de entrada de mensaje
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Botones de adjuntos
              Column(
                children: [
                  // Botón + para menú de archivos
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'file':
                          context.read<ChatProvider>().pickFile();
                          break;
                        case 'image':
                          _pickImage();
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'file',
                        child: Row(
                          children: [
                            Icon(Icons.attach_file, color: Color(0xFF00FF7F)),
                            SizedBox(width: 8),
                            Text('Archivo'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'image',
                        child: Row(
                          children: [
                            Icon(Icons.image, color: Color(0xFF00FF7F)),
                            SizedBox(width: 8),
                            Text('Imagen'),
                          ],
                        ),
                      ),
                    ],
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00FF7F),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.add, color: Colors.black, size: 20),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Botón de audio
                  IconButton(
                    icon: const Icon(Icons.mic, color: Color(0xFF00FF7F)),
                    onPressed: () {
                      context.read<ChatProvider>().recordAudio();
                    },
                  ),
                ],
              ),
              const SizedBox(width: 8),
              // Área de texto expandible
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(
                    minHeight: 40,
                    maxHeight: 120,
                  ),
                  child: TextField(
                    controller: _messageController,
                    style: const TextStyle(color: Colors.white),
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                    decoration: InputDecoration(
                      hintText: 'Escribe tu mensaje...',
                      hintStyle: const TextStyle(color: Colors.white70),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFF00FF7F)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFF00FF7F)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFF00FF7F), width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Botón de enviar separado
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF00FF7F),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.send, color: Colors.black),
                  onPressed: _sendMessage,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _pickImage() async {
    // TODO: Implementar selección específica de imágenes
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Selección de imágenes próximamente')),
    );
  }
}