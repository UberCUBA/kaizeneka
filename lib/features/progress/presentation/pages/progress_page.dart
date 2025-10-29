import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../missions/presentation/providers/mission_provider.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/services/progress_service.dart' as progress_service;
import '../../../../core/services/narrative_service.dart';
import '../../../../core/services/achievement_service.dart';
import '../../../../models/progress_models.dart' as progress_models;

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Método auxiliar para obtener el siguiente cinturón
  String _getNextBelt(String currentBelt) {
    const beltOrder = ['Blanco', 'Amarillo', 'Naranja', 'Verde', 'Marrón', 'Negro', 'Sobrado'];
    final currentIndex = beltOrder.indexOf(currentBelt);
    if (currentIndex == -1 || currentIndex == beltOrder.length - 1) return currentBelt;
    return beltOrder[currentIndex + 1];
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final userProfile = authProvider.userProfile;

    if (userProfile == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: themeProvider.isDarkMode ? Colors.black : const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: themeProvider.isDarkMode ? Colors.black : Colors.white,
        title: const Text('Mi Progreso', style: TextStyle(color: Color(0xFF00FF7F))),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF00FF7F),
          unselectedLabelColor: themeProvider.isDarkMode ? Colors.grey : Colors.black54,
          indicatorColor: const Color(0xFF00FF7F),
          tabs: const [
            Tab(text: 'Nivel'),
            Tab(text: 'Misiones'),
            Tab(text: 'Logros'),
            Tab(text: 'Estadísticas'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLevelTab(userProfile, themeProvider),
          _buildMissionsTab(userProfile, themeProvider),
          _buildAchievementsTab(userProfile, themeProvider),
          _buildStatsTab(userProfile, themeProvider),
        ],
      ),
    );
  }

  Widget _buildLevelTab(userProfile, ThemeProvider themeProvider) {
    final currentPoints = userProfile.points;
    final currentBelt = userProfile.belt;
    final nextBelt = _getNextBelt(currentBelt);
    final pointsForNextBelt = progress_service.ProgressService.calculatePointsRequiredForBelt(nextBelt);
    final pointsForCurrentBelt = progress_service.ProgressService.calculatePointsRequiredForBelt(currentBelt);
    final pointsProgress = currentPoints - pointsForCurrentBelt;
    final pointsNeeded = pointsForNextBelt - pointsForCurrentBelt;
    final progressPercent = pointsNeeded > 0 ? (pointsProgress / pointsNeeded).clamp(0.0, 1.0) : 1.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Nivel actual
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: themeProvider.isDarkMode ? const Color(0xFF1C1C1C) : Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: themeProvider.isDarkMode ? null : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  'CINTURÓN',
                  style: TextStyle(
                    color: Color(0xFF00FF7F),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  currentBelt,
                  style: TextStyle(
                    color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Nivel ${userProfile.level}',
                  style: TextStyle(
                    color: themeProvider.isDarkMode ? Colors.grey : Colors.black54,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 20),
                // Barra de progreso
                Container(
                  height: 12,
                  decoration: BoxDecoration(
                    color: themeProvider.isDarkMode ? Colors.grey[800] : Colors.grey[200],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: progressPercent,
                      backgroundColor: Colors.transparent,
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00FF7F)),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '${pointsProgress.toInt()}/${pointsNeeded.toInt()} Puntos',
                  style: TextStyle(
                    color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Próximo: $nextBelt',
                  style: TextStyle(
                    color: themeProvider.isDarkMode ? Colors.grey : Colors.black54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Estadísticas de progreso
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: themeProvider.isDarkMode ? const Color(0xFF1C1C1C) : Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: themeProvider.isDarkMode ? null : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ESTADÍSTICAS',
                  style: TextStyle(
                    color: Color(0xFF00FF7F),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),
                _buildStatRow('Puntos Totales', currentPoints.toString(), themeProvider),
                _buildStatRow('Monedas', userProfile.coins.toString(), themeProvider),
                _buildStatRow('Racha Actual', '${userProfile.streak} días', themeProvider),
                _buildStatRow('Energía', '${userProfile.energy}/100', themeProvider),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Mundo actual
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: themeProvider.isDarkMode ? const Color(0xFF1C1C1C) : Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: themeProvider.isDarkMode ? null : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  'MUNDO ACTUAL',
                  style: TextStyle(
                    color: Color(0xFF00FF7F),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  userProfile.currentWorld,
                  style: TextStyle(
                    color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Arco ${userProfile.currentArc}: ${progress_models.Arc.values[userProfile.currentArc].name}',
                  style: TextStyle(
                    color: themeProvider.isDarkMode ? Colors.grey : Colors.black54,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMissionsTab(userProfile, ThemeProvider themeProvider) {
    // Aquí iría la lógica para mostrar misiones narrativas disponibles
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: themeProvider.isDarkMode ? const Color(0xFF1C1C1C) : Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: themeProvider.isDarkMode ? null : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  'MISIONES NARRATIVAS',
                  style: TextStyle(
                    color: Color(0xFF00FF7F),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Sistema de misiones próximamente disponible',
                  style: TextStyle(
                    color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  'Misiones completadas: ${userProfile.misionesCompletadas.length}',
                  style: TextStyle(
                    color: themeProvider.isDarkMode ? Colors.grey : Colors.black54,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsTab(userProfile, ThemeProvider themeProvider) {
    // Aquí iría la lógica para mostrar logros desbloqueados
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: themeProvider.isDarkMode ? const Color(0xFF1C1C1C) : Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: themeProvider.isDarkMode ? null : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  'LOGROS DESBLOQUEADOS',
                  style: TextStyle(
                    color: Color(0xFF00FF7F),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Sistema de logros próximamente disponible',
                  style: TextStyle(
                    color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  'Logros desbloqueados: ${userProfile.logrosDesbloqueados.length}',
                  style: TextStyle(
                    color: themeProvider.isDarkMode ? Colors.grey : Colors.black54,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsTab(userProfile, ThemeProvider themeProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Estadísticas detalladas
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: themeProvider.isDarkMode ? const Color(0xFF1C1C1C) : Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: themeProvider.isDarkMode ? null : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ESTADÍSTICAS DETALLADAS',
                  style: TextStyle(
                    color: Color(0xFF00FF7F),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                _buildDetailedStat('Días Completados', userProfile.diasCompletados.toString(), themeProvider),
                _buildDetailedStat('Misiones Completadas', userProfile.misionesCompletadas.length.toString(), themeProvider),
                _buildDetailedStat('Logros Desbloqueados', userProfile.logrosDesbloqueados.length.toString(), themeProvider),
                _buildDetailedStat('Tareas Diarias Promedio', '5.2', themeProvider), // TODO: Calcular real
                _buildDetailedStat('Hábitos Activos', '3', themeProvider), // TODO: Calcular real
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Progreso JVC
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: themeProvider.isDarkMode ? const Color(0xFF1C1C1C) : Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: themeProvider.isDarkMode ? null : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'PROGRESO JVC',
                  style: TextStyle(
                    color: Color(0xFF00FF7F),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                _buildJvcProgress('Salud Extrema', userProfile.jvcProgress['Salud'] ?? 0, themeProvider),
                const SizedBox(height: 15),
                _buildJvcProgress('Dinámicas Sociales', userProfile.jvcProgress['Dinámicas Sociales'] ?? 0, themeProvider),
                const SizedBox(height: 15),
                _buildJvcProgress('Psicología del Éxito', userProfile.jvcProgress['Psicología del Éxito'] ?? 0, themeProvider),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, ThemeProvider themeProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
              fontSize: 16,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF00FF7F),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedStat(String label, String value, ThemeProvider themeProvider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode ? Colors.grey[800] : Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
              fontSize: 16,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF00FF7F),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJvcProgress(String jvcName, int progress, ThemeProvider themeProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          jvcName,
          style: TextStyle(
            color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: themeProvider.isDarkMode ? Colors.grey[800] : Colors.grey[200],
            borderRadius: BorderRadius.circular(4),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress / 100,
              backgroundColor: Colors.transparent,
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00FF7F)),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$progress%',
          style: TextStyle(
            color: themeProvider.isDarkMode ? Colors.grey : Colors.black54,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}