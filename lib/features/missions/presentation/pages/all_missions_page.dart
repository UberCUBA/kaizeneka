import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/theme_provider.dart' as custom_theme;
import '../providers/mission_provider.dart';
import '../../../../models/task_models.dart';

class AllMissionsPage extends StatefulWidget {
  const AllMissionsPage({super.key});

  @override
  State<AllMissionsPage> createState() => _AllMissionsPageState();
}

class _AllMissionsPageState extends State<AllMissionsPage> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<custom_theme.ThemeProvider>(context);
    final missionProvider = Provider.of<MissionProvider>(context);

    final allSystemMissions = missionProvider.missions.where((m) => m.isSystemMission).toList();
    final unlockedMissions = missionProvider.unlockedSystemMissions;
    final lockedMissions = missionProvider.lockedSystemMissions;

    return Scaffold(
      backgroundColor: themeProvider.isDarkMode ? Colors.black : const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: themeProvider.isDarkMode ? Colors.black : Colors.white,
        title: Text(
          'Misiones NK',
          style: TextStyle(
            color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(
          color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header con estadísticas
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatCard(
                        'Puntos',
                        '${missionProvider.user?.puntos ?? 0}',
                        const Color(0xFF00FF7F),
                        themeProvider,
                      ),
                      _buildStatCard(
                        'Desbloqueadas',
                        unlockedMissions.length.toString(),
                        Colors.green,
                        themeProvider,
                      ),
                      _buildStatCard(
                        'Bloqueadas',
                        lockedMissions.length.toString(),
                        Colors.orange,
                        themeProvider,
                      ),
                      
                    ],
                  ),
                ],
              ),
            ),

            // Lista de misiones
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Misiones desbloqueadas
                  if (unlockedMissions.isNotEmpty) ...[
                    _buildSectionHeader('Misiones Desbloqueadas', Colors.green, themeProvider),
                    ...unlockedMissions.map((mission) => _buildMissionCard(mission, true, themeProvider, missionProvider)),
                  ],

                  // Misiones bloqueadas
                  if (lockedMissions.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _buildSectionHeader('Misiones Bloqueadas', Colors.orange, themeProvider),
                    ...lockedMissions.map((mission) => _buildMissionCard(mission, false, themeProvider, missionProvider)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color, custom_theme.ThemeProvider themeProvider) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode ? const Color(0xFF1C1C1C) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: themeProvider.isDarkMode ? Colors.grey : Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color, custom_theme.ThemeProvider themeProvider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            title.contains('Desbloqueadas') ? Icons.check_circle : Icons.lock,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMissionCard(Mission mission, bool isUnlocked, custom_theme.ThemeProvider themeProvider, MissionProvider missionProvider) {
    final missionIndex = missionProvider.lockedSystemMissions.indexOf(mission);
    final requiredPoints = isUnlocked ? 0 : (missionIndex >= 0 ? (missionIndex + 1) * 5 : 5);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: themeProvider.isDarkMode ? const Color(0xFF1C1C1C) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isUnlocked
                        ? const Color(0xFF00FF7F).withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isUnlocked
                          ? const Color(0xFF00FF7F)
                          : Colors.grey,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    isUnlocked ? 'Desbloqueada' : 'Bloqueada',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isUnlocked
                          ? const Color(0xFF00FF7F)
                          : Colors.grey,
                    ),
                  ),
                ),
                const Spacer(),
                if (isUnlocked)
                  Icon(
                    Icons.check_circle,
                    color: mission.isCompleted ? const Color(0xFF00FF7F) : Colors.grey[400],
                    size: 20,
                  )
                else
                  Icon(
                    Icons.lock,
                    color: Colors.grey,
                    size: 20,
                  ),
              ],
            ),

            const SizedBox(height: 8),
            Text(
              mission.title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                decoration: mission.isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),

            if (mission.notes != null && mission.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                mission.notes!,
                style: TextStyle(
                  fontSize: 14,
                  color: themeProvider.isDarkMode ? Colors.grey : Colors.black54,
                ),
              ),
            ],

            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getDifficultyColor(mission.difficulty).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getDifficultyLabel(mission.difficulty),
                    style: TextStyle(
                      fontSize: 12,
                      color: _getDifficultyColor(mission.difficulty),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '${mission.points} puntos',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF00FF7F),
                  ),
                ),
              ],
            ),

            if (!isUnlocked) ...[
              const SizedBox(height: 8),
              Text(
                'Necesitas $requiredPoints puntos para desbloquear',
                style: TextStyle(
                  fontSize: 12,
                  color: themeProvider.isDarkMode ? Colors.grey[400] : Colors.black38,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getDifficultyColor(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return Colors.green;
      case Difficulty.medium:
        return Colors.orange;
      case Difficulty.hard:
        return Colors.red;
    }
  }

  String _getDifficultyLabel(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy:
        return 'Fácil';
      case Difficulty.medium:
        return 'Intermedia';
      case Difficulty.hard:
        return 'Difícil';
    }
  }
}