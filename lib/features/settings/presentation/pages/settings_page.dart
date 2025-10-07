import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

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
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1C),
        title: const Text(
          'Cerrar Sesión',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          '¿Estás seguro de que quieres cerrar sesión?',
          style: TextStyle(color: Colors.white),
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

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Configuración', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        children: [
          // Sección de Cuenta
          _buildSectionHeader('Cuenta'),
          ListTile(
            leading: const Icon(Icons.person, color: Color(0xFF00FF7F)),
            title: const Text('Mi Perfil', style: TextStyle(color: Colors.white)),
            subtitle: Text(
              authProvider.userProfile?.name ?? 'Usuario',
              style: const TextStyle(color: Colors.grey),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
            onTap: () {
              Navigator.of(context).pushNamed('/profile');
            },
          ),
          const Divider(color: Colors.grey),

          // Sección de Preferencias
          _buildSectionHeader('Preferencias'),
          ListTile(
            leading: const Icon(Icons.notifications, color: Color(0xFF00FF7F)),
            title: const Text('Notificaciones', style: TextStyle(color: Colors.white)),
            subtitle: const Text('Gestionar notificaciones diarias', style: TextStyle(color: Colors.grey)),
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
            onTap: () {
              // TODO: Implementar pantalla de notificaciones
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Función próximamente')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.palette, color: Color(0xFF00FF7F)),
            title: const Text('Tema', style: TextStyle(color: Colors.white)),
            subtitle: const Text('Cambiar apariencia de la app', style: TextStyle(color: Colors.grey)),
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
            onTap: () {
              // TODO: Implementar selector de tema
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Función próximamente')),
              );
            },
          ),
          const Divider(color: Colors.grey),

          // Sección de Ayuda
          _buildSectionHeader('Ayuda'),
          ListTile(
            leading: const Icon(Icons.help, color: Color(0xFF00FF7F)),
            title: const Text('Centro de Ayuda', style: TextStyle(color: Colors.white)),
            subtitle: const Text('Preguntas frecuentes', style: TextStyle(color: Colors.grey)),
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
            onTap: () {
              // TODO: Implementar centro de ayuda
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Función próximamente')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.feedback, color: Color(0xFF00FF7F)),
            title: const Text('Enviar Comentarios', style: TextStyle(color: Colors.white)),
            subtitle: const Text('Ayúdanos a mejorar', style: TextStyle(color: Colors.grey)),
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
            onTap: () {
              // TODO: Implementar envío de feedback
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Función próximamente')),
              );
            },
          ),
          const Divider(color: Colors.grey),

          // Sección Legal
          _buildSectionHeader('Legal'),
          ListTile(
            leading: const Icon(Icons.privacy_tip, color: Color(0xFF00FF7F)),
            title: const Text('Política de Privacidad', style: TextStyle(color: Colors.white)),
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
            onTap: () {
              // TODO: Implementar política de privacidad
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Función próximamente')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.description, color: Color(0xFF00FF7F)),
            title: const Text('Términos de Servicio', style: TextStyle(color: Colors.white)),
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
            onTap: () {
              // TODO: Implementar términos de servicio
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Función próximamente')),
              );
            },
          ),
          const Divider(color: Colors.grey),

          // Cerrar Sesión (penúltimo)
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
              style: const TextStyle(
                color: Colors.grey,
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
        style: const TextStyle(
          color: Color(0xFF00FF7F),
          fontSize: 14,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}