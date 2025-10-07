class Mission {
  final int id;
  final String descripcion;
  final String categoria;
  final String beneficio;

  Mission({
    required this.id,
    required this.descripcion,
    required this.categoria,
    required this.beneficio,
  });
}

class User {
  int diasCompletados;
  String cinturonActual;
  int puntos;
  List<int> misionesCompletadas;
  List<String> logrosDesbloqueados;

  User({
    this.diasCompletados = 0,
    this.cinturonActual = 'Blanco',
    this.puntos = 0,
    this.misionesCompletadas = const [],
    this.logrosDesbloqueados = const [],
  });
}

class Cinturon {
  final String nombre;
  final int diasRequeridos;

  Cinturon({required this.nombre, required this.diasRequeridos});
}

class Logro {
  final String nombre;
  final String descripcion;
  final bool Function(User) check;

  Logro({required this.nombre, required this.descripcion, required this.check});
}