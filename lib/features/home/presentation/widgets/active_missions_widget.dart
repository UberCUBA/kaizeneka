import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../missions/presentation/providers/mission_provider.dart';
import '../../../missions/domain/entities/mission.dart' as mission_entity;
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../models/task_models.dart';

class ActiveMissionsWidget extends StatelessWidget {
  const ActiveMissionsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<MissionProvider, AuthProvider>(
      builder: (context, missionProvider, authProvider, child) {
        final userId = authProvider.user?.id;
        if (userId == null) return const SizedBox.shrink();

        final activeMissions = missionProvider.pendingMissions
            .take(3) // Mostrar máximo 3 misiones activas
            .toList();

        if (activeMissions.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1C),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF00FF7F), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.assignment,
                    color: Color(0xFF00FF7F),
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Misiones Activas',
                    style: TextStyle(
                      color: Color(0xFF00FF7F),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      // Navegar a la pantalla de misiones
                      Navigator.of(context).pushNamed('/all-missions');
                    },
                    child: const Text(
                      'Ver todas',
                      style: TextStyle(
                        color: Color(0xFF00FF7F),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...activeMissions.map((mission) => _buildMissionItem(context, mission)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMissionItem(BuildContext context, Mission mission) {
    return InkWell(
      onTap: () {
        // Navegar a la pantalla de todas las misiones
        Navigator.of(context).pushNamed('/all-missions');
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: _getDifficultyColor(mission.difficulty),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mission.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${mission.points} XP',
                    style: const TextStyle(
                      color: Color(0xFF00FF7F),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Colors.white54,
              size: 20,
            ),
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
      default:
        return Colors.grey;
    }
  }
}