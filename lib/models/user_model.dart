import 'package:latlong2/latlong.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String belt; // Unificado con level (belt representa el nivel)
  final int points; // Unificado con xp (points es la experiencia total)
  final int diasCompletados;
  final List<int> misionesCompletadas;
  final List<String> logrosDesbloqueados;
  final LatLng? location;
  final String? avatarUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Sistema de progreso simplificado
  final int coins; // Moneda para compras
  final int streak; // Racha diaria
  final int energy; // Energía disponible
  final Map<String, int> jvcProgress; // Salud, Dinámicas Sociales, Psicología del Éxito
  final String currentWorld;
  final int currentArc;
  final List<String> unlockedMissions;
  final List<String> unlockedAchievements;
  final Map<String, dynamic> stats; // fuerza, constancia, foco, etc.

  // Propiedades calculadas para compatibilidad
  int get xp => points; // points ahora representa XP
  int get level => _getLevelFromBelt(belt); // level derivado del belt

  // Método auxiliar para convertir belt a level
  int _getLevelFromBelt(String belt) {
    const beltLevels = {
      'Blanco': 1,
      'Amarillo': 2,
      'Naranja': 3,
      'Verde': 4,
      'Marrón': 5,
      'Negro': 6,
      'Sobrado': 7,
    };
    return beltLevels[belt] ?? 1;
  }

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.belt,
    required this.points,
    this.diasCompletados = 0,
    this.misionesCompletadas = const [],
    this.logrosDesbloqueados = const [],
    this.location,
    this.avatarUrl,
    required this.createdAt,
    required this.updatedAt,
    this.coins = 0,
    this.streak = 0,
    this.energy = 100,
    this.jvcProgress = const {'Salud': 0, 'Dinámicas Sociales': 0, 'Psicología del Éxito': 0},
    this.currentWorld = 'Salud Extrema',
    this.currentArc = 1,
    this.unlockedMissions = const [],
    this.unlockedAchievements = const [],
    this.stats = const {'fuerza': 0, 'constancia': 0, 'foco': 0},
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'] ?? '',
      belt: json['belt'],
      points: json['points'] ?? json['xp'] ?? 0, // Compatibilidad con xp antiguo
      diasCompletados: json['dias_completados'] ?? 0,
      misionesCompletadas: List<int>.from(json['misiones_completadas'] ?? []),
      logrosDesbloqueados: List<String>.from(json['logros_desbloqueados'] ?? []),
      location: json['location_lat'] != null && json['location_lng'] != null
          ? LatLng(json['location_lat'], json['location_lng'])
          : null,
      avatarUrl: json['avatar_url'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      coins: json['coins'] ?? 0,
      streak: json['streak'] ?? 0,
      energy: json['energy'] ?? 100,
      jvcProgress: Map<String, int>.from(json['jvc_progress'] ?? {'Salud': 0, 'Dinámicas Sociales': 0, 'Psicología del Éxito': 0}),
      currentWorld: json['current_world'] ?? 'Salud Extrema',
      currentArc: json['current_arc'] ?? 1,
      unlockedMissions: List<String>.from(json['unlocked_missions'] ?? []),
      unlockedAchievements: List<String>.from(json['unlocked_achievements'] ?? []),
      stats: Map<String, dynamic>.from(json['stats'] ?? {'fuerza': 0, 'constancia': 0, 'foco': 0}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'belt': belt,
      'points': points, // Ahora representa XP
      'dias_completados': diasCompletados,
      'misiones_completadas': misionesCompletadas,
      'logros_desbloqueados': logrosDesbloqueados,
      'location_lat': location?.latitude,
      'location_lng': location?.longitude,
      'avatar_url': avatarUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'coins': coins,
      'streak': streak,
      'energy': energy,
      'jvc_progress': jvcProgress,
      'current_world': currentWorld,
      'current_arc': currentArc,
      'unlocked_missions': unlockedMissions,
      'unlocked_achievements': unlockedAchievements,
      'stats': stats,
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? belt,
    int? points,
    int? diasCompletados,
    List<int>? misionesCompletadas,
    List<String>? logrosDesbloqueados,
    LatLng? location,
    String? avatarUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? coins,
    int? streak,
    int? energy,
    Map<String, int>? jvcProgress,
    String? currentWorld,
    int? currentArc,
    List<String>? unlockedMissions,
    List<String>? unlockedAchievements,
    Map<String, dynamic>? stats,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      belt: belt ?? this.belt,
      points: points ?? this.points,
      diasCompletados: diasCompletados ?? this.diasCompletados,
      misionesCompletadas: misionesCompletadas ?? this.misionesCompletadas,
      logrosDesbloqueados: logrosDesbloqueados ?? this.logrosDesbloqueados,
      location: location ?? this.location,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      coins: coins ?? this.coins,
      streak: streak ?? this.streak,
      energy: energy ?? this.energy,
      jvcProgress: jvcProgress ?? this.jvcProgress,
      currentWorld: currentWorld ?? this.currentWorld,
      currentArc: currentArc ?? this.currentArc,
      unlockedMissions: unlockedMissions ?? this.unlockedMissions,
      unlockedAchievements: unlockedAchievements ?? this.unlockedAchievements,
      stats: stats ?? this.stats,
    );
  }
}