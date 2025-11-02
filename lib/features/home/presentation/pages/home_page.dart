import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../missions/presentation/providers/mission_provider.dart';
import '../../../missions/domain/entities/mission.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/services/home_widget_service.dart';
import '../widgets/active_missions_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Actualizar widget del home screen cuando se carga la página
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        HomeWidgetService.updateWidgetData(context);
      }
    });
  }

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
                                    color: getBeltColor(missionProvider.user?.cinturonActual ?? 'Blanco'),
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
              leading: const Icon(Icons.task, color: Color(0xFF00FF7F)),
              title: Text('Tareas y Misiones', style: TextStyle(color: themeProvider.isDarkMode ? Colors.white : Colors.black87)),
              onTap: () {
                Navigator.of(context).pushNamedAndRemoveUntil('/tasks', (route) => false);
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con saludo personalizado
              Text(
                '¡Hola, ${authProvider.userProfile?.name?.split(' ').first ?? 'Kaizeneka'}! 👋',
                style: TextStyle(
                  color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '¿Qué vamos a lograr hoy?',
                style: TextStyle(
                  color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 32),

              // Estadísticas rápidas - 1 fila de 3 elementos
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      context,
                      'XP Total',
                      '${authProvider.userProfile?.points ?? 0}',
                      Icons.star,
                      const Color(0xFFFFD700),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      'Racha',
                      '${authProvider.userProfile?.streak ?? 0} días',
                      Icons.local_fire_department,
                      const Color(0xFFFF5722),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      'Energía',
                      '${authProvider.userProfile?.energy ?? 100}',
                      Icons.battery_full,
                      const Color(0xFFFFC107),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Sección de acciones rápidas
              Text(
                'Acciones Rápidas',
                style: TextStyle(
                  color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Grid de acciones rápidas - 2 filas de 3 elementos
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: [
                  _buildQuickActionCard(
                    context,
                    'Nuevo Hábito',
                    Icons.track_changes,
                    const Color(0xFF4CAF50),
                    () => Navigator.of(context).pushNamed('/tasks', arguments: 0),
                  ),
                  _buildQuickActionCard(
                    context,
                    'Nueva Tarea',
                    Icons.add_task,
                    const Color(0xFF2196F3),
                    () => Navigator.of(context).pushNamed('/tasks', arguments: 1),
                  ),
                  _buildQuickActionCard(
                    context,
                    'Nueva Misión',
                    Icons.assignment,
                    const Color(0xFF9C27B0),
                    () => Navigator.of(context).pushNamed('/tasks', arguments: 2),
                  ),
                  _buildQuickActionCard(
                    context,
                    'Tienda',
                    Icons.shopping_bag,
                    const Color(0xFFFF9800),
                    () => Navigator.of(context).pushNamed('/shop'),
                  ),
                  _buildQuickActionCard(
                    context,
                    'Biblioteca',
                    Icons.library_books,
                    const Color(0xFF795548),
                    () => Navigator.of(context).pushNamed('/biblioteca'),
                  ),
                  _buildQuickActionCard(
                    context,
                    'Postureo',
                    Icons.photo_camera,
                    const Color(0xFFE91E63),
                    () => Navigator.of(context).pushNamed('/postureo'),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Sección de actividad reciente
              Text(
                'Actividad Reciente',
                style: TextStyle(
                  color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Lista de actividad reciente (placeholder por ahora)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: themeProvider.isDarkMode ? const Color(0xFF1C1C1C) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
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
                        const Icon(Icons.check_circle, color: Color(0xFF00FF7F), size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Completaste una tarea: "Hacer ejercicio"',
                            style: TextStyle(
                              color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Text(
                          '2h',
                          style: TextStyle(
                            color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Color(0xFFFFD700), size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Ganaste 10 XP por completar tu racha diaria',
                            style: TextStyle(
                              color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Text(
                          '5h',
                          style: TextStyle(
                            color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode ? const Color(0xFF1C1C1C) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: themeProvider.isDarkMode ? null : [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: themeProvider.isDarkMode ? const Color(0xFF1C1C1C) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: themeProvider.isDarkMode ? null : [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}