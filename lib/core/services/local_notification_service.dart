import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import '../../main.dart';

class LocalNotificationService {
  static final LocalNotificationService _instance = LocalNotificationService._internal();
  factory LocalNotificationService() => _instance;
  LocalNotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    //debugPrint('Inicializando servicio de notificaciones...');

    // Inicializar timezone
    tz.initializeTimeZones();

    // Configurar zona horaria local del dispositivo
    await _configureLocalTimezone();

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
          //debugPrint('Notificación recibida con payload: ${response.payload}');
          if (response.payload == 'open_missions') {
            navigatorKey.currentState?.pushNamed('/all-missions');
          } else if (response.payload == 'test_scheduled') {
          //  debugPrint('Notificación de prueba programada recibida correctamente');
          }
        },
      );
      //debugPrint('Plugin de notificaciones inicializado correctamente');
    } catch (e) {
      //debugPrint('Error inicializando plugin de notificaciones: $e');
      return;
    }

    // Solicitar permisos para Android 13+
    final androidPlugin = flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      try {
        await androidPlugin.requestNotificationsPermission();
        await androidPlugin.requestExactAlarmsPermission();
        //debugPrint('Permisos de notificaciones solicitados');
      } catch (e) {
        //debugPrint('Error solicitando permisos: $e');
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
      //debugPrint('Canal de notificaciones creado');
    } catch (e) {
      //debugPrint('Error creando canal de notificaciones: $e');
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
      //debugPrint('Canal de recordatorios creado');
    } catch (e) {
      //debugPrint('Error creando canal de recordatorios: $e');
    }

    // Verificar permisos después de inicialización
    await checkNotificationPermissions();

    // Programar notificaciones después de inicialización
    await scheduleDailyMissionNotification();
  }

  Future<void> checkNotificationPermissions() async {
    final androidPlugin = flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      final areEnabled = await androidPlugin.areNotificationsEnabled();
      //debugPrint('Notificaciones habilitadas: $areEnabled');

      if (areEnabled == false) {
      //  debugPrint('Las notificaciones no están habilitadas. Solicitando permisos...');
        await androidPlugin.requestNotificationsPermission();
      }
    }
  }

  Future<void> _configureLocalTimezone() async {
    try {
      final String timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
      final tz.Location location = tz.getLocation(timeZoneName);
      tz.setLocalLocation(location);
      //debugPrint('Zona horaria local configurada: $timeZoneName');
    } catch (e) {
      //debugPrint('Error configurando zona horaria local: $e');
      // Fallback a UTC si hay error
      tz.setLocalLocation(tz.getLocation('UTC'));
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
    //debugPrint('Iniciando programación de notificaciones...');

    // Verificar y solicitar permisos antes de programar
    final androidPlugin = flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      // Verificar permisos de notificaciones
      final notificationsEnabled = await androidPlugin.areNotificationsEnabled();
      //debugPrint('Permisos de notificaciones: $notificationsEnabled');

      if (notificationsEnabled == false) {
      //  debugPrint('Solicitando permisos de notificaciones...');
        final granted = await androidPlugin.requestNotificationsPermission();
        if (granted == false) {
        //  debugPrint('❌ Los permisos de notificaciones fueron denegados. No se pueden programar.');
          return;
        }
      }

      // Verificar y solicitar permisos de alarmas exactas
      //debugPrint('Verificando permisos de alarmas exactas...');
      final exactAlarmsGranted = await androidPlugin.requestExactAlarmsPermission();
      //debugPrint('Permisos de alarmas exactas: $exactAlarmsGranted');

      if (exactAlarmsGranted == false) {
        //debugPrint('⚠️ Permisos de alarmas exactas no concedidos. Las notificaciones pueden no funcionar correctamente.');
        //debugPrint('Nota: En Android 14+, las alarmas exactas requieren configuración manual del usuario.');
      }
    }

    // Cancelar todas las notificaciones anteriores con manejo de errores
    try {
      await flutterLocalNotificationsPlugin.cancelAll();
      //debugPrint('Notificaciones anteriores canceladas');
    } catch (e) {
      //debugPrint('Error cancelando notificaciones anteriores: $e');
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
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    int notificationId = 1;

    // debugPrint('Hora actual del dispositivo: ${DateTime.now()}');
    // debugPrint('Zona horaria local: ${tz.local}');
    // debugPrint('Usando TZDateTime en zona local: $now');

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

    // Determinar límites según plataforma
    final int maxNotifications;
    final bool isAndroid = defaultTargetPlatform == TargetPlatform.android;

    if (isAndroid) {
      maxNotifications = 500; // Límite de Android AlarmManager
    } else {
      maxNotifications = 64; // Límite de iOS
    }

    // Programar solo 3 notificaciones motivacionales diarias
    final List<Map<String, dynamic>> dailyNotifications = [
      {'hour': 7, 'minute': 0, 'title': '¡Buenos días, Kaizeneka! 🌅', 'message': 'Comienza tu día con propósito. ¿Qué misión completarás hoy?'},
      {'hour': 14, 'minute': 10, 'title': '¡Hora de acción! ⚡', 'message': 'La mitad del día ya pasó. ¿Estás en camino hacia tus metas?'},
      {'hour': 14, 'minute': 15, 'title': '¡Reflexiona y crece! 🌙', 'message': 'Antes de dormir, revisa tu progreso. Mañana serás mejor.'},
    ];

    int notificationsScheduled = 0;

    for (final notification in dailyNotifications) {
      final tz.TZDateTime scheduledTime = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        notification['hour'] as int,
        notification['minute'] as int,
      );

      // Si la hora ya pasó hoy, programar para mañana
      final tz.TZDateTime scheduledTimeAdjusted = scheduledTime.isBefore(now)
          ? scheduledTime.add(const Duration(days: 1))
          : scheduledTime;

        // Seleccionar mensaje aleatorio
        final randomIndex = notificationsScheduled % titles.length;

      try {
        await flutterLocalNotificationsPlugin.zonedSchedule(
          notificationId,
            titles[randomIndex],
            messages[randomIndex],
          scheduledTimeAdjusted,
          NotificationDetails(
            android: androidDetails,
            iOS: const DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.time, // Programar diariamente a la misma hora
          payload: 'open_missions',
        );
        //debugPrint('✅ Notificación motivacional $notificationId programada exitosamente');
        notificationsScheduled++;
      } catch (e) {
        // debugPrint('❌ Error programando notificación motivacional $notificationId: $e');
        // debugPrint('   Detalles del error: ${e.toString()}');
        // debugPrint('   Hora programada: $scheduledTimeAdjusted');
      }

      notificationId++;
    }

    //debugPrint('Total de notificaciones motivacionales programadas: $notificationsScheduled');

    // Verificar si se programaron notificaciones exitosamente
    if (notificationsScheduled == 0) {
      //debugPrint('⚠️ ADVERTENCIA: No se programó ninguna notificación motivacional. Verifica permisos y configuración.');
    } else {
      //debugPrint('✅ Éxito: $notificationsScheduled notificaciones motivacionales programadas correctamente.');
      // debugPrint('   - 7:00 AM: Recordatorio matutino');
      // debugPrint('   - 2:00 PM: Motivación de la tarde');
      // debugPrint('   - 7:00 PM: Reflexión nocturna');
    }

    // Listar todas las notificaciones programadas para verificar
    await listScheduledNotifications();

    // Mostrar notificación inmediata para confirmar que el sistema funciona
    //debugPrint('Mostrando notificación inmediata de confirmación...');
    // await testNotification();
  }

  // Método obsoleto - ahora todas las notificaciones se manejan en scheduleDailyMissionNotification
  Future<void> scheduleReminderNotification() async {
    // Esta función ya no se usa, todas las notificaciones se programan en scheduleDailyMissionNotification
    //debugPrint('scheduleReminderNotification() está obsoleto, usando scheduleDailyMissionNotification()');
    await scheduleDailyMissionNotification();
  }

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  // Método para reprogramar notificaciones al reinicio del dispositivo
  Future<void> rescheduleNotificationsOnBoot() async {
    //debugPrint('🔄 Reprogramando notificaciones después del reinicio del dispositivo...');
    await scheduleDailyMissionNotification();
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  Future<void> testNotification() async {
    //debugPrint('Mostrando notificación de prueba...');

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
      //debugPrint('Notificación de prueba mostrada exitosamente');
    } catch (e) {
      //debugPrint('Error mostrando notificación de prueba: $e');
    }
  }

  Future<void> listScheduledNotifications() async {
    try {
      final pendingNotifications = await flutterLocalNotificationsPlugin.pendingNotificationRequests();
      // debugPrint('=== LISTADO DE NOTIFICACIONES PROGRAMADAS ===');
      // debugPrint('Total de notificaciones programadas: ${pendingNotifications.length}');
      // debugPrint('Hora actual del dispositivo: ${DateTime.now()}');

      // for (final notification in pendingNotifications) {
      //   debugPrint('ID: ${notification.id}');
      //   debugPrint('  Título: ${notification.title}');
      //   debugPrint('  Cuerpo: ${notification.body}');
      //   debugPrint('  Payload: ${notification.payload}');
      //   debugPrint('  ---');
      // }
      // debugPrint('=== FIN DEL LISTADO ===');

      // Verificar permisos de batería/Doze mode
      // await checkBatteryOptimization();
    } catch (e) {
      //debugPrint('Error obteniendo notificaciones programadas: $e');
    }
  }

  // Future<void> checkBatteryOptimization() async {
  //   try {
  //     final androidPlugin = flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
  //     if (androidPlugin != null) {
  //       // Verificar si la app está en whitelist de batería
  //       debugPrint('=== VERIFICACIÓN DE BATERÍA ===');
  //       debugPrint('Nota: Las notificaciones programadas pueden estar bloqueadas por:');
  //       debugPrint('1. Modo de ahorro de batería');
  //       debugPrint('2. Modo Doze/Sleep de Android');
  //       debugPrint('3. Restricciones de batería de la app');
  //       debugPrint('4. Permisos de alarmas exactas no concedidos');
  //       debugPrint('');
  //       debugPrint('Solución: Ve a Configuración > Apps > Kaizeneka > Batería > Sin restricciones');
  //       debugPrint('O: Configuración > Batería > Optimización de batería > Todas las apps > Kaizeneka > No optimizar');
  //       debugPrint('=== FIN VERIFICACIÓN BATERÍA ===');
  //     }
  //   } catch (e) {
  //     debugPrint('Error verificando batería: $e');
  //   }
  // }
}