import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static int _notificationId = 0;

  static Future<void> initialize() async {
    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );

    await _notifications.initialize(
      settings: initializationSettings,
    );
  }

  static Future<void> requestPermission() async {
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.requestNotificationsPermission();
  }

  static Future<void> sendPhaseNotification(bool isRun) async {
    final title = isRun ? 'RUN NOW' : 'WALK NOW';

    const androidDetails = AndroidNotificationDetails(
      'run_walk_channel',
      'Run-Walk Alerts',
      channelDescription: 'Alerts for run and walk intervals',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
    );

    await _notifications.show(
      id: _notificationId++,
      title: title,
      body: isRun ? 'Time to run!' : 'Time to walk!',
      notificationDetails: details,
    );
  }
}
