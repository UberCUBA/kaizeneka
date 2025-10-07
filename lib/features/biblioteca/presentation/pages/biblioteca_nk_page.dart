import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/biblioteca_provider.dart';
import '../widgets/recurso_card.dart';
import '../../domain/entities/recurso.dart';
import 'package:video_player/video_player.dart';
import 'package:just_audio/just_audio.dart';

class BibliotecaNkPage extends StatefulWidget {
  const BibliotecaNkPage({super.key});

  @override
  _BibliotecaNkPageState createState() => _BibliotecaNkPageState();
}

class _BibliotecaNkPageState extends State<BibliotecaNkPage> {
  VideoPlayerController? _videoController;
  AudioPlayer? _audioPlayer;
  Recurso? _currentRecurso;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BibliotecaProvider>().fetchRecursos();
    });
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _audioPlayer?.dispose();
    super.dispose();
  }

  void _playRecurso(Recurso recurso) async {
    // Detener reproducción anterior
    _videoController?.pause();
    _audioPlayer?.stop();

    setState(() {
      _currentRecurso = recurso;
    });

    if (recurso.tipo == 'video') {
      _videoController = VideoPlayerController.network(recurso.url)
        ..initialize().then((_) {
          setState(() {});
          _videoController!.play();
        });
    } else if (recurso.tipo == 'audio') {
      _audioPlayer = AudioPlayer();
      await _audioPlayer!.setUrl(recurso.url);
      _audioPlayer!.play();
    }

    // Mostrar BottomSheet con minireproductor
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      builder: (context) => _buildMiniReproductor(),
    );
  }

  Widget _buildMiniReproductor() {
    if (_currentRecurso == null) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _currentRecurso!.titulo,
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (_currentRecurso!.tipo == 'video' && _videoController != null && _videoController!.value.isInitialized)
            AspectRatio(
              aspectRatio: _videoController!.value.aspectRatio,
              child: VideoPlayer(_videoController!),
            )
          else if (_currentRecurso!.tipo == 'audio')
            StreamBuilder<PlayerState>(
              stream: _audioPlayer!.playerStateStream,
              builder: (context, snapshot) {
                final playerState = snapshot.data;
                final processingState = playerState?.processingState;
                final playing = playerState?.playing;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (processingState == ProcessingState.loading || processingState == ProcessingState.buffering)
                      const CircularProgressIndicator()
                    else if (playing != true)
                      IconButton(
                        icon: const Icon(Icons.play_arrow, color: Color(0xFF00FF7F), size: 48),
                        onPressed: _audioPlayer!.play,
                      )
                    else if (processingState != ProcessingState.completed)
                      IconButton(
                        icon: const Icon(Icons.pause, color: Color(0xFF00FF7F), size: 48),
                        onPressed: _audioPlayer!.pause,
                      )
                    else
                      IconButton(
                        icon: const Icon(Icons.replay, color: Color(0xFF00FF7F), size: 48),
                        onPressed: () => _audioPlayer!.seek(Duration.zero),
                      ),
                  ],
                );
              },
            ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              _videoController?.pause();
              _audioPlayer?.stop();
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Biblioteca NK', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Consumer<BibliotecaProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.error != null) {
            return Center(
              child: Text(
                'Error: ${provider.error}',
                style: const TextStyle(color: Colors.white),
              ),
            );
          }
          return ListView.builder(
            itemCount: provider.recursos.length,
            itemBuilder: (context, index) {
              final recurso = provider.recursos[index];
              return RecursoCard(
                recurso: recurso,
                onPlay: () => _playRecurso(recurso),
              );
            },
          );
        },
      ),
    );
  }
}