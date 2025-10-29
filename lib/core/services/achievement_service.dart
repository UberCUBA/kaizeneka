import '../../models/progress_models.dart';

class AchievementService {
  // Lista completa de logros
  static final List<Achievement> allAchievements = [
    // Logros de Comienzo
    Achievement(
      id: 'comienzo_epico',
      name: 'Comienzo Épico',
      description: 'Completa tu primera tarea',
      icon: '🎯',
      conditions: {'first_task_completed': true},
      rewards: {'xp': 5, 'coins': 1},
    ),
    Achievement(
      id: 'primer_habito',
      name: 'Primer Hábito',
      description: 'Crea tu primer hábito',
      icon: '🌱',
      conditions: {'habits_created': 1},
      rewards: {'xp': 10, 'coins': 2},
    ),

    // Logros de Consistencia
    Achievement(
      id: 'maniaco_orden',
      name: 'Maníaco del Orden',
      description: '10 tareas en 1 día',
      icon: '📋',
      conditions: {'tasks_completed_today': 10},
      rewards: {'xp': 25, 'coins': 5},
    ),
    Achievement(
      id: 'racha_7',
      name: 'Semana Perfecta',
      description: '7 días seguidos sin fallar',
      icon: '🔥',
      conditions: {'streak': 7},
      rewards: {'xp': 50, 'coins': 10},
    ),
    Achievement(
      id: 'racha_14',
      name: 'Fortaleza Mental',
      description: '14 días de racha consecutiva',
      icon: '💪',
      conditions: {'streak': 14},
      rewards: {'xp': 75, 'coins': 15},
    ),
    Achievement(
      id: 'racha_30',
      name: 'Maestro del Hábito',
      description: '30 días de consistencia',
      icon: '👑',
      conditions: {'streak': 30},
      rewards: {'xp': 100, 'coins': 20},
    ),

    // Logros de Hábitos
    Achievement(
      id: 'habito_oro',
      name: 'Hábito de Oro',
      description: 'Mantiene un hábito por 30 días',
      icon: '🥇',
      conditions: {'habit_streak': 30},
      rewards: {'xp': 50, 'coins': 10},
    ),
    Achievement(
      id: 'coleccionista_habitos',
      name: 'Coleccionista de Hábitos',
      description: 'Crea 10 hábitos diferentes',
      icon: '📚',
      conditions: {'habits_created': 10},
      rewards: {'xp': 40, 'coins': 8},
    ),

    // Logros de Misiones
    Achievement(
      id: 'cazador_rdps',
      name: 'Cazador de RDPs',
      description: 'Sellar 10 rendijas',
      icon: '🕳️',
      conditions: {'missions_completed': 10},
      rewards: {'xp': 30, 'coins': 6},
    ),
    Achievement(
      id: 'guerrero_kaizen',
      name: 'Guerrero Kaizen',
      description: 'Completa 25 misiones',
      icon: '⚔️',
      conditions: {'missions_completed': 25},
      rewards: {'xp': 75, 'coins': 15},
    ),

    // Logros de Progreso
    Achievement(
      id: 'nivel_5',
      name: 'Ascendido',
      description: 'Alcanza el nivel 5',
      icon: '⬆️',
      conditions: {'level': 5},
      rewards: {'xp': 25, 'coins': 5},
    ),
    Achievement(
      id: 'nivel_10',
      name: 'Maestro',
      description: 'Alcanza el nivel 10',
      icon: '🎓',
      conditions: {'level': 10},
      rewards: {'xp': 100, 'coins': 20},
    ),
    Achievement(
      id: 'nivel_25',
      name: 'Leyenda',
      description: 'Alcanza el nivel 25',
      icon: '🏆',
      conditions: {'level': 25},
      rewards: {'xp': 200, 'coins': 50},
    ),

    // Logros de Energía
    Achievement(
      id: 'energia_maxima',
      name: 'Tanque Lleno',
      description: 'Alcanza energía máxima',
      icon: '🔋',
      conditions: {'energy': 100},
      rewards: {'xp': 15, 'coins': 3},
    ),

    // Logros de Mundos JVC
    Achievement(
      id: 'equilibrio_jvc',
      name: 'Equilibrio Perfecto',
      description: 'Mantén las 3 JVCs balanceadas por una semana',
      icon: '⚖️',
      conditions: {'jvc_balance_days': 7},
      rewards: {'xp': 60, 'coins': 12},
    ),

    // Logros Especiales
    Achievement(
      id: 'version_sobrada',
      name: 'Versión Sobradísima',
      description: 'Completa los 30 días del programa',
      icon: '😎',
      conditions: {'program_completed': true},
      rewards: {'xp': 150, 'coins': 30},
    ),
    Achievement(
      id: 'mentor_comunitario',
      name: 'Mentor Comunitario',
      description: 'Ayuda a 5 usuarios diferentes',
      icon: '🤝',
      conditions: {'users_helped': 5},
      rewards: {'xp': 80, 'coins': 16},
    ),

    // Logros de Arcos Narrativos
    Achievement(
      id: 'despertar_completo',
      name: 'Despertado',
      description: 'Completa el Arco del Despertar',
      icon: '🌅',
      conditions: {'arc_despertar_completed': true},
      rewards: {'xp': 100, 'coins': 20},
    ),
    Achievement(
      id: 'entrenamiento_completo',
      name: 'Entrenado',
      description: 'Completa el Arco del Entrenamiento',
      icon: '🏋️',
      conditions: {'arc_entrenamiento_completed': true},
      rewards: {'xp': 150, 'coins': 30},
    ),
    Achievement(
      id: 'disciplina_completa',
      name: 'Disciplinado',
      description: 'Completa el Arco de la Disciplina',
      icon: '🎯',
      conditions: {'arc_disciplina_completed': true},
      rewards: {'xp': 200, 'coins': 40},
    ),
    Achievement(
      id: 'sinergia_completa',
      name: 'Sinérgico',
      description: 'Completa el Arco de la Sinergia',
      icon: '🔗',
      conditions: {'arc_sinergia_completed': true},
      rewards: {'xp': 250, 'coins': 50},
    ),
    Achievement(
      id: 'disolucion_completa',
      name: 'Disuelto',
      description: 'Completa el Arco de la Disolución',
      icon: '🧘',
      conditions: {'arc_disolucion_completed': true},
      rewards: {'xp': 300, 'coins': 60},
    ),
    Achievement(
      id: 'sobradez_completa',
      name: 'Sobrador',
      description: 'Completa el Arco de la Sobradez',
      icon: '👑',
      conditions: {'arc_sobradez_completed': true},
      rewards: {'xp': 350, 'coins': 70},
    ),
    Achievement(
      id: 'trascendencia_completa',
      name: 'Trascendido',
      description: 'Completa el Arco de la Trascendencia',
      icon: '✨',
      conditions: {'arc_trascendencia_completed': true},
      rewards: {'xp': 500, 'coins': 100},
    ),

    // Logros de Comunidad
    Achievement(
      id: 'compartidor_sabiduria',
      name: 'Compartidor de Sabiduría',
      description: 'Comparte 10 consejos en la comunidad',
      icon: '📢',
      conditions: {'posts_shared': 10},
      rewards: {'xp': 40, 'coins': 8},
    ),
    Achievement(
      id: 'inspirador',
      name: 'Inspirador',
      description: 'Tus posts reciben 100 likes',
      icon: '⭐',
      conditions: {'total_likes_received': 100},
      rewards: {'xp': 60, 'coins': 12},
    ),

    // Logros de Productividad
    Achievement(
      id: 'productor_legendario',
      name: 'Productor Legendario',
      description: 'Completa 100 tareas',
      icon: '🚀',
      conditions: {'total_tasks_completed': 100},
      rewards: {'xp': 100, 'coins': 20},
    ),
    Achievement(
      id: 'eficiencia_maxima',
      name: 'Eficiencia Máxima',
      description: 'Completa 50 tareas en una semana',
      icon: '⚡',
      conditions: {'tasks_week': 50},
      rewards: {'xp': 80, 'coins': 16},
    ),

    // Logros de Salud
    Achievement(
      id: 'guerrero_salud',
      name: 'Guerrero de la Salud',
      description: 'Completa 30 días de hábitos de ejercicio',
      icon: '💪',
      conditions: {'exercise_days': 30},
      rewards: {'xp': 70, 'coins': 14},
    ),
    Achievement(
      id: 'mente_equilibrada',
      name: 'Mente Equilibrada',
      description: 'Practica meditación por 30 días',
      icon: '🧠',
      conditions: {'meditation_days': 30},
      rewards: {'xp': 60, 'coins': 12},
    ),

    // Logros Ocultos
    Achievement(
      id: 'resurreccion',
      name: 'Resurrección',
      description: 'Vuelve después de perder una racha de 14 días',
      icon: '🔄',
      conditions: {'comeback_after_streak_loss': true},
      rewards: {'xp': 50, 'coins': 10},
    ),
    Achievement(
      id: 'perfeccionista',
      name: 'Perfeccionista',
      description: 'Completa todas las tareas de un día sin errores',
      icon: '💎',
      conditions: {'perfect_day': true},
      rewards: {'xp': 30, 'coins': 6},
    ),
  ];

  // Obtener logros disponibles para un usuario
  static List<Achievement> getAvailableAchievements(Map<String, dynamic> userStats) {
    return allAchievements.where((achievement) {
      return !userStats.containsKey('unlocked_achievements') ||
             !(userStats['unlocked_achievements'] as List).contains(achievement.id);
    }).toList();
  }

  // Verificar si se desbloquea un logro
  static bool checkAchievementUnlock(Achievement achievement, Map<String, dynamic> userStats) {
    return achievement.conditions.entries.every((condition) {
      final key = condition.key;
      final requiredValue = condition.value;

      if (!userStats.containsKey(key)) return false;

      final userValue = userStats[key];

      if (requiredValue is bool) {
        return userValue == requiredValue;
      } else if (requiredValue is num) {
        return (userValue as num) >= requiredValue;
      } else if (requiredValue is String) {
        return userValue == requiredValue;
      }

      return false;
    });
  }

  // Obtener logros desbloqueados
  static List<Achievement> getUnlockedAchievements(List<String> unlockedIds) {
    return allAchievements.where((achievement) => unlockedIds.contains(achievement.id)).toList();
  }

  // Calcular progreso de logro (para logros con progreso)
  static double getAchievementProgress(Achievement achievement, Map<String, dynamic> userStats) {
    if (achievement.conditions.length != 1) return 0.0;

    final condition = achievement.conditions.entries.first;
    final key = condition.key;
    final requiredValue = condition.value;

    if (!userStats.containsKey(key) || !(requiredValue is num)) return 0.0;

    final userValue = userStats[key] as num;
    return (userValue / requiredValue).clamp(0.0, 1.0);
  }

  // Obtener logros por categoría
  static Map<String, List<Achievement>> getAchievementsByCategory() {
    final categories = {
      'Comienzo': ['comienzo_epico', 'primer_habito'],
      'Consistencia': ['maniaco_orden', 'racha_7', 'racha_14', 'racha_30'],
      'Hábitos': ['habito_oro', 'coleccionista_habitos'],
      'Misiones': ['cazador_rdps', 'guerrero_kaizen'],
      'Progreso': ['nivel_5', 'nivel_10', 'nivel_25'],
      'Energía': ['energia_maxima'],
      'Equilibrio': ['equilibrio_jvc'],
      'Especiales': ['version_sobrada', 'mentor_comunitario'],
      'Arcos': ['despertar_completo', 'entrenamiento_completo', 'disciplina_completa', 'sinergia_completa', 'disolucion_completa', 'sobradez_completa', 'trascendencia_completa'],
      'Comunidad': ['compartidor_sabiduria', 'inspirador'],
      'Productividad': ['productor_legendario', 'eficiencia_maxima'],
      'Salud': ['guerrero_salud', 'mente_equilibrada'],
      'Ocultos': ['resurreccion', 'perfeccionista'],
    };

    return categories.map((category, ids) => MapEntry(
      category,
      allAchievements.where((achievement) => ids.contains(achievement.id)).toList(),
    ));
  }
}