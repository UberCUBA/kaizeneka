import '../../models/progress_models.dart';
import '../../models/user_model.dart';
import '../../models/task_models.dart';
import 'supabase_service.dart';

class ProgressService {
  ProgressService();

  // Gestión de puntos (XP unificado)
  Future<void> addPoints(String userId, int pointsAmount) async {
    final user = await SupabaseService.getUserProfile(userId);
    if (user == null) return;

    final newPoints = user.points + pointsAmount;
    final newBelt = _calculateBeltFromPoints(newPoints);

    await SupabaseService.updateUser(userId, {
      'points': newPoints,
      'belt': newBelt,
    });

    // Verificar desbloqueos por cinturón
    await _checkBeltUnlocks(userId, newBelt);
  }

  Future<void> addCoins(String userId, int coinsAmount) async {
    final user = await SupabaseService.getUserProfile(userId);
    if (user == null) return;

    await SupabaseService.updateUser(userId, {
      'coins': user.coins + coinsAmount,
    });
  }

  // Gestión de rachas
  Future<void> updateStreak(String userId, bool completedToday) async {
    final user = await SupabaseService.getUserProfile(userId);
    if (user == null) return;

    int newStreak = user.streak;
    if (completedToday) {
      newStreak = user.streak + 1;
    } else {
      newStreak = 0;
    }

    await SupabaseService.updateUser(userId, {
      'streak': newStreak,
    });
  }

  // Gestión de energía
  Future<void> consumeEnergy(String userId, int amount) async {
    final user = await SupabaseService.getUserProfile(userId);
    if (user == null) return;

    final newEnergy = (user.energy - amount).clamp(0, 100);
    await SupabaseService.updateUser(userId, {
      'energy': newEnergy,
    });
  }

  Future<void> restoreEnergy(String userId, int amount) async {
    final user = await SupabaseService.getUserProfile(userId);
    if (user == null) return;

    final newEnergy = (user.energy + amount).clamp(0, 100);
    await SupabaseService.updateUser(userId, {
      'energy': newEnergy,
    });
  }

  // Gestión de progreso JVC
  Future<void> updateJvcProgress(String userId, String jvc, int progress) async {
    final user = await SupabaseService.getUserProfile(userId);
    if (user == null) return;

    final newJvcProgress = Map<String, int>.from(user.jvcProgress);
    newJvcProgress[jvc] = progress;

    await SupabaseService.updateUser(userId, {
      'jvc_progress': newJvcProgress,
    });
  }

  // Gestión de misiones narrativas
  Future<List<NarrativeMission>> getNarrativeMissions(String userId) async {
    final user = await SupabaseService.getUserProfile(userId);
    if (user == null) return [];

    // Aquí iría la lógica para obtener misiones desde Supabase
    // Por ahora retornamos una lista vacía
    return [];
  }

  Future<void> completeNarrativeMission(String userId, String missionId) async {
    final user = await SupabaseService.getUserProfile(userId);
    if (user == null) return;

    final mission = await _getNarrativeMission(missionId);
    if (mission == null) return;

    // Agregar puntos (XP) y monedas
    await addPoints(userId, mission.xpReward);
    await addCoins(userId, mission.coinsReward);

    // Marcar misión como completada
    final newUnlockedMissions = List<String>.from(user.unlockedMissions);
    if (!newUnlockedMissions.contains(missionId)) {
      newUnlockedMissions.add(missionId);
    }

    await SupabaseService.updateUser(userId, {
      'unlocked_missions': newUnlockedMissions,
    });

    // Verificar desbloqueos de nuevas misiones
    await _checkMissionUnlocks(userId, mission);
  }

  // Gestión de logros
  Future<List<Achievement>> getAchievements(String userId) async {
    final user = await SupabaseService.getUserProfile(userId);
    if (user == null) return [];

    // Aquí iría la lógica para obtener logros desde Supabase
    return [];
  }

  Future<void> checkAchievements(String userId) async {
    final user = await SupabaseService.getUserProfile(userId);
    if (user == null) return;

    final achievements = await getAchievements(userId);
    final newUnlockedAchievements = List<String>.from(user.unlockedAchievements);

    for (final achievement in achievements) {
      if (!achievement.isUnlocked && _checkAchievementConditions(user, achievement)) {
        newUnlockedAchievements.add(achievement.id);
        // Aplicar recompensas
        await _applyAchievementRewards(userId, achievement);
      }
    }

    await SupabaseService.updateUser(userId, {
      'unlocked_achievements': newUnlockedAchievements,
    });
  }

  // Método auxiliar para calcular cinturón desde puntos
  String _calculateBeltFromPoints(int points) {
    if (points >= 500) return 'Sobrado';
    if (points >= 350) return 'Negro';
    if (points >= 250) return 'Marrón';
    if (points >= 150) return 'Verde';
    if (points >= 80) return 'Naranja';
    if (points >= 30) return 'Amarillo';
    return 'Blanco';
  }

  // Método auxiliar para verificar desbloqueos por cinturón
  Future<void> _checkBeltUnlocks(String userId, String newBelt) async {
    // Lógica para desbloquear misiones por cinturón alcanzado
    // Implementar según las reglas del sistema
  }

  // Métodos auxiliares
  Future<void> _checkLevelUnlocks(String userId, int newLevel) async {
    // Lógica para desbloquear misiones por nivel alcanzado
    // Implementar según las reglas del sistema
  }

  Future<void> _checkMissionUnlocks(String userId, NarrativeMission mission) async {
    // Lógica para desbloquear siguientes misiones en la narrativa
  }

  Future<NarrativeMission?> _getNarrativeMission(String missionId) async {
    // Obtener misión específica desde Supabase
    return null;
  }

  bool _checkAchievementConditions(UserModel user, Achievement achievement) {
    // Lógica para verificar condiciones de logros
    return false;
  }

  Future<void> _applyAchievementRewards(String userId, Achievement achievement) async {
    // Aplicar recompensas de logros
  }

  // Métodos estáticos para cálculos
  static int calculatePointsRequiredForBelt(String belt) {
    const beltRequirements = {
      'Blanco': 0,
      'Amarillo': 30,
      'Naranja': 80,
      'Verde': 150,
      'Marrón': 250,
      'Negro': 350,
      'Sobrado': 500,
    };
    return beltRequirements[belt] ?? 0;
  }

  static String getBeltFromPoints(int points) {
    if (points >= 500) return 'Sobrado';
    if (points >= 350) return 'Negro';
    if (points >= 250) return 'Marrón';
    if (points >= 150) return 'Verde';
    if (points >= 80) return 'Naranja';
    if (points >= 30) return 'Amarillo';
    return 'Blanco';
  }

  static int calculateXpReward(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return 5;
      case Difficulty.medium:
        return 10;
      case Difficulty.hard:
        return 20;
      default:
        return 10;
    }
  }

  static int calculateCoinsReward(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return 1;
      case Difficulty.medium:
        return 2;
      case Difficulty.hard:
        return 4;
      default:
        return 2;
    }
  }
}