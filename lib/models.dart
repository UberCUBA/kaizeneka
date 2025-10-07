class Mision {
  final int id;
  final String descripcion;
  final String categoria; // Salud-Fitness, Amor-Relaciones, Trabajo-Finanzas
  final String beneficio;

  Mision({
    required this.id,
    required this.descripcion,
    required this.categoria,
    required this.beneficio,
  });
}

class Usuario {
  int diasCompletados;
  String cinturonActual;
  int puntos;
  List<int> misionesCompletadas; // ids de misiones completadas
  List<String> logrosDesbloqueados;

  Usuario({
    this.diasCompletados = 0,
    this.cinturonActual = 'Blanco',
    this.puntos = 0,
    this.misionesCompletadas = const [],
    this.logrosDesbloqueados = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'diasCompletados': diasCompletados,
      'cinturonActual': cinturonActual,
      'puntos': puntos,
      'misionesCompletadas': misionesCompletadas,
      'logrosDesbloqueados': logrosDesbloqueados,
    };
  }

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      diasCompletados: json['diasCompletados'] ?? 0,
      cinturonActual: json['cinturonActual'] ?? 'Blanco',
      puntos: json['puntos'] ?? 0,
      misionesCompletadas: List<int>.from(json['misionesCompletadas'] ?? []),
      logrosDesbloqueados: List<String>.from(json['logrosDesbloqueados'] ?? []),
    );
  }
}

class Cinturon {
  final String nombre;
  final int diasRequeridos;

  Cinturon({required this.nombre, required this.diasRequeridos});
}

List<Cinturon> cinturones = [
  Cinturon(nombre: 'Blanco', diasRequeridos: 0),
  Cinturon(nombre: 'Amarillo', diasRequeridos: 7),
  Cinturon(nombre: 'Naranja', diasRequeridos: 14),
  Cinturon(nombre: 'Verde', diasRequeridos: 21),
  Cinturon(nombre: 'Marrón', diasRequeridos: 28),
  Cinturon(nombre: 'Negro', diasRequeridos: 35),
  Cinturon(nombre: 'Sobrado', diasRequeridos: 42),
];

class Logro {
  final String nombre;
  final String descripcion;
  final bool Function(Usuario) check;

  Logro({required this.nombre, required this.descripcion, required this.check});
}

List<Logro> logros = [
  Logro(
    nombre: 'No palmarás en vano',
    descripcion: '7 días seguidos sin fallar',
    check: (usuario) => usuario.diasCompletados >= 7,
  ),
  Logro(
    nombre: 'Cazador de RDPs',
    descripcion: 'Sellar 10 rendijas',
    check: (usuario) => usuario.misionesCompletadas.length >= 10,
  ),
  Logro(
    nombre: 'Versión Sobradísima',
    descripcion: 'Completar los 30 días',
    check: (usuario) => usuario.diasCompletados >= 30,
  ),
];

List<Mision> misiones = [
  Mision(id: 1, descripcion: 'Haz 14h de ayuno intermitente', categoria: 'Salud-Fitness', beneficio: 'Optimiza energía, autofagia y disciplina'),
  Mision(id: 2, descripcion: '20 min de vaina protectora (musculación básica)', categoria: 'Salud-Fitness', beneficio: 'Más fuerza, testosterona y atractivo'),
  Mision(id: 3, descripcion: 'Paseo circadianizador 15 min al sol', categoria: 'Salud-Fitness', beneficio: 'Regula biorritmos, vitamina D, ánimo'),
  Mision(id: 4, descripcion: 'Cena sin ultraprocesados', categoria: 'Salud-Fitness', beneficio: 'Mejor digestión, menos inflamación'),
  Mision(id: 5, descripcion: 'Acuéstate 30 min antes', categoria: 'Salud-Fitness', beneficio: 'Lucras sueño → más salud y ganasolina'),
  Mision(id: 6, descripcion: 'Haz 10 burpees al despertarte', categoria: 'Salud-Fitness', beneficio: 'Activas cuerpo y foco inmediato'),
  Mision(id: 7, descripcion: 'Ducha fría 1 min', categoria: 'Salud-Fitness', beneficio: 'Hormesis, dopamina, resiliencia'),
  Mision(id: 8, descripcion: 'Haz 10.000 pasos sin móvil', categoria: 'Salud-Fitness', beneficio: 'Salud cardiovascular + foco mental'),
  Mision(id: 9, descripcion: 'Cambia un snack basura por fruta o frutos secos', categoria: 'Salud-Fitness', beneficio: 'Nutrición densa, energía estable'),
  Mision(id: 10, descripcion: 'Levántate cada hora para estirarte', categoria: 'Salud-Fitness', beneficio: 'Evita rigidez, activa circulación'),
  Mision(id: 11, descripcion: 'Sonríe a 3 desconocidos', categoria: 'Amor-Relaciones', beneficio: 'Socialización + confianza'),
  Mision(id: 12, descripcion: 'Contacto visual 3 seg + sonrisa', categoria: 'Amor-Relaciones', beneficio: 'Aumenta tu VMS (valor de mercado sexual)'),
  Mision(id: 13, descripcion: 'Envía un mensaje de gratitud', categoria: 'Amor-Relaciones', beneficio: 'Refuerzas vínculos y ánimo'),
  Mision(id: 14, descripcion: 'Haz una llamada en vez de WhatsApp', categoria: 'Amor-Relaciones', beneficio: 'Conexión más real y profunda'),
  Mision(id: 15, descripcion: 'Escucha 5 min sin interrumpir', categoria: 'Amor-Relaciones', beneficio: 'Empatía + atracción social'),
  Mision(id: 16, descripcion: 'Da un cumplido sincero', categoria: 'Amor-Relaciones', beneficio: 'Generas buen rollo instantáneo'),
  Mision(id: 17, descripcion: 'Micro-flirteo con humor', categoria: 'Amor-Relaciones', beneficio: 'Practicas juego social sin presión'),
  Mision(id: 18, descripcion: 'Reencuadra un problema en clave de juego', categoria: 'Amor-Relaciones', beneficio: 'Ganasolina emocional, reduces drama'),
  Mision(id: 19, descripcion: 'Saluda a alguien nuevo', categoria: 'Amor-Relaciones', beneficio: 'Expansión de red social'),
  Mision(id: 20, descripcion: 'Pide feedback honesto', categoria: 'Amor-Relaciones', beneficio: 'Aumenta aprendizaje y humildad atractiva'),
  Mision(id: 21, descripcion: '30 min de absortismo (podcast/libro mientras entrenas/cocinas)', categoria: 'Trabajo-Finanzas', beneficio: 'Aprendes y entrenas a la vez'),
  Mision(id: 22, descripcion: 'Escribe tus 3 OVCs de la semana', categoria: 'Trabajo-Finanzas', beneficio: 'Claridad, foco y priorización'),
  Mision(id: 23, descripcion: 'Elimina una RDP (rendija de palme)', categoria: 'Trabajo-Finanzas', beneficio: 'Cierras fugas de tiempo/dinero'),
  Mision(id: 24, descripcion: '25 min de trabajo profundo (pomodoro)', categoria: 'Trabajo-Finanzas', beneficio: 'Avance real en proyectos clave'),
  Mision(id: 25, descripcion: 'Escribe 5 ideas para generar ingresos extra (CDLs)', categoria: 'Trabajo-Finanzas', beneficio: 'Activas mentalidad de abundancia'),
  Mision(id: 26, descripcion: 'Lee 10 min sobre tu sector', categoria: 'Trabajo-Finanzas', beneficio: 'Acumulas claves de poder'),
  Mision(id: 27, descripcion: 'Desinstala o limita una app palmante', categoria: 'Trabajo-Finanzas', beneficio: 'Recuperas tiempo y foco'),
  Mision(id: 28, descripcion: 'Haz 2h de apagón digital', categoria: 'Trabajo-Finanzas', beneficio: 'Deep work + detox mental'),
  Mision(id: 29, descripcion: 'Haz networking (contacto nuevo LinkedIn/persona)', categoria: 'Trabajo-Finanzas', beneficio: 'Amplías oportunidades y CDLs'),
  Mision(id: 30, descripcion: 'Lista tus 5 RDPs más gordas + plan para sellarlas', categoria: 'Trabajo-Finanzas', beneficio: 'Estrategia defensiva de sobrado'),
];

class Post {
  final int id;
  final String usuarioNombre;
  final String usuarioCinturon;
  final String? usuarioAvatar; // URL o path
  final String? imagenUrl; // Para posts con imagen
  final String? texto; // Para posts de texto
  int likes;
  final DateTime timestamp;
  bool likedByUser; // Si el usuario actual le dio like

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