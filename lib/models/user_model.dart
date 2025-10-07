import 'package:latlong2/latlong.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String belt;
  final int points;
  final int diasCompletados;
  final List<int> misionesCompletadas;
  final List<String> logrosDesbloqueados;
  final LatLng? location;
  final String? avatarUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

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
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'] ?? '',
      belt: json['belt'],
      points: json['points'],
      diasCompletados: json['dias_completados'] ?? 0,
      misionesCompletadas: List<int>.from(json['misiones_completadas'] ?? []),
      logrosDesbloqueados: List<String>.from(json['logros_desbloqueados'] ?? []),
      location: json['lat'] != null && json['lng'] != null
          ? LatLng(json['lat'], json['lng'])
          : null,
      avatarUrl: json['avatar_url'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'belt': belt,
      'points': points,
      'dias_completados': diasCompletados,
      'misiones_completadas': misionesCompletadas,
      'logros_desbloqueados': logrosDesbloqueados,
      'lat': location?.latitude,
      'lng': location?.longitude,
      'avatar_url': avatarUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
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
    );
  }
}