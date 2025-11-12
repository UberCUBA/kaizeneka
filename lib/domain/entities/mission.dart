class Mission {
  final int id;
  final String description;
  final String category; // Salud-Fitness, Amor-Relaciones, Trabajo-Finanzas
  final String benefit;

  Mission({
    required this.id,
    required this.description,
    required this.category,
    required this.benefit,
  });

  factory Mission.fromJson(Map<String, dynamic> json) {
    return Mission(
      id: json['id'],
      description: json['description'],
      category: json['category'],
      benefit: json['benefit'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'category': category,
      'benefit': benefit,
    };
  }
}