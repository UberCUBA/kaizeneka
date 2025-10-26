import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/repositories/mission_repository.dart';
import '../../domain/entities/mission.dart';
import '../widgets/mission_card.dart';

class AllMissionsPage extends StatefulWidget {
  const AllMissionsPage({super.key});

  @override
  State<AllMissionsPage> createState() => _AllMissionsPageState();
}

class _AllMissionsPageState extends State<AllMissionsPage> {
  List<Mission> missions = [];

  @override
  void initState() {
    super.initState();
    _loadMissions();
  }

  Future<void> _loadMissions() async {
    final prefs = await SharedPreferences.getInstance();
    final repository = MissionRepositoryImpl(prefs);
    setState(() {
      missions = repository.getAllMissions();
    });
  }

  @override
  Widget build(BuildContext context) {
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