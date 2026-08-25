import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
    );

    try {
      await _notificationsPlugin.initialize(initSettings);
    } catch (e) {
      // Graceful fallback if platform is not Android or desktop runner
    }
  }

  static Future<void> showTaskNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'task_reminders_channel',
      'Task Reminders',
      channelDescription: 'Notifications for scheduled college tasks and deadlines',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    try {
      await _notificationsPlugin.show(id, title, body, details);
    } catch (e) {
      // Notification plugin fallback
    }
  }

  static Future<void> showTimerAlarmNotification({
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'focus_alarm_channel_v2',
      'Focus Alarm Notifications',
      channelDescription: 'Ringing alarms when focus timers complete',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    try {
      await _notificationsPlugin.show(999, title, body, details);
    } catch (e) {
      // Notification plugin fallback
    }
  }
}
