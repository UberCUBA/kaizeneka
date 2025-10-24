import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../missions/presentation/providers/mission_provider.dart';
import '../../../missions/domain/entities/mission.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/theme/theme_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final missionProvider = Provider.of<MissionProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    if (missionProvider.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    Mission mission = missionProvider.getCurrentDailyMission();

    // Get user initials for avatar
    String getInitials(String? name) {
      if (name == null || name.isEmpty) return 'U';
      final parts = name.split(' ');
      if (parts.length >= 2) {
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      }
      return name[0].toUpperCase();
    }

    Color getBeltColor(String belt) {
      switch (belt) {
        case 'Blanco':
          return Colors.white;
        case 'Amarillo':
          return Colors.yellow;
        case 'Naranja':
          return Colors.orange;
        case 'Verde':
          return Colors.green;
        case 'Azul':
          return Colors.blue;
        case 'Marrón':
          return Colors.brown;
        case 'Negro':
          return Colors.black;
        default:
          return Colors.grey;
      }
    }

    return Scaffold(
      backgroundColor: themeProvider.isDarkMode ? Colors.black : const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: themeProvider.isDarkMode ? Colors.black : Colors.white,
        title: Text('NK(+)', style: TextStyle(color: themeProvider.isDarkMode ? Colors.white : Colors.black87)),
        iconTheme: IconThemeData(color: themeProvider.isDarkMode ? Colors.white : Colors.black54),
      ),
      drawer: Drawer(
        backgroundColor: themeProvider.isDarkMode ? Colors.black : Colors.white,
        child: Padding(
          padding: EdgeInsets.only(top: 28),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
            Container(
              height: 150,
              decoration: const BoxDecoration(
                color: Color(0xFF00FF7F),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Center(
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pushNamed('/profile'),
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.black,
                              child: Text(
                                getInitials(authProvider.userProfile?.name),
                                style: const TextStyle(color: Color(0xFF00FF7F), fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  CircleAvatar(
                                    radius: 12,
                                    backgroundColor: const Color.fromARGB(255, 186, 185, 185),
                                  ),
                                  CircleAvatar(
                                    radius: 9,
                                    backgroundColor: Colors.grey[600],
                                  ),
                                  Icon(
                                    Icons.star,
                                    color: getBeltColor(missionProvider.user.cinturonActual),
                                    size: 14,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      authProvider.userProfile?.name ?? '',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      authProvider.user?.email ?? '',
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    // Align(
                    //   alignment: Alignment.centerRight,
                    //   child: Padding(
                    //     padding: const EdgeInsets.only(top: 8.0),
                    //     child: IconButton(
                    //       icon: const Icon(Icons.brightness_6, color: Colors.black),
                    //       onPressed: () {
                    //         // TODO: Implement theme toggle
                    //         ScaffoldMessenger.of(context).showSnackBar(
                    //           const SnackBar(content: Text('Cambio de tema próximamente')),
                    //         );
                    //       },
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Color(0xFF00FF7F)),
              title: Text('Mi Perfil', style: TextStyle(color: themeProvider.isDarkMode ? Colors.white : Colors.black87)),
              onTap: () {
                Navigator.of(context).pushNamed('/profile');
              },
            ),
            ListTile(
              leading: const Icon(Icons.assignment, color: Color(0xFF00FF7F)),
              title: Text('Inicio', style: TextStyle(color: themeProvider.isDarkMode ? Colors.white : Colors.black87)),
              onTap: () {
                Navigator.of(context).pop();
              },
            ),

            ListTile(
              leading: const Icon(Icons.photo_camera, color: Color(0xFF00FF7F)),
              title: Text('Postureo NK', style: TextStyle(color: themeProvider.isDarkMode ? Colors.white : Colors.black87)),
              onTap: () {
                Navigator.of(context).pushNamed('/postureo');
              },
            ),

            ListTile(
              leading: const Icon(Icons.library_books, color: Color(0xFF00FF7F)),
              title: Text('Biblioteca NK', style: TextStyle(color: themeProvider.isDarkMode ? Colors.white : Colors.black87)),
              onTap: () {
                Navigator.of(context).pushNamed('/biblioteca');
              },
            ),

            ListTile(
              leading: const Icon(Icons.smart_toy, color: Color(0xFF00FF7F)),
              title: Text('IA NK', style: TextStyle(color: themeProvider.isDarkMode ? Colors.white : Colors.black87)),
              onTap: () {
                Navigator.of(context).pushNamed('/ia_nk');
              },
            ),

            ListTile(
              leading: const Icon(Icons.shopping_bag, color: Color(0xFF00FF7F)),
              title: Text('Shop NK', style: TextStyle(color: themeProvider.isDarkMode ? Colors.white : Colors.black87)),
              onTap: () {
                Navigator.of(context).pushNamed('/shop');
              },
            ),

            ListTile(
              leading: const Icon(Icons.map, color: Color(0xFF00FF7F)),
              title: Text('Mapa Kaizeneka', style: TextStyle(color: themeProvider.isDarkMode ? Colors.white : Colors.black87)),
              onTap: () {
                Navigator.of(context).pushNamed('/map');
              },
            ),
            ListTile(
              leading: const Icon(Icons.leaderboard, color: Color(0xFF00FF7F)),
              title: Text('Ranking de Usuarios', style: TextStyle(color: themeProvider.isDarkMode ? Colors.white : Colors.black87)),
              onTap: () {
                Navigator.of(context).pushNamed('/ranking');
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: Color(0xFF00FF7F)),
              title: Text('Ajustes', style: TextStyle(color: themeProvider.isDarkMode ? Colors.white : Colors.black87)),
              onTap: () {
                Navigator.of(context).pushNamed('/settings');
              },
            ),
          ],
        ),
      ),
    ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Bloque superior: Misión del día
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: themeProvider.isDarkMode ? const Color(0xFF1C1C1C) : Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: themeProvider.isDarkMode ? null : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.diamond, color: Color(0xFF00FF7F), size: 40),
                      const SizedBox(width: 10),
                      Text(
                        'Misión del día',
                        style: TextStyle(
                          color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    mission.descripcion,
                    style: TextStyle(
                      color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      await missionProvider.completeCurrentMission();
                      setState(() {}); // Forzar reconstrucción para mostrar la nueva misión
                      // Sincronizar con Supabase
                      final authProvider = Provider.of<AuthProvider>(context, listen: false);
                      if (authProvider.isAuthenticated) {
                        await authProvider.updateUserPoints(missionProvider.user.puntos);
                        await authProvider.updateUserDiasCompletados(missionProvider.user.diasCompletados);
                      }
                      _showFeedback(context, mission);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00FF7F),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    ),
                    child: const Text('COMPLETADO', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Bloque nivel
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: themeProvider.isDarkMode ? const Color(0xFF1C1C1C) : Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: themeProvider.isDarkMode ? null : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.emoji_events, color: Color(0xFF00FF7F), size: 40),
                  const SizedBox(width: 10),
                  Text(
                    'Tu nivel: Cinturón ${missionProvider.user.cinturonActual}',
                    style: TextStyle(
                      color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Palmarómetro
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: themeProvider.isDarkMode ? const Color(0xFF1C1C1C) : Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: themeProvider.isDarkMode ? null : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.thermostat_outlined, color: Color(0xFF00FF7F), size: 30),
                      Text(
                        'Palmarómetro',
                        style: TextStyle(
                          color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: missionProvider.user.puntos / 100.0,
                    backgroundColor: themeProvider.isDarkMode ? Colors.grey : Colors.grey[300],
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00FF7F)),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${missionProvider.user.puntos} puntos',
                    style: TextStyle(color: themeProvider.isDarkMode ? Colors.white : Colors.black87),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // // Ranking Nacional
            // Container(
            //   padding: const EdgeInsets.all(20),
            //   decoration: BoxDecoration(
            //     color: const Color(0xFF1C1C1C),
            //     borderRadius: BorderRadius.circular(10),
            //   ),
            //   child: const Column(
            //     children: [
            //       Text(
            //         'Ranking Nacional',
            //         style: TextStyle(
            //           color: Colors.white,
            //           fontSize: 18,
            //           fontWeight: FontWeight.bold,
            //         ),
            //       ),
            //       SizedBox(height: 10),
            //       Text('🥇 Paola — 867', style: TextStyle(color: Colors.white)),
            //       Text('🥈 Julia — 818', style: TextStyle(color: Colors.white)),
            //       Text('🥉 Tiago — 750', style: TextStyle(color: Colors.white)),
            //     ],
            //   ),
            // ),
            const Spacer(),
            // Botón inferior
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/all-missions');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00FF7F),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('VER MISIONES', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _showFeedback(BuildContext context, Mission mission) {
    if (!mounted) return;
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: themeProvider.isDarkMode ? Colors.black : Colors.white,
        title: Text('¡Misión Completada!', style: TextStyle(color: const Color(0xFF00FF7F))),
        content: Text(
          'Has lucrado ${mission.beneficio}. Sobradísimo 💥',
          style: TextStyle(color: themeProvider.isDarkMode ? Colors.white : Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK', style: TextStyle(color: Color(0xFF00FF7F))),
          ),
        ],
      ),
    );
  }
}