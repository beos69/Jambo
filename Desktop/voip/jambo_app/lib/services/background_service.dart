import 'dart:async';
import 'dart:ui';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class BackgroundService {
  static final BackgroundService _instance = BackgroundService._internal();
  factory BackgroundService() => _instance;

  final FlutterBackgroundService _service = FlutterBackgroundService();
  bool _isRunning = false;

  BackgroundService._internal();

  Future<void> initialize() async {
    await _service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: true,
        isForegroundMode: true,
        notificationChannelId: 'jambo_service',
        initialNotificationTitle: 'Jambo Service',
        initialNotificationContent: 'En attente d\'appels',
        foregroundServiceNotificationId: 888,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: true,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
    );
  }

  static Future<bool> onIosBackground(ServiceInstance service) async {
    return true;
  }

  @pragma('vm:entry-point')
  static void onStart(ServiceInstance service) async {
    DartPluginRegistrant.ensureInitialized();

    if (service is AndroidServiceInstance) {
      service.on('setAsForeground').listen((event) {
        service.setAsForegroundService();
      });

      service.on('setAsBackground').listen((event) {
        service.setAsBackgroundService();
      });
    }

    service.on('stopService').listen((event) {
      service.stopSelf();
    });

    Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (service is AndroidServiceInstance) {
        if (await service.isForegroundService()) {
          service.setForegroundNotificationInfo(
            title: "Jambo Service",
            content: "Service actif - ${DateTime.now()}",
          );
        }
      }

      // Envoi du statut aux clients
      service.invoke(
        'update',
        {
          'current_date': DateTime.now().toIso8601String(),
          'is_active': true,
        },
      );
    });
  }

  Future<void> startService() async {
    if (!_isRunning) {
      await _service.startService();
      _isRunning = true;
    }
  }

  Future<void> stopService() async {
    if (_isRunning) {
      await _service.invoke('stopService');
      _isRunning = false;
    }
  }

  Future<void> setForeground() async {
    await _service.invoke('setAsForeground');
  }

  Future<void> setBackground() async {
    await _service.invoke('setAsBackground');
  }

  Stream<Map<String, dynamic>> get onDataReceived {
    return _service.on('update');
  }

  bool get isRunning => _isRunning;
}
