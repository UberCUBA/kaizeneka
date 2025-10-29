import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/theme_provider.dart' as custom_theme;
import '../providers/mission_provider.dart';
import '../../../../models/task_models.dart';

class MissionsPage extends StatefulWidget {
  final String? searchQuery;
  final Difficulty? selectedDifficulty;
  final bool? showCompleted;
  final bool? showSystemMissions;

  const MissionsPage({
    super.key,
    this.searchQuery,
    this.selectedDifficulty,
    this.showCompleted,
    this.showSystemMissions,
  });

  @override
  State<MissionsPage> createState() => _MissionsPageState();
}

class _MissionsPageState extends State<MissionsPage> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<custom_theme.ThemeProvider>(context);
    final missionProvider = Provider.of<MissionProvider>(context);

    // Aplicar filtros a las misiones
    final filteredMissions = _filterMissions(missionProvider.missions);

    return Scaffold(
      backgroundColor: themeProvider.isDarkMode ? Colors.black : const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Text(
                      //   'Misiones',
                      //   style: TextStyle(
                      //     fontSize: 24,
                      //     fontWeight: FontWeight.bold,
                      //     color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                      //   ),
                      // ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00FF7F).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '${_getPendingMissions(filteredMissions).length} pendientes',
                          style: const TextStyle(
                            color: Color(0xFF00FF7F),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.stars,
                        color: themeProvider.isDarkMode ? Colors.grey : Colors.black54,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${_getTotalPoints(filteredMissions)} puntos totales',
                        style: TextStyle(
                          fontSize: 14,
                          color: themeProvider.isDarkMode ? Colors.grey : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Missions List
            Expanded(
              child: missionProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredMissions.isEmpty
                      ? _buildEmptyState(themeProvider)
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredMissions.length,
                          itemBuilder: (context, index) {
                            final mission = filteredMissions[index];
                            return _buildMissionCard(mission, themeProvider, missionProvider);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  List<Mission> _filterMissions(List<Mission> missions) {
    return missions.where((mission) {
      // Filtro de búsqueda
      if (widget.searchQuery != null && widget.searchQuery!.isNotEmpty) {
        final query = widget.searchQuery!.toLowerCase();
        if (!mission.title.toLowerCase().contains(query) &&
            (mission.notes == null || !mission.notes!.toLowerCase().contains(query))) {
          return false;
        }
      }

      // Filtro de dificultad
      if (widget.selectedDifficulty != null && mission.difficulty != widget.selectedDifficulty) {
        return false;
      }

      // Filtro de estado completado
      if (widget.showCompleted != null) {
        if (widget.showCompleted! && !mission.isCompleted) {
          return false;
        }
        if (!widget.showCompleted! && mission.isCompleted) {
          return false;
        }
      }

      // Filtro de tipo de misión
      if (widget.showSystemMissions != null) {
        if (widget.showSystemMissions! && !mission.isSystemMission) {
          return false;
        }
        if (!widget.showSystemMissions! && mission.isSystemMission) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  List<Mission> _getPendingMissions(List<Mission> missions) {
    return missions.where((mission) => !mission.isCompleted).toList();
  }

  int _getTotalPoints(List<Mission> missions) {
    return missions.where((mission) => mission.isCompleted).fold(0, (sum, mission) => sum + mission.points);
  }

  Widget _buildEmptyState(custom_theme.ThemeProvider themeProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.flag,
            size: 64,
            color: themeProvider.isDarkMode ? Colors.grey : Colors.black26,
          ),
          const SizedBox(height: 16),
          Text(
            'No tienes misiones activas',
            style: TextStyle(
              fontSize: 18,
              color: themeProvider.isDarkMode ? Colors.grey : Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '¡Completa misiones para ganar puntos!',
            style: TextStyle(
              fontSize: 14,
              color: themeProvider.isDarkMode ? Colors.grey : Colors.black38,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMissionCard(Mission mission, custom_theme.ThemeProvider themeProvider, MissionProvider missionProvider) {
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
                // Badge para tipo de misión
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: mission.isSystemMission
                        ? const Color(0xFF00FF7F).withOpacity(0.1) // NK - Verde
                        : Colors.blue.withOpacity(0.1), // Personal - Azul
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: mission.isSystemMission
                          ? const Color(0xFF00FF7F)
                          : Colors.blue,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    mission.isSystemMission ? 'NK' : 'P',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: mission.isSystemMission
                          ? const Color(0xFF00FF7F)
                          : Colors.blue,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    mission.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                      decoration: mission.isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Text(
                      '${mission.points}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF00FF7F),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.stars,
                      size: 16,
                      color: const Color(0xFF00FF7F),
                    ),
                    const SizedBox(width: 8),
                    Checkbox(
                      value: mission.isCompleted,
                      onChanged: (value) {
                        if (value != null) {
                          missionProvider.toggleMissionCompletion(mission.id);
                        }
                      },
                      activeColor: const Color(0xFF00FF7F),
                    ),
                  ],
                ),
              ],
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

            // Mission metadata
            Row(
              children: [
                _buildDifficultyChip(mission.difficulty),
                const SizedBox(width: 8),
                // Badge adicional para tipo de misión (más descriptivo)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: mission.isSystemMission
                        ? Colors.purple.withOpacity(0.1)
                        : Colors.teal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    mission.isSystemMission ? 'Sistema NK' : 'Personal',
                    style: TextStyle(
                      fontSize: 10,
                      color: mission.isSystemMission ? Colors.purple : Colors.teal,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  _formatDate(mission.startDate),
                  style: TextStyle(
                    fontSize: 12,
                    color: themeProvider.isDarkMode ? Colors.grey : Colors.black54,
                  ),
                ),
                if (mission.repeatType != null) ...[
                  const SizedBox(width: 8),
                  Icon(
                    Icons.repeat,
                    size: 14,
                    color: themeProvider.isDarkMode ? Colors.grey : Colors.black54,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    mission.repeatType!.name,
                    style: TextStyle(
                      fontSize: 12,
                      color: themeProvider.isDarkMode ? Colors.grey : Colors.black54,
                    ),
                  ),
                ],
              ],
            ),

            // SubMissions
            if (mission.subMissions.isNotEmpty) ...[
              const SizedBox(height: 12),
              ...mission.subMissions.map((subMission) => _buildSubMissionItem(subMission, mission.id, missionProvider, themeProvider)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyChip(Difficulty difficulty) {
    final color = _getDifficultyColor(difficulty);
    final label = _getDifficultyLabel(difficulty);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildSubMissionItem(SubMission subMission, String missionId, MissionProvider missionProvider, custom_theme.ThemeProvider themeProvider) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: Checkbox(
              value: subMission.isCompleted,
              onChanged: (value) {
                if (value != null) {
                  missionProvider.toggleSubMissionCompletion(missionId, subMission.id);
                }
              },
              activeColor: const Color(0xFF00FF7F),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              subMission.title,
              style: TextStyle(
                fontSize: 14,
                color: themeProvider.isDarkMode ? Colors.white70 : Colors.black87,
                decoration: subMission.isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
          if (subMission.points != null) ...[
            const SizedBox(width: 8),
            Text(
              '+${subMission.points}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF00FF7F),
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.stars,
              size: 12,
              color: const Color(0xFF00FF7F),
            ),
          ],
        ],
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return 'Hoy';
    } else if (difference == 1) {
      return 'Ayer';
    } else if (difference < 7) {
      return 'Hace $difference días';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}