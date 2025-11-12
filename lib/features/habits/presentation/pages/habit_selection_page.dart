import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/theme_provider.dart' as custom_theme;
import 'habit_templates_page.dart';
import '../../../tasks/presentation/widgets/add_habit_form.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/theme_provider.dart' as custom_theme;

class HabitSelectionPage extends StatefulWidget {
  const HabitSelectionPage({super.key});

  @override
  State<HabitSelectionPage> createState() => _HabitSelectionPageState();
}

class _HabitSelectionPageState extends State<HabitSelectionPage> {
  final List<HabitCategory> _categories = [
    HabitCategory(
      name: 'Mantente Activo',
      description: 'Hábitos para mantener tu cuerpo en movimiento',
      icon: Icons.directions_run,
      color: const Color(0xFF4CAF50),
      habits: [
        HabitTemplate(name: 'Ejercicios', description: 'Rutina de ejercicios físicos'),
        HabitTemplate(name: 'Senderismo', description: 'Caminatas en la naturaleza'),
        HabitTemplate(name: 'Natación', description: 'Nado recreativo o deportivo'),
        HabitTemplate(name: 'Yoga', description: 'Práctica de yoga y meditación'),
        HabitTemplate(name: 'Ciclismo', description: 'Paseos en bicicleta'),
        HabitTemplate(name: 'Danza', description: 'Clases de baile o danza'),
      ],
    ),
    HabitCategory(
      name: 'Ponte en Forma',
      description: 'Hábitos para mejorar tu condición física',
      icon: Icons.fitness_center,
      color: const Color(0xFFFF5722),
      habits: [
        HabitTemplate(name: 'Flexiones', description: 'Ejercicios de fuerza'),
        HabitTemplate(name: 'Abdominales', description: 'Ejercicios para el core'),
        HabitTemplate(name: 'Estiramientos', description: 'Rutina de estiramiento'),
        HabitTemplate(name: 'Pesas', description: 'Entrenamiento con pesas'),
        HabitTemplate(name: 'Saltar la cuerda', description: 'Ejercicio cardiovascular'),
        HabitTemplate(name: 'Pilates', description: 'Clases de pilates'),
      ],
    ),
    HabitCategory(
      name: 'Salud y Bienestar',
      description: 'Hábitos para cuidar tu salud mental y física',
      icon: Icons.health_and_safety,
      color: const Color(0xFF2196F3),
      habits: [
        HabitTemplate(name: 'Meditación', description: 'Práctica diaria de meditación'),
        HabitTemplate(name: 'Beber agua', description: 'Mantener hidratación'),
        HabitTemplate(name: 'Dormir 8 horas', description: 'Descanso adecuado'),
        HabitTemplate(name: 'Comer saludable', description: 'Alimentación balanceada'),
        HabitTemplate(name: 'Respiración profunda', description: 'Ejercicios de respiración'),
        HabitTemplate(name: 'Diario de gratitud', description: 'Escribir cosas positivas'),
      ],
    ),
    HabitCategory(
      name: 'Productividad',
      description: 'Hábitos para ser más productivo y organizado',
      icon: Icons.work,
      color: const Color(0xFF9C27B0),
      habits: [
        HabitTemplate(name: 'Levantarse temprano', description: 'Rutina matutina'),
        HabitTemplate(name: 'Planificar el día', description: 'Organización diaria'),
        HabitTemplate(name: 'Leer 30 minutos', description: 'Lectura diaria'),
        HabitTemplate(name: 'Aprender algo nuevo', description: 'Desarrollo personal'),
        HabitTemplate(name: 'Hacer listas', description: 'Organización de tareas'),
        HabitTemplate(name: 'Revisar emails', description: 'Gestión del correo'),
      ],
    ),
    HabitCategory(
      name: 'Relaciones Sociales',
      description: 'Hábitos para mejorar tus conexiones sociales',
      icon: Icons.people,
      color: const Color(0xFFFF9800),
      habits: [
        HabitTemplate(name: 'Llamar a un amigo', description: 'Mantener contacto'),
        HabitTemplate(name: 'Salir con amigos', description: 'Actividades sociales'),
        HabitTemplate(name: 'Ayudar a otros', description: 'Actos de bondad'),
        HabitTemplate(name: 'Unirme a un club', description: 'Grupos de interés'),
        HabitTemplate(name: 'Networking', description: 'Conexiones profesionales'),
        HabitTemplate(name: 'Familia primero', description: 'Tiempo con la familia'),
      ],
    ),
    HabitCategory(
      name: 'Hobbies y Creatividad',
      description: 'Hábitos para desarrollar tus pasiones creativas',
      icon: Icons.palette,
      color: const Color(0xFFE91E63),
      habits: [
        HabitTemplate(name: 'Dibujar', description: 'Práctica artística'),
        HabitTemplate(name: 'Tocar instrumento', description: 'Música y práctica'),
        HabitTemplate(name: 'Escribir', description: 'Redacción creativa'),
        HabitTemplate(name: 'Fotografía', description: 'Capturar momentos'),
        HabitTemplate(name: 'Jardinería', description: 'Cuidado de plantas'),
        HabitTemplate(name: 'Cocinar', description: 'Experimentar en la cocina'),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<custom_theme.ThemeProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.isDarkMode ? Colors.black : const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: themeProvider.isDarkMode ? Colors.black : const Color(0xFFF8F9FA),
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(
            Icons.arrow_back,
            color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        title: Text(
          'Crear Nuevo Hábito',
          style: TextStyle(
            color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '¿Qué  hábito quieres crear?',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Elige o crea...',
                style: TextStyle(
                  fontSize: 16,
                  color: themeProvider.isDarkMode ? Colors.grey : Colors.black54,
                ),
              ),
              const SizedBox(height: 32),

              // Option 1: Create Custom Habit
              _buildOptionCard(
                context,
                title: 'Crear Hábito Personalizado',
                description: 'Diseña tu propio hábito desde cero',
                icon: Icons.create,
                color: const Color(0xFF00FF7F),
                onTap: () => _navigateToCustomHabit(),
              ),

              const SizedBox(height: 24),

              // Option 2: Choose from Templates
              Text(
                'Elige de categorías predefinidas:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 16),

              // Categories List
              Expanded(
                child: ListView.builder(
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    return _buildCategoryCard(context, category);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final themeProvider = Provider.of<custom_theme.ThemeProvider>(context);

    return Card(
      color: themeProvider.isDarkMode ? const Color(0xFF1C1C1C) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: color,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: themeProvider.isDarkMode ? Colors.grey : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: themeProvider.isDarkMode ? Colors.grey : Colors.black38,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, HabitCategory category) {
    final themeProvider = Provider.of<custom_theme.ThemeProvider>(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: themeProvider.isDarkMode ? const Color(0xFF1C1C1C) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _navigateToHabitTemplates(category),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: category.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  category.icon,
                  size: 24,
                  color: category.color,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      category.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: themeProvider.isDarkMode ? Colors.grey : Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${category.habits.length} hábitos disponibles',
                      style: TextStyle(
                        fontSize: 12,
                        color: category.color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: themeProvider.isDarkMode ? Colors.grey : Colors.black38,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToCustomHabit() {
    // Abrir el modal de AddHabitForm directamente
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddHabitForm(),
    );
  }

  void _navigateToHabitTemplates(HabitCategory category) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => HabitTemplatesPage(category: category),
      ),
    );
  }
}

class HabitCategory {
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final List<HabitTemplate> habits;

  const HabitCategory({
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.habits,
  });
}

class HabitTemplate {
  final String name;
  final String description;

  const HabitTemplate({
    required this.name,
    required this.description,
  });
}