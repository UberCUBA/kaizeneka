import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'dart:io';
import '../providers/postureo_provider.dart';
import '../widgets/post_card.dart';
import '../../../../models.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../missions/presentation/providers/mission_provider.dart';
import '../../../../core/services/supabase_service.dart';

class PostureoNkPage extends StatefulWidget {
  const PostureoNkPage({super.key});

  @override
  State<PostureoNkPage> createState() => _PostureoNkPageState();
}

class _PostureoNkPageState extends State<PostureoNkPage> {
  final ImagePicker _picker = ImagePicker();
  final ScrollController _scrollController = ScrollController();

  final dummyPost = Post(
    id: 0,
    usuarioNombre: 'Loading...',
    usuarioCinturon: 'Blanco',
    usuarioAvatar: null,
    imagenUrl: 'https://via.placeholder.com/300x600?text=Loading',
    texto: null,
    likes: 0,
    timestamp: DateTime.now(),
    likedByUser: false,
  );

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PostureoProvider>().fetchPosts();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      context.read<PostureoProvider>().fetchMorePosts();
    }
  }


  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PostureoProvider>();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Postureo NK', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: provider.isLoading
          ? Skeletonizer(
              child: ListView.builder(
                itemCount: 3,
                itemBuilder: (context, index) => PostCard(post: dummyPost),
              ),
            )
          : provider.error != null
              ? Center(child: Text('Error: ${provider.error}', style: const TextStyle(color: Colors.white)))
              : ListView.builder(
                  controller: _scrollController,
                  itemCount: provider.posts.length + (provider.isLoadingMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == provider.posts.length) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final post = provider.posts[index];
                    return PostCard(post: post);
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreatePostDialog(context),
        backgroundColor: const Color(0xFF00FF7F),
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  void _showCreatePostDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        title: const Text('Crear Post', style: TextStyle(color: Color(0xFF00FF7F))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo, color: Color(0xFF00FF7F)),
              title: const Text('Fotografia', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.text_fields, color: Color(0xFF00FF7F)),
              title: const Text('Frase Motivadora', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.of(context).pop();
                _showTextDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _pickImage(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        title: const Text('Seleccionar Imagen', style: TextStyle(color: Color(0xFF00FF7F))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF00FF7F)),
              title: const Text('Cámara', style: TextStyle(color: Colors.white)),
              onTap: () async {
                Navigator.of(context).pop();
                await _selectImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Color(0xFF00FF7F)),
              title: const Text('Galería', style: TextStyle(color: Colors.white)),
              onTap: () async {
                Navigator.of(context).pop();
                await _selectImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        final file = File(pickedFile.path);
        // Upload to Supabase Storage
        final imageUrl = await SupabaseService.uploadImage(file, 'posts', 'images');
        if (imageUrl != null) {
          final authProvider = context.read<AuthProvider>();
          final missionProvider = context.read<MissionProvider>();
          final post = Post(
            id: DateTime.now().millisecondsSinceEpoch,
            usuarioNombre: authProvider.userProfile?.name ?? 'Usuario',
            usuarioCinturon: missionProvider.user?.cinturonActual ?? 'Blanco',
            usuarioAvatar: authProvider.userProfile?.avatarUrl,
            imagenUrl: imageUrl,
            timestamp: DateTime.now(),
          );
          await context.read<PostureoProvider>().addPost(post);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al subir la imagen')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _showTextDialog(BuildContext context) {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        title: const Text('Escribir Post', style: TextStyle(color: Color(0xFF00FF7F))),
        content: TextField(
          controller: textController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: '¿Qué estás postureando?',
            hintStyle: TextStyle(color: Colors.grey),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF00FF7F)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () async {
              if (textController.text.isNotEmpty) {
                final authProvider = context.read<AuthProvider>();
                final missionProvider = context.read<MissionProvider>();
                final post = Post(
                  id: DateTime.now().millisecondsSinceEpoch,
                  usuarioNombre: authProvider.userProfile?.name ?? 'Usuario',
                  usuarioCinturon: missionProvider.user?.cinturonActual ?? 'Blanco',
                  usuarioAvatar: authProvider.userProfile?.avatarUrl,
                  texto: textController.text,
                  timestamp: DateTime.now(),
                );
                await context.read<PostureoProvider>().addPost(post);
                Navigator.of(context).pop();
              }
            },
            child: const Text('Publicar', style: TextStyle(color: Color(0xFF00FF7F))),
          ),
        ],
      ),
    );
  }
}