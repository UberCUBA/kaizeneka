import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import '../../domain/entities/recurso.dart';

class RecursoCard extends StatelessWidget {
  final Recurso recurso;
  final VoidCallback onPlay;

  const RecursoCard({
    super.key,
    required this.recurso,
    required this.onPlay,
  });

  Future<void> _downloadRecurso(BuildContext context) async {
    try {
      final dir = await getExternalStorageDirectory();
      final fileName = recurso.url.split('/').last;
      final savePath = '${dir!.path}/$fileName';

      final dio = Dio();
      await dio.download(recurso.url, savePath);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Descargado: $fileName')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al descargar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.black,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  recurso.tipo == 'video' ? '🎬' : '🎧',
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    recurso.titulo,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: onPlay,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Reproducir'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00FF7F),
                    foregroundColor: Colors.black,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _downloadRecurso(context),
                  icon: const Icon(Icons.download),
                  label: const Text(''),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[800],
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}