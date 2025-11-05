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
import '../widgets/draggable_fab.dart';
import '../../../../models/task_models.dart';

class MainTasksPage extends StatefulWidget {
  const MainTasksPage({super.key});

  @override
  State<MainTasksPage> createState() => _MainTasksPageState();
}

class _MainTasksPageState extends State<MainTasksPage> {
  int _selectedIndex = 0;
  late Size _screenSize;
  late Offset _fabPosition;
  late PageController _pageController;

  // Estados para búsqueda y filtros
  bool _isSearching = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // Estados de filtros
  Difficulty? _selectedDifficulty;
  bool? _showCompleted;
  bool? _showCompletedToday;
  bool? _showSystemMissions;

  final List<Widget> _pages = [
    const HabitsPage(), // Primero hábitos
    const TasksPage(),  // Segundo tareas
    const MissionsPage(), // Tercero misiones
  ];

  final List<String> _titles = [
    'Hábitos', // Primero hábitos
    'Tareas',  // Segundo tareas
    'Misiones', // Tercero misiones
  ];

  final List<String> _subtitles = [
    'Construye hábitos poderosos', // Primero hábitos
    'Gestiona tus objetivos diarios', // Segundo tareas
    'Completa desafíos épicos', // Tercero misiones
  ];

  @override
  void initState() {
    super.initState();
    // Inicializar el PageController inmediatamente
    _pageController = PageController(initialPage: _selectedIndex);

    // Verificar si hay argumentos para seleccionar un tab específico
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is int && args >= 0 && args < _pages.length) {
        setState(() {
          _selectedIndex = args;
        });
        // Solo animar si es diferente del inicial
        if (args != 0) {
          _pageController.animateToPage(
            args,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      }
    });
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _screenSize = MediaQuery.of(context).size;
    // Posición inicial: esquina inferior derecha, pero más arriba de la navegación
    _fabPosition = Offset(_screenSize.width - 80, _screenSize.height - 180);
  }


  void _showAddForm() {
    final themeProvider = Provider.of<custom_theme.ThemeProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        switch (_selectedIndex) {
          case 0: // Hábitos
            return const AddHabitForm();
          case 1: // Tareas
            return const AddTaskForm();
          case 2: // Misiones
            return const AddMissionForm();
          default:
            return const AddHabitForm();
        }
      },
    );
  }

  void _showSearchDialog(BuildContext context) {
    final TextEditingController searchController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Buscar'),
          content: TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'Buscar ${_titles[_selectedIndex].toLowerCase()}...',
              prefixIcon: const Icon(Icons.search),
            ),
            onChanged: (value) {
              // Aquí implementar lógica de búsqueda
              // Por ahora solo mostramos el valor
              print('Buscando: $value en ${_titles[_selectedIndex]}');
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                // Implementar búsqueda
                Navigator.of(context).pop();
              },
              child: const Text('Buscar'),
            ),
          ],
        );
      },
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.6,
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.grey, width: 0.5),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Filtros',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ),

                  // Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Dificultad - para todas las pestañas
                          const Text('Dificultad:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _buildFilterChip(
                                'Fácil',
                                _selectedDifficulty == Difficulty.easy,
                                () {
                                  setModalState(() {
                                    _selectedDifficulty = _selectedDifficulty == Difficulty.easy ? null : Difficulty.easy;
                                  });
                                  setState(() {});
                                },
                              ),
                              _buildFilterChip(
                                'Medio',
                                _selectedDifficulty == Difficulty.medium,
                                () {
                                  setModalState(() {
                                    _selectedDifficulty = _selectedDifficulty == Difficulty.medium ? null : Difficulty.medium;
                                  });
                                  setState(() {});
                                },
                              ),
                              _buildFilterChip(
                                'Difícil',
                                _selectedDifficulty == Difficulty.hard,
                                () {
                                  setModalState(() {
                                    _selectedDifficulty = _selectedDifficulty == Difficulty.hard ? null : Difficulty.hard;
                                  });
                                  setState(() {});
                                },
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Estado - para todas las pestañas
                          const Text('Estado:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _buildFilterChip(
                                'Pendientes',
                                _showCompleted == false,
                                () {
                                  setModalState(() {
                                    _showCompleted = _showCompleted == false ? null : false;
                                  });
                                  setState(() {});
                                },
                              ),
                              _buildFilterChip(
                                'Completadas',
                                _showCompleted == true,
                                () {
                                  setModalState(() {
                                    _showCompleted = _showCompleted == true ? null : true;
                                  });
                                  setState(() {});
                                },
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          if (_selectedIndex == 0) ...[ // Solo para hábitos
                            const Text('Completado hoy:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _buildFilterChip(
                                  'Sí',
                                  _showCompletedToday == true,
                                  () {
                                    setModalState(() {
                                      _showCompletedToday = _showCompletedToday == true ? null : true;
                                    });
                                    setState(() {});
                                  },
                                ),
                                _buildFilterChip(
                                  'No',
                                  _showCompletedToday == false,
                                  () {
                                    setModalState(() {
                                      _showCompletedToday = _showCompletedToday == false ? null : false;
                                    });
                                    setState(() {});
                                  },
                                ),
                              ],
                            ),
                          ] else if (_selectedIndex == 2) ...[ // Solo para misiones
                            const Text('Tipo:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _buildFilterChip(
                                  'Sistema NK',
                                  _showSystemMissions == true,
                                  () {
                                    setModalState(() {
                                      _showSystemMissions = _showSystemMissions == true ? null : true;
                                    });
                                    setState(() {});
                                  },
                                ),
                                _buildFilterChip(
                                  'Personales',
                                  _showSystemMissions == false,
                                  () {
                                    setModalState(() {
                                      _showSystemMissions = _showSystemMissions == false ? null : false;
                                    });
                                    setState(() {});
                                  },
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  // Footer con botón de limpiar
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Colors.grey, width: 0.5),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () {
                              setModalState(() {
                                _selectedDifficulty = null;
                                _showCompleted = null;
                                _showCompletedToday = null;
                                _showSystemMissions = null;
                              });
                              setState(() {});
                            },
                            child: const Text('Limpiar filtros'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00FF7F),
                            foregroundColor: Colors.black,
                          ),
                          child: const Text('Aplicar'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      backgroundColor: Colors.grey.withOpacity(0.1),
      selectedColor: const Color(0xFF00FF7F).withOpacity(0.2),
      checkmarkColor: const Color(0xFF00FF7F),
      side: BorderSide(
        color: isSelected ? const Color(0xFF00FF7F) : Colors.grey.withOpacity(0.3),
        width: isSelected ? 2 : 1,
      ),
    );
  }

  bool _hasActiveFilters() {
    return _selectedDifficulty != null || _showCompleted != null || _showCompletedToday != null || _showSystemMissions != null;
  }

  List<Widget> _buildFilteredPages() {
    return [
      // Hábitos con filtros aplicados
      HabitsPage(
        key: ValueKey('habits_${_searchQuery}_${_selectedDifficulty}_${_showCompleted}_${_showCompletedToday}'),
        searchQuery: _searchQuery,
        selectedDifficulty: _selectedDifficulty,
        showCompleted: _showCompleted,
        showCompletedToday: _showCompletedToday,
      ),
      // Tareas con filtros aplicados
      TasksPage(
        key: ValueKey('tasks_${_searchQuery}_${_selectedDifficulty}_${_showCompleted}'),
        searchQuery: _searchQuery,
        selectedDifficulty: _selectedDifficulty,
        showCompleted: _showCompleted,
      ),
      // Misiones con filtros aplicados
      MissionsPage(
        key: ValueKey('missions_${_searchQuery}_${_selectedDifficulty}_${_showCompleted}_${_showSystemMissions}'),
        searchQuery: _searchQuery,
        selectedDifficulty: _selectedDifficulty,
        showCompleted: _showCompleted,
        showSystemMissions: _showSystemMissions,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<custom_theme.ThemeProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final missionProvider = Provider.of<MissionProvider>(context);

    // Actualizar tamaño de pantalla si cambia
    _screenSize = MediaQuery.of(context).size;

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
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
          ),
          onPressed: () {
            Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
          },
        ),
        title: Text(
          _titles[_selectedIndex],
          style: TextStyle(
            color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        actions: [
          // Campo de búsqueda expandible
          if (_isSearching)
            Expanded(
              child: Container(
                margin: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.2), // 20% desplazamiento a la derecha
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Buscar ${_titles[_selectedIndex].toLowerCase()}...',
                    hintStyle: TextStyle(
                      color: themeProvider.isDarkMode ? Colors.grey : Colors.black54,
                    ),
                    border: InputBorder.none,
                    suffixIcon: IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                      ),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                          _searchQuery = '';
                          _isSearching = false;
                        });
                      },
                    ),
                  ),
                  style: TextStyle(
                    color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),
            )
          else ...[
            // Botón de búsqueda
            IconButton(
              icon: Icon(
                Icons.search,
                color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
              ),
              onPressed: () {
                setState(() {
                  _isSearching = true;
                });
              },
            ),
            // Botón de filtro con badge si hay filtros activos
            Stack(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.filter_list,
                    color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                  ),
                  onPressed: () => _showFilterBottomSheet(context),
                ),
                if (_hasActiveFilters())
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF00FF7F),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            // Botón de próximas misiones
            IconButton(
              icon: Icon(
                Icons.lock_open,
                color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
              ),
              onPressed: () {
                Navigator.of(context).pushNamed('/all-missions');
              },
            ),
          ],
        ],
      ),
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            children: _buildFilteredPages(),
          ),
          Positioned(
            bottom: 90,
            right: 20,
            child: FloatingActionButton(
              onPressed: _showAddForm,
              backgroundColor: const Color(0xFF00FF7F),
              child: const Icon(Icons.add, color: Colors.black),
              elevation: 4,
            ),
          ),
        ],
      ),
      bottomNavigationBar: CurvedNavigationBar(
        index: _selectedIndex,
        height: 75,
        items: [
          CurvedNavigationBarItem(
            child: Icon(
              Icons.track_changes,
              color: _selectedIndex == 0 ? Colors.white : Colors.grey,
            ),
            label: 'Hábitos',
            labelStyle: TextStyle(
              color: _selectedIndex == 0 ? Colors.white : Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          CurvedNavigationBarItem(
            child: Icon(
              Icons.checklist,
              color: _selectedIndex == 1 ? Colors.white : Colors.grey,
            ),
            label: 'Tareas',
            labelStyle: TextStyle(
              color: _selectedIndex == 1 ? Colors.white : Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          CurvedNavigationBarItem(
            child: Icon(
              Icons.flag,
              color: _selectedIndex == 2 ? Colors.white : Colors.grey,
            ),
            label: 'Misiones',
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
          // Sincronizar PageView con navegación por tabs
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        letIndexChange: (index) => true,
      ),
    );
  }
}