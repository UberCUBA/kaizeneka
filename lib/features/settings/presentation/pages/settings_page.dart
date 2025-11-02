import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/theme/theme_provider.dart' as custom_theme;
import '../../../missions/presentation/providers/mission_provider.dart';
import '../../../tasks/presentation/providers/task_provider.dart';
import '../../../habits/presentation/providers/habit_provider.dart';
import 'donation_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _appVersion = '1.0.0';

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _appVersion = packageInfo.version;
      });
    } catch (e) {
      // Mantener versión por defecto si hay error
    }
  }

  Future<void> _showLogoutDialog() async {
    final themeProvider = Provider.of<custom_theme.ThemeProvider>(context, listen: false);
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: themeProvider.isDarkMode ? const Color(0xFF1C1C1C) : Colors.white,
        title: Text(
          'Cerrar Sesión',
          style: TextStyle(color: themeProvider.isDarkMode ? Colors.white : Colors.black87),
        ),
        content: Text(
          '¿Estás seguro de que quieres cerrar sesión?',
          style: TextStyle(color: themeProvider.isDarkMode ? Colors.white : Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar', style: TextStyle(color: Color(0xFF00FF7F))),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );

    if (result == true) {
      await _logout();
    }
  }

  Future<void> _logout() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.signOut();

      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cerrar sesión: $e')),
        );
      }
    }
  }

  Future<void> _showResetProgressDialog() async {
    final themeProvider = Provider.of<custom_theme.ThemeProvider>(context, listen: false);
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: themeProvider.isDarkMode ? const Color(0xFF1C1C1C) : Colors.white,
        title: Text(
          '⚠️ Resetear Progreso',
          style: TextStyle(color: themeProvider.isDarkMode ? Colors.white : Colors.black87),
        ),
        content: Text(
          '¿Estás seguro de que quieres resetear TODO tu progreso?\n\nEsto eliminará:\n• Todos tus puntos\n• Todas tus misiones\n• Todas tus tareas\n• Todos tus hábitos\n\nEsta acción NO se puede deshacer.',
          style: TextStyle(color: themeProvider.isDarkMode ? Colors.white : Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar', style: TextStyle(color: Color(0xFF00FF7F))),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('RESETEAR TODO'),
          ),
        ],
      ),
    );

    if (result == true) {
      await _resetAllProgress();
    }
  }

  Future<void> _resetAllProgress() async {
    try {
      // Resetear puntos y progreso de misiones
      final missionProvider = Provider.of<MissionProvider>(context, listen: false);
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      final habitProvider = Provider.of<HabitProvider>(context, listen: false);

      // Limpiar SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // Resetear providers
      missionProvider.resetProgress();
      taskProvider.resetAll();
      habitProvider.resetAll();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Progreso reseteado completamente'),
            backgroundColor: Colors.green,
          ),
        );

        // Recargar la página de settings para reflejar cambios
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al resetear progreso: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<custom_theme.ThemeProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.isDarkMode ? Colors.black : const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: themeProvider.isDarkMode ? Colors.black : Colors.white,
        title: Text('Configuración', style: TextStyle(color: themeProvider.isDarkMode ? Colors.white : Colors.black87)),
        iconTheme: IconThemeData(color: themeProvider.isDarkMode ? Colors.white : Colors.black54),
      ),
      body: ListView(
        children: [
          // Sección de Cuenta
          _buildSectionHeader('Cuenta'),
          ListTile(
            leading: const Icon(Icons.person, color: Color(0xFF00FF7F)),
            title: Text('Mi Perfil', style: TextStyle(color: themeProvider.isDarkMode ? Colors.white : Colors.black87)),
            subtitle: Text(
              authProvider.userProfile?.name ?? 'Usuario',
              style: TextStyle(color: themeProvider.isDarkMode ? Colors.grey : Colors.black54),
            ),
            trailing: Icon(Icons.arrow_forward_ios, color: themeProvider.isDarkMode ? Colors.grey : Colors.black38, size: 16),
            onTap: () {
              Navigator.of(context).pushNamed('/profile');
            },
          ),
          Divider(color: themeProvider.isDarkMode ? Colors.grey : Colors.black12),

          // Sección de Preferencias
          _buildSectionHeader('Preferencias'),
          ListTile(
            leading: const Icon(Icons.notifications, color: Color(0xFF00FF7F)),
            title: Text('Notificaciones', style: TextStyle(color: themeProvider.isDarkMode ? Colors.white : Colors.black87)),
            subtitle: Text('Gestionar notificaciones diarias', style: TextStyle(color: themeProvider.isDarkMode ? Colors.grey : Colors.black54)),
            trailing: Icon(Icons.arrow_forward_ios, color: themeProvider.isDarkMode ? Colors.grey : Colors.black38, size: 16),
            onTap: () {
              Navigator.of(context).pushNamed('/notifications');
            },
          ),
          Consumer<custom_theme.ThemeProvider>(
            builder: (context, themeProvider, child) {
              String getThemeSubtitle() {
                switch (themeProvider!.themeMode) {
                  case custom_theme.ThemeMode.light:
                    return 'Modo claro';
                  case custom_theme.ThemeMode.dark:
                    return 'Modo oscuro';
                  case custom_theme.ThemeMode.system:
                    return 'Tema del sistema';
                  default:
                    return 'Modo oscuro';
                }
              }

              void _showThemeMenu() {
                final RenderBox button = context.findRenderObject() as RenderBox;
                final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
                final RelativeRect position = RelativeRect.fromRect(
                  Rect.fromPoints(
                    button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
                    button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
                  ),
                  Offset.zero & overlay.size,
                );

                showMenu<custom_theme.ThemeMode>(
                  context: context,
                  position: position,
                  items: <PopupMenuEntry<custom_theme.ThemeMode>>[
                    const PopupMenuItem<custom_theme.ThemeMode>(
                      value: custom_theme.ThemeMode.light,
                      child: Text('Tema claro'),
                    ),
                    const PopupMenuItem<custom_theme.ThemeMode>(
                      value: custom_theme.ThemeMode.dark,
                      child: Text('Tema oscuro'),
                    ),
                    const PopupMenuItem<custom_theme.ThemeMode>(
                      value: custom_theme.ThemeMode.system,
                      child: Text('Tema del sistema'),
                    ),
                  ],
                ).then((custom_theme.ThemeMode? mode) {
                  if (mode != null) {
                    themeProvider!.setThemeMode(mode);
                  }
                });
              }

              return ListTile(
                leading: const Icon(Icons.palette, color: Color(0xFF00FF7F)),
                title: Text('Tema', style: TextStyle(color: themeProvider!.isDarkMode ? Colors.white : Colors.black87)),
                subtitle: Text(
                  getThemeSubtitle(),
                  style: TextStyle(color: themeProvider!.isDarkMode ? Colors.grey : Colors.black54),
                ),
                trailing: Icon(
                  Icons.arrow_drop_down,
                  color: themeProvider!.isDarkMode ? Colors.grey : Colors.black38,
                ),
                onTap: _showThemeMenu,
              );
            },
          ),
          const Divider(color: Colors.grey),

          // Sección de Ayuda
          _buildSectionHeader('Ayuda'),
          ListTile(
            leading: const Icon(Icons.school, color: Color(0xFF00FF7F)),
            title: Text('Tutorial de Progreso', style: TextStyle(color: themeProvider.isDarkMode ? Colors.white : Colors.black87)),
            subtitle: Text('Aprende cómo funciona el sistema de cinturones', style: TextStyle(color: themeProvider.isDarkMode ? Colors.grey : Colors.black54)),
            trailing: Icon(Icons.arrow_forward_ios, color: themeProvider.isDarkMode ? Colors.grey : Colors.black38, size: 16),
            onTap: () {
              Navigator.of(context).pushNamed('/tutorial');
            },
          ),
          ListTile(
            leading: const Icon(Icons.help, color: Color(0xFF00FF7F)),
            title: Text('Centro de Ayuda', style: TextStyle(color: themeProvider.isDarkMode ? Colors.white : Colors.black87)),
            subtitle: Text('Preguntas frecuentes', style: TextStyle(color: themeProvider.isDarkMode ? Colors.grey : Colors.black54)),
            trailing: Icon(Icons.arrow_forward_ios, color: themeProvider.isDarkMode ? Colors.grey : Colors.black38, size: 16),
            onTap: () {
              // TODO: Implementar centro de ayuda
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Función próximamente')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.feedback, color: Color(0xFF00FF7F)),
            title: Text('Enviar Comentarios', style: TextStyle(color: themeProvider.isDarkMode ? Colors.white : Colors.black87)),
            subtitle: Text('Ayúdanos a mejorar', style: TextStyle(color: themeProvider.isDarkMode ? Colors.grey : Colors.black54)),
            trailing: Icon(Icons.arrow_forward_ios, color: themeProvider.isDarkMode ? Colors.grey : Colors.black38, size: 16),
            onTap: () {
              // TODO: Implementar envío de feedback
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Función próximamente')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.favorite, color: Colors.red),
            title: Text('Donar a Desarrolladores', style: TextStyle(color: themeProvider.isDarkMode ? Colors.white : Colors.black87)),
            subtitle: Text('Apoya el desarrollo de NK+', style: TextStyle(color: themeProvider.isDarkMode ? Colors.grey : Colors.black54)),
            trailing: Icon(Icons.arrow_forward_ios, color: themeProvider.isDarkMode ? Colors.grey : Colors.black38, size: 16),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const DonationPage(),
                ),
              );
            },
          ),
          const Divider(color: Colors.grey),

          // Sección Legal
          _buildSectionHeader('Legal'),
          ListTile(
            leading: const Icon(Icons.privacy_tip, color: Color(0xFF00FF7F)),
            title: Text('Política de Privacidad', style: TextStyle(color: themeProvider.isDarkMode ? Colors.white : Colors.black87)),
            trailing: Icon(Icons.arrow_forward_ios, color: themeProvider.isDarkMode ? Colors.grey : Colors.black38, size: 16),
            onTap: () {
              // TODO: Implementar política de privacidad
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Función próximamente')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.description, color: Color(0xFF00FF7F)),
            title: Text('Términos de Servicio', style: TextStyle(color: themeProvider.isDarkMode ? Colors.white : Colors.black87)),
            trailing: Icon(Icons.arrow_forward_ios, color: themeProvider.isDarkMode ? Colors.grey : Colors.black38, size: 16),
            onTap: () {
              // TODO: Implementar términos de servicio
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Función próximamente')),
              );
            },
          ),
          const Divider(color: Colors.grey),

          // Resetear Progreso
          ListTile(
            leading: const Icon(Icons.refresh, color: Colors.orange),
            title: const Text('Resetear Progreso', style: TextStyle(color: Colors.orange)),
            subtitle: const Text('Eliminar todos los datos (irreversible)', style: TextStyle(fontSize: 12)),
            onTap: _showResetProgressDialog,
          ),

          const Divider(color: Colors.grey),

          // Cerrar Sesión (último)
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Cerrar Sesión', style: TextStyle(color: Colors.red)),
            onTap: _showLogoutDialog,
          ),

          // Versión de la app (último, centrado)
          const SizedBox(height: 20),
          Center(
            child: Text(
              'Versión $_appVersion',
              style: TextStyle(
                color: themeProvider.isDarkMode ? Colors.grey : Colors.black54,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          color: const Color(0xFF00FF7F),
          fontSize: 14,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}