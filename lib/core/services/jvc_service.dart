import '../../models/user_model.dart';
import 'supabase_service.dart';

class JvcService {
  // Definición de los mundos JVC
  static const Map<String, Map<String, dynamic>> jvcWorlds = {
    'Salud Extrema': {
      'description': 'Cuerpo y mente - Energía, sueño, nutrición, emociones',
      'color': 0xFF4CAF50, // Verde
      'icon': '🧘',
      'focus': ['Ejercicio físico', 'Alimentación saludable', 'Sueño reparador', 'Gestión emocional'],
    },
    'Dinámicas Sociales': {
      'description': 'Vida social y afectiva - Comunicación, empatía, relaciones',
      'color': 0xFF2196F3, // Azul
      'icon': '🤝',
      'focus': ['Comunicación efectiva', 'Empatía', 'Relaciones saludables', 'Redes sociales'],
    },
    'Psicología del Éxito': {
      'description': 'Carrera y propósito - Productividad, dinero, propósito',
      'color': 0xFFFF9800, // Naranja
      'icon': '🚀',
      'focus': ['Productividad', 'Desarrollo profesional', 'Gestión financiera', 'Propósito vital'],
    },
  };

  // Calcular progreso general de JVC
  static double getOverallJvcProgress(UserModel user) {
    final jvcValues = user.jvcProgress.values.toList();
    if (jvcValues.isEmpty) return 0.0;

    final total = jvcValues.reduce((a, b) => a + b);
    return total / (jvcValues.length * 100);
  }

  // Verificar si el usuario puede subir de "cinturón vital"
  static bool canAdvanceBelt(UserModel user) {
    // Todas las JVC deben tener al menos 70% de progreso
    return user.jvcProgress.values.every((progress) => progress >= 70);
  }

  // Obtener recomendaciones basadas en progreso JVC
  static List<String> getJvcRecommendations(UserModel user) {
    final recommendations = <String>[];

    user.jvcProgress.forEach((jvc, progress) {
      if (progress < 50) {
        recommendations.add(_getLowProgressRecommendation(jvc));
      } else if (progress < 80) {
        recommendations.add(_getMediumProgressRecommendation(jvc));
      }
    });

    return recommendations;
  }

  // Obtener recomendación para progreso bajo
  static String _getLowProgressRecommendation(String jvc) {
    switch (jvc) {
      case 'Salud Extrema':
        return 'Enfócate en establecer rutinas básicas de ejercicio y alimentación';
      case 'Dinámicas Sociales':
        return 'Trabaja en mejorar tus habilidades de comunicación diaria';
      case 'Psicología del Éxito':
        return 'Define objetivos claros y establece hábitos de productividad';
      default:
        return 'Trabaja en mejorar esta área vital';
    }
  }

  // Obtener recomendación para progreso medio
  static String _getMediumProgressRecommendation(String jvc) {
    switch (jvc) {
      case 'Salud Extrema':
        return 'Profundiza en técnicas avanzadas de bienestar y mindfulness';
      case 'Dinámicas Sociales':
        return 'Desarrolla relaciones más profundas y mentoría';
      case 'Psicología del Éxito':
        return 'Trabaja en proyectos más ambiciosos y liderazgo';
      default:
        return 'Continúa avanzando en esta área vital';
    }
  }

  // Calcular sinergia entre JVCs
  static Map<String, double> calculateSynergy(UserModel user) {
    final jvcProgress = user.jvcProgress;
    final synergy = <String, double>{};

    // Sinergia Salud - Sociales
    final healthSocialSynergy = (jvcProgress['Salud Extrema'] ?? 0) * 0.6 +
                                (jvcProgress['Dinámicas Sociales'] ?? 0) * 0.4;
    synergy['Salud-Sociales'] = healthSocialSynergy;

    // Sinergia Salud - Éxito
    final healthSuccessSynergy = (jvcProgress['Salud Extrema'] ?? 0) * 0.5 +
                                 (jvcProgress['Psicología del Éxito'] ?? 0) * 0.5;
    synergy['Salud-Éxito'] = healthSuccessSynergy;

    // Sinergia Sociales - Éxito
    final socialSuccessSynergy = (jvcProgress['Dinámicas Sociales'] ?? 0) * 0.4 +
                                 (jvcProgress['Psicología del Éxito'] ?? 0) * 0.6;
    synergy['Sociales-Éxito'] = socialSuccessSynergy;

    return synergy;
  }

  // Obtener mundo actual basado en progreso
  static String getCurrentWorld(UserModel user) {
    final jvcProgress = user.jvcProgress;

    // Encontrar el mundo con menor progreso
    String lowestWorld = 'Salud Extrema';
    int lowestProgress = jvcProgress[lowestWorld] ?? 0;

    jvcProgress.forEach((world, progress) {
      if (progress < lowestProgress) {
        lowestWorld = world;
        lowestProgress = progress;
      }
    });

    return lowestWorld;
  }

  // Actualizar progreso JVC basado en acciones
  static Future<void> updateJvcFromAction(String userId, String actionType, int points) async {
    final user = await SupabaseService.getUserProfile(userId);
    if (user == null) return;

    final jvcUpdates = _calculateJvcImpact(actionType, points);
    final newJvcProgress = Map<String, int>.from(user.jvcProgress);

    jvcUpdates.forEach((jvc, impact) {
      newJvcProgress[jvc] = (newJvcProgress[jvc] ?? 0 + impact).clamp(0, 100);
    });

    await SupabaseService.updateUser(userId, {
      'jvc_progress': newJvcProgress,
    });
  }

  // Calcular impacto de una acción en las JVCs
  static Map<String, int> _calculateJvcImpact(String actionType, int points) {
    // Definir cómo diferentes acciones impactan cada JVC
    final impactMatrix = {
      'exercise': {'Salud Extrema': 3, 'Dinámicas Sociales': 0, 'Psicología del Éxito': 1},
      'meditation': {'Salud Extrema': 2, 'Dinámicas Sociales': 1, 'Psicología del Éxito': 2},
      'social_interaction': {'Salud Extrema': 0, 'Dinámicas Sociales': 3, 'Psicología del Éxito': 1},
      'work_task': {'Salud Extrema': 0, 'Dinámicas Sociales': 0, 'Psicología del Éxito': 3},
      'learning': {'Salud Extrema': 1, 'Dinámicas Sociales': 1, 'Psicología del Éxito': 2},
      'healthy_eating': {'Salud Extrema': 2, 'Dinámicas Sociales': 0, 'Psicología del Éxito': 1},
      'sleep': {'Salud Extrema': 3, 'Dinámicas Sociales': 0, 'Psicología del Éxito': 2},
    };

    final impacts = impactMatrix[actionType] ?? {};
    return impacts.map((jvc, baseImpact) => MapEntry(jvc, (baseImpact * points / 10).round()));
  }

  // Obtener consejos de equilibrio
  static List<String> getBalanceTips(UserModel user) {
    final tips = <String>[];
    final jvcProgress = user.jvcProgress;

    // Encontrar desequilibrios
    final avgProgress = jvcProgress.values.reduce((a, b) => a + b) / jvcProgress.length;

    jvcProgress.forEach((jvc, progress) {
      if (progress < avgProgress - 20) {
        tips.add('Dedica más tiempo a mejorar tu $jvc');
      } else if (progress > avgProgress + 20) {
        tips.add('Tu $jvc está muy avanzada, asegúrate de equilibrar con otras áreas');
      }
    });

    if (tips.isEmpty) {
      tips.add('¡Excelente equilibrio! Mantén el enfoque en todas las áreas');
    }

    return tips;
  }

  // Calcular "puntuación vital" general
  static int calculateVitalScore(UserModel user) {
    final jvcScore = getOverallJvcProgress(user) * 40; // 40% del score
    final levelScore = (user.level / 25).clamp(0, 1) * 30; // 30% del score
    final streakScore = (user.streak / 30).clamp(0, 1) * 20; // 20% del score
    final achievementsScore = (user.logrosDesbloqueados.length / 10).clamp(0, 1) * 10; // 10% del score

    return (jvcScore + levelScore + streakScore + achievementsScore).round();
  }
}