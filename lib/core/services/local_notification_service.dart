import 'dart:ui';
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

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Manejar acción de notificación
        if (response.payload == 'open_missions') {
          navigatorKey.currentState?.pushNamed('/all-missions');
        }
      },
    );

    // Solicitar permisos para Android 13+
    await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'kaizeneka_channel',
      'Kaizeneka Notifications',
      channelDescription: 'Notificaciones de Kaizeneka',
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
    await flutterLocalNotificationsPlugin.zonedSchedule(
      1,
      'Tu misión de hoy está lista, Kaizeneka 👊',
      '¡Es hora de lucrar! Completa tu misión diaria.',
      _nextInstanceOfTime(9, 0), // 9:00 AM
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'kaizeneka_channel',
          'Kaizeneka Notifications',
          channelDescription: 'Notificaciones de Kaizeneka',
          importance: Importance.max,
          priority: Priority.high,
          color: Color(0xFF00FF7F),
          icon: '@mipmap/ic_launcher',
          actions: <AndroidNotificationAction>[
            AndroidNotificationAction('open_missions', 'Abrir Misión'),
          ],
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'open_missions',
    );
  }

  Future<void> scheduleReminderNotification() async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      2,
      'Has palmado en las últimas 24h… vuelve a lucrar ⚡',
      '¡No dejes que el momentum se pierda! Completa una misión.',
      _nextInstanceOfTime(20, 0), // 8:00 PM
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'kaizeneka_channel',
          'Kaizeneka Notifications',
          channelDescription: 'Notificaciones de Kaizeneka',
          importance: Importance.max,
          priority: Priority.high,
          color: Color(0xFF00FF7F),
          icon: '@mipmap/ic_launcher',
          actions: <AndroidNotificationAction>[
            AndroidNotificationAction('open_missions', 'Abrir Misión'),
          ],
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'open_missions',
    );
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}