import 'package:flutter/material.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/theme_provider.dart' as custom_theme;
import '../providers/task_provider.dart';
import '../../../missions/presentation/providers/mission_provider.dart';
import '../../../habits/presentation/providers/habit_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import 'tasks_page.dart';
import '../../../missions/presentation/pages/missions_page.dart';
import '../../../habits/presentation/pages/habits_page.dart';
import '../widgets/add_task_form.dart';
import '../widgets/add_mission_form.dart';
import '../widgets/add_habit_form.dart';

class MainTasksPage extends StatefulWidget {
  const MainTasksPage({super.key});

  @override
  State<MainTasksPage> createState() => _MainTasksPageState();
}

class _MainTasksPageState extends State<MainTasksPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const TasksPage(),
    const MissionsPage(),
    const HabitsPage(),
  ];

  final List<String> _titles = [
    'Tareas',
    'Misiones',
    'Hábitos',
  ];

  final List<String> _subtitles = [
    'Gestiona tus objetivos diarios',
    'Completa desafíos épicos',
    'Construye hábitos poderosos',
  ];

  void _showAddForm() {
    final themeProvider = Provider.of<custom_theme.ThemeProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        switch (_selectedIndex) {
          case 0:
            return const AddTaskForm();
          case 1:
            return const AddMissionForm();
          case 2:
            return const AddHabitForm();
          default:
            return const AddTaskForm();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<custom_theme.ThemeProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final missionProvider = Provider.of<MissionProvider>(context);

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
        title: Text(
          _titles[_selectedIndex],
          style: TextStyle(
            color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(
              Icons.menu,
              color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
            ),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
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
            // ListTile(
            //   leading: const Icon(Icons.assignment, color: Color(0xFF00FF7F)),
            //   title: Text('Inicio', style: TextStyle(color: themeProvider.isDarkMode ? Colors.white : Colors.black87)),
            //   onTap: () {
            //     Navigator.of(context).pushNamed('/home');
            //   },
            // ),

            ListTile(
              leading: const Icon(Icons.task, color: Color(0xFF00FF7F)),
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
      body: _pages[_selectedIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddForm,
        backgroundColor: const Color(0xFF00FF7F),
        child: const Icon(Icons.add, color: Colors.black),
        elevation: 4,
      ),
      bottomNavigationBar: CurvedNavigationBar(
        index: _selectedIndex,
        height: 75,
        items: [
          CurvedNavigationBarItem(
            child: Icon(
              Icons.checklist,
              color: _selectedIndex == 0 ? Colors.white : Colors.grey,
            ),
            label: 'Tareas',
            labelStyle: TextStyle(
              color: _selectedIndex == 0 ? Colors.white : Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          CurvedNavigationBarItem(
            child: Icon(
              Icons.flag,
              color: _selectedIndex == 1 ? Colors.white : Colors.grey,
            ),
            label: 'Misiones',
            labelStyle: TextStyle(
              color: _selectedIndex == 1 ? Colors.white : Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          CurvedNavigationBarItem(
            child: Icon(
              Icons.track_changes,
              color: _selectedIndex == 2 ? Colors.white : Colors.grey,
            ),
            label: 'Hábitos',
            labelStyle: TextStyle(
              color: _selectedIndex == 2 ? Colors.white : Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
        color: themeProvider.isDarkMode ? const Color(0xFF1C1C1C) : Colors.white,
        buttonBackgroundColor: const Color(0xFF00FF7F),
        backgroundColor: themeProvider.isDarkMode ? Colors.black : const Color(0xFFF8F9FA),
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 300),
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        letIndexChange: (index) => true,
      ),
    );
  }
}