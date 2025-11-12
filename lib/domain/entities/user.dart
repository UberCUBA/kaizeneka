class User {
  int diasCompletados;
  String cinturonActual;
  int puntos;
  List<int> misionesCompletadas; // ids of completed missions
  List<String> logrosDesbloqueados;

  User({
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

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      diasCompletados: json['diasCompletados'] ?? 0,
      cinturonActual: json['cinturonActual'] ?? 'Blanco',
      puntos: json['puntos'] ?? 0,
      misionesCompletadas: List<int>.from(json['misionesCompletadas'] ?? []),
      logrosDesbloqueados: List<String>.from(json['logrosDesbloqueados'] ?? []),
    );
  }
}