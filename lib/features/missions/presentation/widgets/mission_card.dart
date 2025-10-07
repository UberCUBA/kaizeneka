import 'package:flutter/material.dart';
import '../../domain/entities/mission.dart';

class MissionCard extends StatelessWidget {
  final Mission mission;

  const MissionCard({super.key, required this.mission});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1C1C1C),
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Día ${mission.id}: ${mission.categoria}',
              style: const TextStyle(
                color: Color(0xFF00FF7F),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              mission.descripcion,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Beneficio: ${mission.beneficio}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}