class Belt {
  final String nombre;
  final int diasRequeridos;

  Belt({required this.nombre, required this.diasRequeridos});

  factory Belt.fromJson(Map<String, dynamic> json) {
    return Belt(
      nombre: json['nombre'] ?? json['name'] ?? '',
      diasRequeridos: json['diasRequeridos'] ?? json['requiredDays'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'diasRequeridos': diasRequeridos,
    };
  }
}