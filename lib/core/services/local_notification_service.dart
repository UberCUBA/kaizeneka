import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../../main.dart';

class LocalNotificationService {
  static final LocalNotificationService _instance = LocalNotificationService._internal();
  factory LocalNotificationService() => _instance;
  LocalNotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    debugPrint('Inicializando servicio de notificaciones...');

    // Inicializar timezone
    tz.initializeTimeZones();

    // Configuración para Android
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');

    // Configuración para iOS
    const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    try {
      await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          // Manejar acción de notificación
          debugPrint('Notificación recibida con payload: ${response.payload}');
          if (response.payload == 'open_missions') {
            navigatorKey.currentState?.pushNamed('/all-missions');
          } else if (response.payload == 'test_scheduled') {
            debugPrint('Notificación de prueba programada recibida correctamente');
          }
        },
      );
      debugPrint('Plugin de notificaciones inicializado correctamente');
    } catch (e) {
      debugPrint('Error inicializando plugin de notificaciones: $e');
      return;
    }

    // Solicitar permisos para Android 13+
    final androidPlugin = flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      try {
        await androidPlugin.requestNotificationsPermission();
        await androidPlugin.requestExactAlarmsPermission();
        debugPrint('Permisos de notificaciones solicitados');
      } catch (e) {
        debugPrint('Error solicitando permisos: $e');
      }
    }

    // Crear canal de notificaciones para Android (compatible con versiones antiguas)
    try {
      await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(
        const AndroidNotificationChannel(
          'kaizeneka_channel',
          'NK Notifications',
          description: 'Notificaciones NK',
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
          enableLights: true,
          ledColor: Color(0xFF00FF7F),
        ),
      );
      debugPrint('Canal de notificaciones creado');
    } catch (e) {
      debugPrint('Error creando canal de notificaciones: $e');
    }

    // Para Android 8.0+, crear canal adicional si es necesario
    try {
      await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(
        const AndroidNotificationChannel(
          'kaizeneka_reminders',
          'NK Reminders',
          description: 'Recordatorios NK',
          importance: Importance.high,
          playSound: true,
          enableVibration: true,
        ),
      );
      debugPrint('Canal de recordatorios creado');
    } catch (e) {
      debugPrint('Error creando canal de recordatorios: $e');
    }

    // Verificar permisos después de inicialización
    await checkNotificationPermissions();
  }

  Future<void> checkNotificationPermissions() async {
    final androidPlugin = flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      final areEnabled = await androidPlugin.areNotificationsEnabled();
      debugPrint('Notificaciones habilitadas: $areEnabled');

      if (areEnabled == false) {
        debugPrint('Las notificaciones no están habilitadas. Solicitando permisos...');
        await androidPlugin.requestNotificationsPermission();
      }
    }
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'kaizeneka_channel',
      'NK Notifications',
      channelDescription: 'Notificaciones NK',
      importance: Importance.max,
      priority: Priority.high,
      color: Color(0xFF00FF7F),
      icon: '@mipmap/ic_launcher',
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction('open_missions', 'Abrir Misión'),
      ],
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  Future<void> scheduleDailyMissionNotification() async {
    debugPrint('Iniciando programación de notificaciones...');

    // Verificar permisos antes de programar
    final androidPlugin = flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      final notificationsEnabled = await androidPlugin.areNotificationsEnabled();
      final exactAlarmsGranted = await androidPlugin.requestExactAlarmsPermission();

      debugPrint('Permisos de notificaciones: $notificationsEnabled');
      debugPrint('Permisos de alarmas exactas: $exactAlarmsGranted');

      if (notificationsEnabled == false) {
        debugPrint('❌ Las notificaciones no están habilitadas. No se pueden programar.');
        return;
      }

      if (exactAlarmsGranted == false) {
        debugPrint('⚠️ Permisos de alarmas exactas no concedidos. Las notificaciones pueden no funcionar correctamente.');
      }
    }

    // Cancelar todas las notificaciones anteriores con manejo de errores
    try {
      await flutterLocalNotificationsPlugin.cancelAll();
      debugPrint('Notificaciones anteriores canceladas');
    } catch (e) {
      debugPrint('Error cancelando notificaciones anteriores: $e');
    }

    // Para Android 8+, usar el canal específico
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'kaizeneka_channel',
      'NK Notifications',
      channelDescription: 'Notificaciones NK',
      importance: Importance.max,
      priority: Priority.high,
      color: Color(0xFF00FF7F),
      icon: '@mipmap/ic_launcher',
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction('open_missions', 'Abrir Misión'),
      ],
      // Configuraciones adicionales para compatibilidad
      playSound: true,
      enableVibration: true,
      enableLights: true,
      ledColor: Color(0xFF00FF7F),
      ledOnMs: 1000,
      ledOffMs: 1000,
    );

    // Usar zona horaria local del dispositivo para programar notificaciones
    final deviceTime = DateTime.now();
    String timeZoneName = deviceTime.timeZoneName;

    // Manejar zonas horarias no estándar que no existen en la base de datos de timezone
    if (timeZoneName == 'CST' || timeZoneName == 'CDT') {
      // CST/CDT generalmente corresponde a America/Chicago o America/Mexico_City
      // Usar una zona horaria estándar que funcione
      timeZoneName = 'America/New_York'; // Usar zona horaria del este de EE.UU. como fallback
    }

    try {
      final localLocation = tz.getLocation(timeZoneName);
      final tz.TZDateTime now = tz.TZDateTime.from(deviceTime, localLocation);
      int notificationId = 1;

      debugPrint('Hora actual del dispositivo: $deviceTime');
      debugPrint('Zona horaria del dispositivo: $timeZoneName');
      debugPrint('Offset zona horaria: ${deviceTime.timeZoneOffset}');
      debugPrint('Usando TZDateTime en zona local: $now');

      // Crear lista de mensajes motivacionales variados
      final List<String> titles = [
        '¡Hora de Kaizeneka! ⚡',
        'Tu momento de crecimiento 🥷',
        '¡Es hora de lucrar! 💰',
        'Misión diaria lista 👊',
        '¡Despierta tu potencial! 🌟',
        'Momento de acción 🔥',
        '¡Kaizeneka te llama! 📞',
        'Tu transformación continúa 🚀',
        '¡No pares ahora! 💪',
        'Momento de excelencia 💎',
        '¡Sigue adelante! 🎯',
        'Tu éxito te espera 🏆',
      ];

      final List<String> messages = [
        'Completa tu misión diaria y gana XP',
        'Cada acción cuenta para tu crecimiento',
        '¡Es momento de hacer que suceda!',
        'Tu consistencia te llevará al éxito',
        '¡Un paso más hacia la grandeza!',
        'El éxito es la suma de pequeños esfuerzos',
        '¡Mantén el momentum vivo!',
        'Cada día es una oportunidad de oro',
        '¡Tu futuro yo te lo agradecerá!',
        'La excelencia es un hábito, no un acto',
        '¡Sigue construyendo tu legado!',
        '¡El cambio comienza ahora!',
      ];

      // Programar notificaciones cada 15 minutos durante todo el día
      int notificationsScheduled = 0;
      for (int hour = 8; hour <= 22; hour++) { // De 8 AM a 10 PM
        for (int minute = 0; minute < 60; minute += 15) { // Cada 15 minutos
          final tz.TZDateTime scheduledTime = tz.TZDateTime(localLocation, now.year, now.month, now.day, hour, minute);

          // Si la hora ya pasó hoy, programar para mañana
          if (scheduledTime.isBefore(now)) {
            scheduledTime.add(const Duration(days: 1));
          }

          // Seleccionar mensaje aleatorio
          final randomIndex = notificationsScheduled % titles.length;

          debugPrint('Programando notificación $notificationId para: $scheduledTime');
          debugPrint('  Fecha y hora programada: ${scheduledTime.toString()}');
          debugPrint('  Offset zona horaria: ${scheduledTime.timeZoneOffset}');

          try {
            await flutterLocalNotificationsPlugin.zonedSchedule(
              notificationId,
              titles[randomIndex],
              messages[randomIndex],
              scheduledTime,
              NotificationDetails(
                android: androidDetails,
                iOS: const DarwinNotificationDetails(
                  presentAlert: true,
                  presentBadge: true,
                  presentSound: true,
                ),
              ),
              androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
              uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.wallClockTime,
              matchDateTimeComponents: null,
              payload: 'open_missions',
            );
            debugPrint('✅ Notificación $notificationId programada exitosamente');
            notificationsScheduled++;
          } catch (e) {
            debugPrint('❌ Error programando notificación $notificationId: $e');
          }

          notificationId++;
          if (notificationId > 96) break; // Límite de notificaciones
        }
        if (notificationId > 96) break;
      }
    } catch (e) {
      debugPrint('❌ Error obteniendo zona horaria $timeZoneName: $e');
      debugPrint('Usando UTC como fallback...');

      // Fallback a UTC si hay problemas con la zona horaria
      final tz.TZDateTime now = tz.TZDateTime.from(deviceTime, tz.UTC);
      int notificationId = 1;

      debugPrint('Hora actual del dispositivo: $deviceTime');
      debugPrint('Usando TZDateTime en UTC (fallback): $now');

      // Crear lista de mensajes motivacionales variados
      final List<String> titles = [
        '¡Hora de Kaizeneka! ⚡',
        'Tu momento de crecimiento 🥷',
        '¡Es hora de lucrar! 💰',
        'Misión diaria lista 👊',
        '¡Despierta tu potencial! 🌟',
        'Momento de acción 🔥',
        '¡Kaizeneka te llama! 📞',
        'Tu transformación continúa 🚀',
        '¡No pares ahora! 💪',
        'Momento de excelencia 💎',
        '¡Sigue adelante! 🎯',
        'Tu éxito te espera 🏆',
      ];

      final List<String> messages = [
        'Completa tu misión diaria y gana XP',
        'Cada acción cuenta para tu crecimiento',
        '¡Es momento de hacer que suceda!',
        'Tu consistencia te llevará al éxito',
        '¡Un paso más hacia la grandeza!',
        'El éxito es la suma de pequeños esfuerzos',
        '¡Mantén el momentum vivo!',
        'Cada día es una oportunidad de oro',
        '¡Tu futuro yo te lo agradecerá!',
        'La excelencia es un hábito, no un acto',
        '¡Sigue construyendo tu legado!',
        '¡El cambio comienza ahora!',
      ];

      // Programar notificaciones cada 15 minutos durante todo el día
      int notificationsScheduled = 0;
      for (int hour = 8; hour <= 22; hour++) { // De 8 AM a 10 PM
        for (int minute = 0; minute < 60; minute += 15) { // Cada 15 minutos
          final tz.TZDateTime scheduledTime = tz.TZDateTime(tz.UTC, now.year, now.month, now.day, hour, minute);

          // Si la hora ya pasó hoy, programar para mañana
          if (scheduledTime.isBefore(now)) {
            scheduledTime.add(const Duration(days: 1));
          }

          // Seleccionar mensaje aleatorio
          final randomIndex = notificationsScheduled % titles.length;

          debugPrint('Programando notificación $notificationId para: $scheduledTime (UTC)');
          debugPrint('  Fecha y hora programada: ${scheduledTime.toString()}');

          try {
            await flutterLocalNotificationsPlugin.zonedSchedule(
              notificationId,
              titles[randomIndex],
              messages[randomIndex],
              scheduledTime,
              NotificationDetails(
                android: androidDetails,
                iOS: const DarwinNotificationDetails(
                  presentAlert: true,
                  presentBadge: true,
                  presentSound: true,
                ),
              ),
              androidScheduleMode: AndroidScheduleMode.exact,
              uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
              matchDateTimeComponents: DateTimeComponents.time,
              payload: 'open_missions',
            );
            debugPrint('✅ Notificación $notificationId programada exitosamente');
            notificationsScheduled++;
          } catch (e) {
            debugPrint('❌ Error programando notificación $notificationId: $e');
          }

          notificationId++;
          if (notificationId > 96) break; // Límite de notificaciones
        }
        if (notificationId > 96) break;
      }
    }

    debugPrint('Total de notificaciones programadas: 0');

    // Listar todas las notificaciones programadas para verificar
    await listScheduledNotifications();

    // Mostrar notificación inmediata para confirmar que el sistema funciona
    debugPrint('Mostrando notificación inmediata de confirmación...');
    await testNotification();
  }

  // Método obsoleto - ahora todas las notificaciones se manejan en scheduleDailyMissionNotification
  Future<void> scheduleReminderNotification() async {
    // Esta función ya no se usa, todas las notificaciones se programan en scheduleDailyMissionNotification
    debugPrint('scheduleReminderNotification() está obsoleto, usando scheduleDailyMissionNotification()');
    await scheduleDailyMissionNotification();
  }

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final deviceTime = DateTime.now();
    String timeZoneName = deviceTime.timeZoneName;

    // Manejar zonas horarias no estándar
    if (timeZoneName == 'CST' || timeZoneName == 'CDT') {
      timeZoneName = 'America/New_York';
    }

    try {
      final localLocation = tz.getLocation(timeZoneName);
      final tz.TZDateTime now = tz.TZDateTime.from(deviceTime, localLocation);
      tz.TZDateTime scheduledDate = tz.TZDateTime(localLocation, now.year, now.month, now.day, hour, minute);

      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      return scheduledDate;
    } catch (e) {
      // Fallback a UTC
      final tz.TZDateTime now = tz.TZDateTime.from(deviceTime, tz.UTC);
      tz.TZDateTime scheduledDate = tz.TZDateTime(tz.UTC, now.year, now.month, now.day, hour, minute);

      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      return scheduledDate;
    }
  }

  Future<void> testNotification() async {
    debugPrint('Mostrando notificación de prueba...');

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'kaizeneka_channel',
      'NK Notifications',
      channelDescription: 'Notificaciones NK',
      importance: Importance.max,
      priority: Priority.high,
      color: Color(0xFF00FF7F),
      icon: '@mipmap/ic_launcher',
      playSound: true,
      enableVibration: true,
      enableLights: true,
      ledColor: Color(0xFF00FF7F),
      ledOnMs: 1000,
      ledOffMs: 1000,
    );

    try {
      await flutterLocalNotificationsPlugin.show(
        999,
        'Test Notification',
        'Esta es una notificación pingsssss - ${DateTime.now().toString()}',
        NotificationDetails(
          android: androidDetails,
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: 'test',
      );
      debugPrint('Notificación de prueba mostrada exitosamente');
    } catch (e) {
      debugPrint('Error mostrando notificación de prueba: $e');
    }
  }

  Future<void> listScheduledNotifications() async {
    try {
      final pendingNotifications = await flutterLocalNotificationsPlugin.pendingNotificationRequests();
      debugPrint('=== LISTADO DE NOTIFICACIONES PROGRAMADAS ===');
      debugPrint('Total de notificaciones programadas: ${pendingNotifications.length}');
      debugPrint('Hora actual del dispositivo: ${DateTime.now()}');

      for (final notification in pendingNotifications) {
        debugPrint('ID: ${notification.id}');
        debugPrint('  Título: ${notification.title}');
        debugPrint('  Cuerpo: ${notification.body}');
        debugPrint('  Payload: ${notification.payload}');
        debugPrint('  ---');
      }
      debugPrint('=== FIN DEL LISTADO ===');

      // Verificar permisos de batería/Doze mode
      await checkBatteryOptimization();
    } catch (e) {
      debugPrint('Error obteniendo notificaciones programadas: $e');
    }
  }

  Future<void> checkBatteryOptimization() async {
    try {
      final androidPlugin = flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        // Verificar si la app está en whitelist de batería
        debugPrint('=== VERIFICACIÓN DE BATERÍA ===');
        debugPrint('Nota: Las notificaciones programadas pueden estar bloqueadas por:');
        debugPrint('1. Modo de ahorro de batería');
        debugPrint('2. Modo Doze/Sleep de Android');
        debugPrint('3. Restricciones de batería de la app');
        debugPrint('4. Permisos de alarmas exactas no concedidos');
        debugPrint('');
        debugPrint('Solución: Ve a Configuración > Apps > Kaizeneka > Batería > Sin restricciones');
        debugPrint('O: Configuración > Batería > Optimización de batería > Todas las apps > Kaizeneka > No optimizar');
        debugPrint('=== FIN VERIFICACIÓN BATERÍA ===');
      }
    } catch (e) {
      debugPrint('Error verificando batería: $e');
    }
  }
}