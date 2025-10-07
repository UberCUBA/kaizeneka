class Recurso {
  final int id;
  final String titulo;
  final String tipo; // 'video' o 'audio'
  final String url;

  Recurso({
    required this.id,
    required this.titulo,
    required this.tipo,
    required this.url,
  });
}