import '../../domain/entities/mission.dart';

class MissionModel extends Mission {
  MissionModel({
    required super.id,
    required super.descripcion,
    required super.categoria,
    required super.beneficio,
  });

  factory MissionModel.fromEntity(Mission mission) {
    return MissionModel(
      id: mission.id,
      descripcion: mission.descripcion,
      categoria: mission.categoria,
      beneficio: mission.beneficio,
    );
  }
}

class UserModel {
  final int diasCompletados;
  final String cinturonActual;
  final int puntos;
  final List<int> misionesCompletadas;
  final List<String> logrosDesbloqueados;

  UserModel({
    required this.diasCompletados,
    required this.cinturonActual,
    required this.puntos,
    required this.misionesCompletadas,
    required this.logrosDesbloqueados,
  });

  factory UserModel.fromEntity(User user) {
    return UserModel(
      diasCompletados: user.diasCompletados,
      cinturonActual: user.cinturonActual,
      puntos: user.puntos,
      misionesCompletadas: user.misionesCompletadas,
      logrosDesbloqueados: user.logrosDesbloqueados,
    );
  }

  User toEntity() {
    return User(
      diasCompletados: diasCompletados,
      cinturonActual: cinturonActual,
      puntos: puntos,
      misionesCompletadas: misionesCompletadas,
      logrosDesbloqueados: logrosDesbloqueados,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'diasCompletados': diasCompletados,
      'cinturonActual': cinturonActual,
      'puntos': puntos,
      'misionesCompletadas': misionesCompletadas,
      'logrosDesbloqueados': logrosDesbloqueados,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      diasCompletados: json['diasCompletados'] ?? 0,
      cinturonActual: json['cinturonActual'] ?? 'Blanco',
      puntos: json['puntos'] ?? 0,
      misionesCompletadas: List<int>.from(json['misionesCompletadas'] ?? []),
      logrosDesbloqueados: List<String>.from(json['logrosDesbloqueados'] ?? []),
    );
  }
}