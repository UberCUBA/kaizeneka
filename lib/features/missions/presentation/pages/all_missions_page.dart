import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/mission_provider.dart';
import '../widgets/mission_card.dart';

class AllMissionsPage extends StatelessWidget {
  const AllMissionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final missionProvider = Provider.of<MissionProvider>(context);
    final missions = missionProvider.getMissionsList();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Todas las Misiones', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        itemCount: missions.length,
        itemBuilder: (context, index) {
          final mission = missions[index];
          return MissionCard(mission: mission);
        },
      ),
    );
  }
}