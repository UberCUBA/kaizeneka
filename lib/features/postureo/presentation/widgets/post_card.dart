import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/postureo_provider.dart';
import '../../../../models.dart';

class PostCard extends StatelessWidget {
  final Post post;

  const PostCard({super.key, required this.post});

  Color getBeltColor(String belt) {
    switch (belt) {
      case 'Blanco':
        return Colors.white;
      case 'Amarillo':
        return Colors.yellow;
      case 'Naranja':
        return Colors.orange;
      case 'Verde':
        return Colors.green;
      case 'Azul':
        return Colors.blue;
      case 'Marrón':
        return Colors.brown;
      case 'Negro':
        return Colors.black;
      default:
        return Colors.grey;
    }
  }

  void _showFullImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        backgroundColor: Colors.black,
        child: InteractiveViewer(
          panEnabled: true,
          minScale: 0.5,
          maxScale: 5.0,
          child: Image.network(imageUrl),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1C1C1C),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Avatar, nombre, cinturón
            Row(
              children: [
                            Stack(
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundColor: const Color(0xFF00FF7F),
                                  child: Text(
                                    post.usuarioNombre[0].toUpperCase(),
                                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      CircleAvatar(
                                        radius: 12,
                                        backgroundColor: const Color.fromARGB(255, 186, 185, 185),
                                      ),
                                      CircleAvatar(
                                        radius: 9,
                                        backgroundColor: Colors.grey[600],
                                      ),
                                      Icon(
                                        Icons.star,
                                        color: getBeltColor(post.usuarioCinturon),
                                        size: 14,
                                      ),
                                    ],
                                  ),
                                ),
                              
                              ],
                            ),
                              const SizedBox(width: 16),
                              Text(
                                post.usuarioNombre,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          ],
              // children: [
              //   // CircleAvatar(
              //   //   backgroundColor: const Color(0xFF00FF7F),
              //   //   child: Text(
              //   //     post.usuarioNombre[0].toUpperCase(),
              //   //     style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              //   //   ),
              //   // ),
                
              //   const SizedBox(width: 12),
              //   Text(
              //     post.usuarioNombre,
              //     style: const TextStyle(
              //       color: Colors.white,
              //       fontSize: 16,
              //       fontWeight: FontWeight.bold,
              //     ),
              //   ),
              //   // const SizedBox(width: 30),
              //   // Container(
              //   //   width: 50,
              //   //   height: 5,
              //   //   color: getBeltColor(post.usuarioCinturon),
              //   // ),
              // ],
            ),
            const SizedBox(height: 12),
            // Contenido: imagen o texto
            if (post.imagenUrl != null)
              GestureDetector(
                onTap: () => _showFullImage(context, post.imagenUrl!),
                child: Container(
                  height: 485,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: NetworkImage(post.imagenUrl!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              )
            else if (post.texto != null)
              Text(
                post.texto!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            const SizedBox(height: 12),
            // Botones
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    context.read<PostureoProvider>().toggleLike(post.id, context);
                  },
                  icon: Icon(
                    post.likedByUser ? Icons.favorite : Icons.favorite_border,
                    color: const Color(0xFF00FF7F),
                  ),
                ),
                Text(
                  '${post.likes}',
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(width: 16),
                IconButton(
                  onPressed: () {
                    // TODO: Implementar comentar
                  },
                  icon: const Icon(Icons.comment, color: Colors.white),
                ),
                // const Text('Comentar', style: TextStyle(color: Colors.white)),
                const SizedBox(width: 16),
                IconButton(
                  onPressed: () {
                    // TODO: Implementar compartir
                  },
                  icon: const Icon(Icons.share, color: Colors.white),
                ),
                // const Text('Compartir', style: TextStyle(color: Colors.white)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}