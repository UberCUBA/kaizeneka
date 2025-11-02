import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/local_notification_service.dart';
import '../../../../core/theme/theme_provider.dart' as custom_theme;

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool _notificationsEnabled = true;
  bool _dailyRemindersEnabled = true;
  bool _achievementNotificationsEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
  }

  Future<void> _loadNotificationSettings() async {
    // Aquí cargaríamos las preferencias guardadas
    // Por ahora usamos valores por defecto
  }

  Future<void> _saveNotificationSettings() async {
    // Aquí guardaríamos las preferencias
  }

  Future<void> _testNotification() async {
    await LocalNotificationService().testNotification();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Notificación de prueba enviada'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _scheduleNotifications() async {
    try {
      await LocalNotificationService().scheduleDailyMissionNotification();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Notificaciones programadas para cada 15 minutos'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al programar notificaciones: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _cancelAllNotifications() async {
    try {
      await LocalNotificationService().cancelAllNotifications();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Todas las notificaciones canceladas'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al cancelar notificaciones: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<custom_theme.ThemeProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.isDarkMode ? Colors.black : const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: themeProvider.isDarkMode ? Colors.black : Colors.white,
        title: Text(
          'Notificaciones',
          style: TextStyle(color: themeProvider.isDarkMode ? Colors.white : Colors.black87),
        ),
        iconTheme: IconThemeData(color: themeProvider.isDarkMode ? Colors.white : Colors.black54),
      ),
      body: ListView(
        children: [
          // Estado general de notificaciones
          _buildSectionHeader('Estado General'),
          SwitchListTile(
            title: Text(
              'Notificaciones activadas',
              style: TextStyle(color: themeProvider.isDarkMode ? Colors.white : Colors.black87),
            ),
            subtitle: Text(
              'Activar/desactivar todas las notificaciones',
              style: TextStyle(color: themeProvider.isDarkMode ? Colors.grey : Colors.black54),
            ),
            value: _notificationsEnabled,
            activeColor: const Color(0xFF00FF7F),
            onChanged: (value) {
              setState(() => _notificationsEnabled = value);
              _saveNotificationSettings();
            },
          ),

          const Divider(color: Colors.grey),

          // Tipos de notificaciones
          _buildSectionHeader('Tipos de Notificaciones'),
          SwitchListTile(
            title: Text(
              'Recordatorios diarios',
              style: TextStyle(color: themeProvider.isDarkMode ? Colors.white : Colors.black87),
            ),
            subtitle: Text(
              'Notificaciones cada 15 minutos para motivarte',
              style: TextStyle(color: themeProvider.isDarkMode ? Colors.grey : Colors.black54),
            ),
            value: _dailyRemindersEnabled,
            activeColor: const Color(0xFF00FF7F),
            onChanged: _notificationsEnabled
                ? (value) {
                    setState(() => _dailyRemindersEnabled = value);
                    _saveNotificationSettings();
                  }
                : null,
          ),

          SwitchListTile(
            title: Text(
              'Logros y recompensas',
              style: TextStyle(color: themeProvider.isDarkMode ? Colors.white : Colors.black87),
            ),
            subtitle: Text(
              'Notificaciones cuando completes objetivos',
              style: TextStyle(color: themeProvider.isDarkMode ? Colors.grey : Colors.black54),
            ),
            value: _achievementNotificationsEnabled,
            activeColor: const Color(0xFF00FF7F),
            onChanged: _notificationsEnabled
                ? (value) {
                    setState(() => _achievementNotificationsEnabled = value);
                    _saveNotificationSettings();
                  }
                : null,
          ),

          const Divider(color: Colors.grey),

          // Configuración de sonido
          _buildSectionHeader('Configuración'),
          SwitchListTile(
            title: Text(
              'Sonido',
              style: TextStyle(color: themeProvider.isDarkMode ? Colors.white : Colors.black87),
            ),
            subtitle: Text(
              'Reproducir sonido con las notificaciones',
              style: TextStyle(color: themeProvider.isDarkMode ? Colors.grey : Colors.black54),
            ),
            value: _soundEnabled,
            activeColor: const Color(0xFF00FF7F),
            onChanged: _notificationsEnabled
                ? (value) {
                    setState(() => _soundEnabled = value);
                    _saveNotificationSettings();
                  }
                : null,
          ),

          SwitchListTile(
            title: Text(
              'Vibración',
              style: TextStyle(color: themeProvider.isDarkMode ? Colors.white : Colors.black87),
            ),
            subtitle: Text(
              'Vibrar el dispositivo con las notificaciones',
              style: TextStyle(color: themeProvider.isDarkMode ? Colors.grey : Colors.black54),
            ),
            value: _vibrationEnabled,
            activeColor: const Color(0xFF00FF7F),
            onChanged: _notificationsEnabled
                ? (value) {
                    setState(() => _vibrationEnabled = value);
                    _saveNotificationSettings();
                  }
                : null,
          ),

          const Divider(color: Colors.grey),

          // Acciones de prueba
          _buildSectionHeader('Pruebas'),
          ListTile(
            leading: const Icon(Icons.notification_important, color: Color(0xFF00FF7F)),
            title: Text(
              'Probar notificación',
              style: TextStyle(color: themeProvider.isDarkMode ? Colors.white : Colors.black87),
            ),
            subtitle: Text(
              'Enviar una notificación de prueba inmediata',
              style: TextStyle(color: themeProvider.isDarkMode ? Colors.grey : Colors.black54),
            ),
            trailing: const Icon(Icons.send, color: Color(0xFF00FF7F)),
            onTap: _testNotification,
          ),

          ListTile(
            leading: const Icon(Icons.schedule, color: Color(0xFF00FF7F)),
            title: Text(
              'Programar notificaciones',
              style: TextStyle(color: themeProvider.isDarkMode ? Colors.white : Colors.black87),
            ),
            subtitle: Text(
              'Programar notificaciones cada 15 minutos',
              style: TextStyle(color: themeProvider.isDarkMode ? Colors.grey : Colors.black54),
            ),
            trailing: const Icon(Icons.play_arrow, color: Color(0xFF00FF7F)),
            onTap: _scheduleNotifications,
          ),

          ListTile(
            leading: const Icon(Icons.cancel, color: Colors.orange),
            title: Text(
              'Cancelar todas',
              style: TextStyle(color: themeProvider.isDarkMode ? Colors.white : Colors.black87),
            ),
            subtitle: Text(
              'Cancelar todas las notificaciones programadas',
              style: TextStyle(color: themeProvider.isDarkMode ? Colors.grey : Colors.black54),
            ),
            trailing: const Icon(Icons.stop, color: Colors.orange),
            onTap: _cancelAllNotifications,
          ),

          ListTile(
            leading: const Icon(Icons.list, color: Color(0xFF00FF7F)),
            title: Text(
              'Listar programadas',
              style: TextStyle(color: themeProvider.isDarkMode ? Colors.white : Colors.black87),
            ),
            subtitle: Text(
              'Ver todas las notificaciones programadas',
              style: TextStyle(color: themeProvider.isDarkMode ? Colors.grey : Colors.black54),
            ),
            trailing: const Icon(Icons.visibility, color: Color(0xFF00FF7F)),
            onTap: () async {
              await LocalNotificationService().listScheduledNotifications();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ Revisa los logs para ver las notificaciones programadas'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
          ),

          const SizedBox(height: 20),

          // Información
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: themeProvider.isDarkMode ? const Color(0xFF1C1C1C) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF00FF7F).withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info, color: Color(0xFF00FF7F)),
                      const SizedBox(width: 8),
                      Text(
                        'Información',
                        style: TextStyle(
                          color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Las notificaciones se envían cada 15 minutos durante todo el día para mantenerte motivado en tu camino Kaizeneka. Puedes ajustar la frecuencia y tipos de notificaciones según tus preferencias.',
                    style: TextStyle(
                      color: themeProvider.isDarkMode ? Colors.grey : Colors.black54,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.withOpacity(0.3)),
                    ),
                    // child: Column(
                    //   crossAxisAlignment: CrossAxisAlignment.start,
                    //   children: [
                    //     Row(
                    //       children: [
                    //         const Icon(Icons.warning, color: Colors.orange, size: 20),
                    //         const SizedBox(width: 8),
                    //         Text(
                    //           'Problema Detectado',
                    //           style: TextStyle(
                    //             color: Colors.orange,
                    //             fontWeight: FontWeight.bold,
                    //             fontSize: 14,
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //     const SizedBox(height: 8),
                    //     Text(
                    //       'Si las notificaciones programadas no aparecen, puede ser por restricciones de batería. Ve a:\n\nConfiguración > Apps > Kaizeneka > Batería > "Sin restricciones"\n\nO:\n\nConfiguración > Batería > Optimización > Todas las apps > Kaizeneka > "No optimizar"',
                    //       style: TextStyle(
                    //         color: themeProvider.isDarkMode ? Colors.grey[300] : Colors.black87,
                    //         fontSize: 12,
                    //       ),
                    //     ),
                    //   ],
                    // ),
                  ),
                ],
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