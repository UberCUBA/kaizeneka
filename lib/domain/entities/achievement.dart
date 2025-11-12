import 'user.dart';

class Achievement {
  final String nombre;
  final String descripcion;
  final bool Function(User) check;

  Achievement({required this.nombre, required this.descripcion, required this.check});

  factory Achievement.fromJson(Map<String, dynamic> json) {
    // Note: The check function cannot be serialized, so this is for data only
    return Achievement(
      nombre: json['nombre'] ?? json['name'] ?? '',
      descripcion: json['descripcion'] ?? json['description'] ?? '',
      check: (user) => false, // Placeholder, logic should be handled elsewhere
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
    };
  }
}