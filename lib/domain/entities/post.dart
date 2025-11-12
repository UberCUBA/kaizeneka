class Post {
  final int id;
  final String usuarioNombre;
  final String usuarioCinturon;
  final String? usuarioAvatar; // URL or path
  final String? imagenUrl; // For posts with image
  final String? texto; // For text posts
  int likes;
  final DateTime timestamp;
  bool likedByUser; // If current user liked it

  Post({
    required this.id,
    required this.usuarioNombre,
    required this.usuarioCinturon,
    this.usuarioAvatar,
    this.imagenUrl,
    this.texto,
    this.likes = 0,
    required this.timestamp,
    this.likedByUser = false,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      usuarioNombre: json['usuario_nombre'] ?? '',
      usuarioCinturon: json['usuario_cinturon'] ?? '',
      usuarioAvatar: json['usuario_avatar'],
      imagenUrl: json['imagen_url'],
      texto: json['texto'],
      likes: json['likes'] ?? 0,
      timestamp: DateTime.parse(json['timestamp']),
      likedByUser: json['liked_by_user'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'usuario_nombre': usuarioNombre,
      'usuario_cinturon': usuarioCinturon,
      'usuario_avatar': usuarioAvatar,
      'imagen_url': imagenUrl,
      'texto': texto,
      'likes': likes,
      'timestamp': timestamp.toIso8601String(),
      'liked_by_user': likedByUser,
    };
  }

  Post copyWith({
    int? id,
    String? usuarioNombre,
    String? usuarioCinturon,
    String? usuarioAvatar,
    String? imagenUrl,
    String? texto,
    int? likes,
    DateTime? timestamp,
    bool? likedByUser,
  }) {
    return Post(
      id: id ?? this.id,
      usuarioNombre: usuarioNombre ?? this.usuarioNombre,
      usuarioCinturon: usuarioCinturon ?? this.usuarioCinturon,
      usuarioAvatar: usuarioAvatar ?? this.usuarioAvatar,
      imagenUrl: imagenUrl ?? this.imagenUrl,
      texto: texto ?? this.texto,
      likes: likes ?? this.likes,
      timestamp: timestamp ?? this.timestamp,
      likedByUser: likedByUser ?? this.likedByUser,
    );
  }
}