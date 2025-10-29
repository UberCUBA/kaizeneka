import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/theme/theme_provider.dart';

class ProgressTutorialPage extends StatefulWidget {
  const ProgressTutorialPage({super.key});

  @override
  State<ProgressTutorialPage> createState() => _ProgressTutorialPageState();
}

class _ProgressTutorialPageState extends State<ProgressTutorialPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<TutorialStep> _tutorialSteps = [
    TutorialStep(
      title: '¡Bienvenido al Sistema de Progreso! 🎮',
      description: 'Descubre cómo el camino Kaizeneka se convierte en una aventura gamificada. Cada acción cuenta para tu crecimiento.',
      icon: Icons.celebration,
      color: const Color(0xFF00FF7F),
    ),
    TutorialStep(
      title: 'XP y Niveles 📈',
      description: 'Gana Experiencia (XP) completando tareas, hábitos y misiones. Sube de nivel automáticamente y desbloquea nuevas aventuras.',
      icon: Icons.trending_up,
      color: const Color(0xFF2196F3),
      example: 'Tarea simple: +5 XP\nTarea difícil: +20 XP\nMisión completa: +50 XP',
    ),
    TutorialStep(
      title: 'Monedas y Recompensas 💰',
      description: 'Las monedas son tu moneda del juego. Úsalas para comprar mejoras, temas y contenido premium.',
      icon: Icons.monetization_on,
      color: const Color(0xFFFFD700),
      example: 'Completa hábitos diarios\nDesbloquea logros\nVende items en la tienda',
    ),
    TutorialStep(
      title: 'Sistema de Rachas 🔥',
      description: 'Mantén la consistencia con rachas diarias. ¡Cada día consecutivo multiplica tus recompensas!',
      icon: Icons.local_fire_department,
      color: const Color(0xFFFF5722),
      example: 'Día 1: +10 XP\nDía 7: +70 XP + bonificación\nDía 14: +140 XP + logro especial',
    ),
    TutorialStep(
      title: 'Misiones Narrativas 📜',
      description: 'Embárcate en un viaje de 12 arcos narrativos. Cada misión representa un paso en tu transformación Kaizeneka.',
      icon: Icons.book,
      color: const Color(0xFF9C27B0),
      example: 'Arco 1: El Despertar\nArco 2: Entrenamiento\nArco 12: Trascendencia',
    ),
    TutorialStep(
      title: 'Los 3 Mundos JVC 🌍',
      description: 'Mantén el equilibrio entre Salud Extrema, Dinámicas Sociales y Psicología del Éxito.',
      icon: Icons.balance,
      color: const Color(0xFF4CAF50),
      example: 'Salud Extrema 🧘\nDinámicas Sociales 🤝\nPsicología del Éxito 🚀',
    ),
    TutorialStep(
      title: 'Sistema de Energía ⚡',
      description: 'Gestiona tu energía diaria. Algunas acciones consumen energía, otras la restauran.',
      icon: Icons.battery_full,
      color: const Color(0xFFFFC107),
      example: 'Máximo: 100 puntos\nTareas difíciles: -20\nDescanso: +30\nSueño completo: +50',
    ),
    TutorialStep(
      title: 'Logros y Desbloqueos 🏆',
      description: 'Completa desafíos únicos y desbloquea logros permanentes. Cada logro cuenta una historia de tu progreso.',
      icon: Icons.emoji_events,
      color: const Color(0xFFFF9800),
      example: '"Comienzo Épico"\n"Maestro de Rachas"\n"Misionero Legendario"',
    ),
    TutorialStep(
      title: '¡Tu Aventura Comienza! 🚀',
      description: 'Cada día es una oportunidad para crecer. Recuerda: la consistencia vence al talento. ¡Nos vemos en el camino Kaizeneka!',
      icon: Icons.rocket_launch,
      color: const Color(0xFFE91E63),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _tutorialSteps.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeTutorial();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _completeTutorial() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    // Aquí podrías guardar que el usuario completó el tutorial
    // await authProvider.markTutorialCompleted();

    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.isDarkMode ? Colors.black : const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            // Indicador de progreso
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: List.generate(
                  _tutorialSteps.length,
                  (index) => Expanded(
                    child: Container(
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: index <= _currentPage
                            ? const Color(0xFF00FF7F)
                            : (themeProvider.isDarkMode ? Colors.grey[800] : Colors.grey[300]),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Contenido del tutorial
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (page) {
                  setState(() => _currentPage = page);
                },
                itemCount: _tutorialSteps.length,
                itemBuilder: (context, index) {
                  return _buildTutorialStep(_tutorialSteps[index]);
                },
              ),
            ),

            // Botones de navegación
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentPage > 0)
                    TextButton(
                      onPressed: _previousPage,
                      child: Text(
                        'Anterior',
                        style: TextStyle(
                          color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54,
                          fontSize: 16,
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: 80),

                  ElevatedButton(
                    onPressed: _nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _tutorialSteps[_currentPage].color,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Text(
                      _currentPage == _tutorialSteps.length - 1 ? '¡Comenzar!' : 'Siguiente',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTutorialStep(TutorialStep step) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Ícono
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: step.color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              step.icon,
              size: 60,
              color: step.color,
            ),
          ),

          const SizedBox(height: 32),

          // Título
          Text(
            step.title,
            style: TextStyle(
              color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // Descripción
          Text(
            step.description,
            style: TextStyle(
              color: themeProvider.isDarkMode ? Colors.white70 : Colors.black54,
              fontSize: 16,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),

          if (step.example != null) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: themeProvider.isDarkMode ? const Color(0xFF1C1C1C) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: step.color.withOpacity(0.3),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.lightbulb,
                    color: step.color,
                    size: 24,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ejemplo:',
                    style: TextStyle(
                      color: step.color,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    step.example!,
                    style: TextStyle(
                      color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class TutorialStep {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String? example;

  const TutorialStep({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.example,
  });
}