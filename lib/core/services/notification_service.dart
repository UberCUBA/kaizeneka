import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../../models/user_model.dart';
import 'supabase_service.dart';
import 'progress_service.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(settings);
  }

  // Notificaciones de progreso
  static Future<void> scheduleProgressNotifications(String userId) async {
    final user = await SupabaseService.getUserProfile(userId);
    if (user == null) return;

    // Notificación diaria de progreso
    await _scheduleDailyProgressReminder();

    // Notificación de racha si está en riesgo
    if (user.streak > 0 && user.streak < 3) {
      await _scheduleStreakReminder();
    }

    // Notificación de cinturón si está cerca
    final nextBelt = _getNextBelt(user.belt);
    final nextBeltPoints = ProgressService.calculatePointsRequiredForBelt(nextBelt);
    final pointsNeeded = nextBeltPoints - user.points;
    if (pointsNeeded <= 50 && nextBelt != user.belt) {
      await _scheduleBeltUpReminder(pointsNeeded, nextBelt);
    }

    // Notificación de energía baja
    if (user.energy < 30) {
      await _scheduleEnergyReminder();
    }
  }

  // Notificación diaria de progreso
  static Future<void> _scheduleDailyProgressReminder() async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'daily_progress',
      'Progreso Diario',
      channelDescription: 'Recordatorios diarios de progreso',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const NotificationDetails details = NotificationDetails(android: androidDetails);

    // Programar para las 8 PM todos los días
    await _notificationsPlugin.zonedSchedule(
      1,
      '¡Hora de revisar tu progreso! 🏆',
      '¿Completaste tus tareas hoy? Revisa tu racha y nivel.',
      _nextInstanceOfTime(20, 0), // 8:00 PM
      details,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  // Notificación de racha en riesgo
  static Future<void> _scheduleStreakReminder() async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'streak_reminder',
      'Recordatorio de Racha',
      channelDescription: 'Recordatorios para mantener tu racha',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails details = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      2,
      '¡No pierdas tu racha! 🔥',
      'Tienes una racha activa. ¡Completa tus hábitos hoy!',
      details,
    );
  }

  // Notificación de subida de cinturón cercana
  static Future<void> _scheduleBeltUpReminder(int pointsNeeded, String nextBelt) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'belt_up',
      'Subida de Cinturón',
      channelDescription: 'Notificaciones de progreso de cinturón',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails details = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      3,
      '¡Estás cerca del cinturón $nextBelt! 🥋',
      'Solo necesitas $pointsNeeded puntos más. ¡Sigue así!',
      details,
    );
  }

  // Método auxiliar para obtener el siguiente cinturón
  static String _getNextBelt(String currentBelt) {
    const beltOrder = ['Blanco', 'Amarillo', 'Naranja', 'Verde', 'Marrón', 'Negro', 'Sobrado'];
    final currentIndex = beltOrder.indexOf(currentBelt);
    if (currentIndex == -1 || currentIndex == beltOrder.length - 1) return currentBelt;
    return beltOrder[currentIndex + 1];
  }

  // Notificación de energía baja
  static Future<void> _scheduleEnergyReminder() async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'energy_low',
      'Energía Baja',
      channelDescription: 'Recordatorios de energía',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );

    const NotificationDetails details = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      4,
      'Tu energía está baja ⚡',
      'Toma un descanso o realiza una actividad energizante.',
      details,
    );
  }

  // Notificaciones de gamificación
  static Future<void> showAchievementNotification(String achievementName, String description) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'achievement',
      'Logros',
      channelDescription: 'Notificaciones de logros desbloqueados',
      importance: Importance.high,
      priority: Priority.high,
      sound: RawResourceAndroidNotificationSound('achievement_sound'),
    );

    const NotificationDetails details = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      5,
      '¡Nuevo logro desbloqueado! 🏆',
      '$achievementName: $description',
      details,
    );
  }

  static Future<void> showLevelUpNotification(int newLevel) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'level_up_celebration',
      'Subida de Nivel',
      channelDescription: 'Celebraciones de subida de nivel',
      importance: Importance.high,
      priority: Priority.high,
      sound: RawResourceAndroidNotificationSound('level_up_sound'),
    );

    const NotificationDetails details = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      6,
      '¡Felicidades! Subiste al nivel $newLevel 🎉',
      '¡Sigue avanzando en tu camino Kaizeneka!',
      details,
    );
  }

  static Future<void> showStreakNotification(int streak) async {
    if (streak % 7 == 0) { // Cada semana
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'streak_milestone',
        'Hitos de Racha',
        channelDescription: 'Celebraciones de rachas importantes',
        importance: Importance.high,
        priority: Priority.high,
      );

      const NotificationDetails details = NotificationDetails(android: androidDetails);

      await _notificationsPlugin.show(
        7,
        '¡Racha increíble! 🔥',
        'Llevas $streak días consecutivos. ¡Eres imparable!',
        details,
      );
    }
  }

  // Notificaciones de misiones
  static Future<void> showMissionAvailableNotification(String missionTitle) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'mission_available',
      'Misiones Disponibles',
      channelDescription: 'Nuevas misiones disponibles',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );

    const NotificationDetails details = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      8,
      'Nueva misión disponible 📜',
      '$missionTitle - ¡Acepta el desafío!',
      details,
    );
  }

  static Future<void> showMissionCompletedNotification(String missionTitle, int xpReward, int coinsReward) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'mission_completed',
      'Misiones Completadas',
      channelDescription: 'Celebraciones de misiones completadas',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails details = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      9,
      '¡Misión completada! 🎯',
      '$missionTitle - Ganaste $xpReward XP y $coinsReward monedas',
      details,
    );
  }

  // Notificaciones de JVC
  static Future<void> showJvcBalanceReminder() async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'jvc_balance',
      'Equilibrio JVC',
      channelDescription: 'Recordatorios de equilibrio vital',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );

    const NotificationDetails details = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      10,
      'Revisa tu equilibrio vital ⚖️',
      '¿Están tus 3 áreas vitales en armonía?',
      details,
    );
  }

  // Notificaciones motivacionales
  static Future<void> showMotivationalNotification() async {
    final messages = [
      '¡Cada pequeño paso cuenta! 👣',
      'La consistencia vence al talento 💪',
      'Estás construyendo un mejor tú 🏗️',
      'El cambio comienza con una decisión 🤝',
      '¡Sigue adelante! Tu futuro yo te lo agradecerá 🙏',
    ];

    final randomMessage = messages[DateTime.now().millisecondsSinceEpoch % messages.length];

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'motivation',
      'Motivación',
      channelDescription: 'Mensajes motivacionales',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );

    const NotificationDetails details = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      11,
      'Mensaje del día 💭',
      randomMessage,
      details,
    );
  }

  // Utilidades
  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  static Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  static Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }
}
