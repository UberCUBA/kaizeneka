import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'package:workmanager/workmanager.dart';
import 'package:provider/provider.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/missions/presentation/providers/mission_provider.dart';

/// Used for Background Updates using Workmanager Plugin
@pragma("vm:entry-point")
void callbackDispatcher() async {
  Workmanager().executeTask((taskName, inputData) {
    final now = DateTime.now();
    return Future.wait<bool?>([
      HomeWidget.saveWidgetData(
        'title',
        'NK+ - ¡Vamos!',
      ),
      HomeWidget.saveWidgetData(
        'message',
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
      ),
      HomeWidget.saveWidgetData(
        'xp_total',
        'XP: ${inputData?['xp_total'] ?? 0}',
      ),
      HomeWidget.saveWidgetData(
        'streak',
        'Racha: ${inputData?['streak'] ?? 0} días',
      ),
    ]).then((value) async {
      Future.wait<bool?>([
        HomeWidget.updateWidget(
          name: 'HomeWidgetExampleProvider',
          iOSName: 'HomeWidgetExample',
        ),
        if (Platform.isAndroid)
          HomeWidget.updateWidget(
            qualifiedAndroidName:
                'com.kaizeneka.nk.HomeWidgetReceiver',
          ),
      ]);
      return !value.contains(false);
    });
  });
}

/// Called when Doing Background Work initiated from Widget
@pragma("vm:entry-point")
Future<void> interactiveCallback(Uri? data) async {
  if (data?.host == 'openapp') {
    // Abrir la app cuando se hace tap en el widget
    // Esto se maneja automáticamente por el sistema
  } else if (data?.host == 'newmission') {
    // Abrir la app en la sección de misiones
    // Esto se maneja en el callback de la app principal
  }
}

class HomeWidgetService {
  static const String appGroupId = 'group.com.kaizeneka.nk';

  static Future<void> initialize() async {
    try {
      await HomeWidget.setAppGroupId(appGroupId);
      HomeWidget.registerInteractivityCallback(interactiveCallback);

      // Inicializar Workmanager para actualizaciones en background
      await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
    } catch (e) {
      debugPrint('Error initializing HomeWidget: $e');
    }
  }

  static Future<void> updateWidgetData(BuildContext context) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final missionProvider = Provider.of<MissionProvider>(context, listen: false);

      final userProfile = authProvider.userProfile;
      final pendingMissions = missionProvider.pendingMissions.length;

      await Future.wait([
        HomeWidget.saveWidgetData<String>('title', 'NK+ - ¡Vamos!'),
        HomeWidget.saveWidgetData<String>('xp_total', 'XP: ${userProfile?.points ?? 0}'),
        HomeWidget.saveWidgetData<String>('streak', 'Racha: ${userProfile?.streak ?? 0} días'),
        HomeWidget.saveWidgetData<String>('pending_missions', 'Misiones: $pendingMissions'),
        HomeWidget.saveWidgetData<String>('belt', 'Cinturón: ${userProfile?.belt ?? 'Blanco'}'),
      ]);

      await _updateWidget();
    } catch (e) {
      debugPrint('Error updating widget data: $e');
    }
  }

  static Future<void> _updateWidget() async {
    try {
      await Future.wait([
        HomeWidget.updateWidget(
          name: 'HomeWidgetExampleProvider',
          iOSName: 'HomeWidgetExample',
        ),
        if (Platform.isAndroid)
          HomeWidget.updateWidget(
            qualifiedAndroidName: 'com.kaizeneka.nk.HomeWidgetReceiver',
          ),
      ]);
    } catch (e) {
      debugPrint('Error updating widget: $e');
    }
  }

  static Future<void> requestPinWidget() async {
    try {
      if (Platform.isAndroid) {
        await HomeWidget.requestPinWidget(
          qualifiedAndroidName: 'com.kaizeneka.nk.HomeWidgetReceiver',
        );
      }
    } catch (e) {
      debugPrint('Error requesting pin widget: $e');
    }
  }

  static Future<void> startBackgroundUpdates() async {
    try {
      await Workmanager().registerPeriodicTask(
        'widget_update',
        'widgetBackgroundUpdate',
        frequency: const Duration(hours: 1), // Actualizar cada hora
        inputData: <String, dynamic>{},
      );
    } catch (e) {
      debugPrint('Error starting background updates: $e');
    }
  }

  static Future<void> stopBackgroundUpdates() async {
    try {
      await Workmanager().cancelByUniqueName('widget_update');
    } catch (e) {
      debugPrint('Error stopping background updates: $e');
    }
  }

  static Future<bool> isWidgetSupported() async {
    try {
      return await HomeWidget.isRequestPinWidgetSupported() ?? false;
    } catch (e) {
      return false;
    }
  }

  static Future<List<HomeWidgetInfo>> getInstalledWidgets() async {
    try {
      return await HomeWidget.getInstalledWidgets();
    } catch (e) {
      debugPrint('Error getting installed widgets: $e');
      return [];
    }
  }
}