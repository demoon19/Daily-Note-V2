import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Reminder terhubung ke Calendar/Todo lewat relasi ID
/// (linked_intent_ref / linkedEventId), BUKAN duplikasi data.
/// Tidak butuh server sama sekali (flutter_local_notifications).
class ReminderNotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init({void Function(String?)? onNotificationClick}) async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        if (onNotificationClick != null) {
          onNotificationClick(response.payload);
        }
      },
    );

    final androidImplementation =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidImplementation?.requestNotificationsPermission();
    await androidImplementation?.requestExactAlarmsPermission();
  }

  Future<void> scheduleReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    int? linkedEventId,
  }) async {
    // TODO: gunakan zonedSchedule dengan timezone package untuk
    // akurasi zona waktu perangkat.
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      _toTZDateTime(scheduledTime),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'reminder_channel',
          'Reminder',
          channelDescription: 'Notifikasi reminder Daily Note',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: linkedEventId?.toString(),
    );
  }

  Future<void> cancelReminder(int id) async {
    await _plugin.cancel(id);
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final isNotificationEnabled = prefs.getBool('settings_notification_enabled') ?? true;
    if (!isNotificationEnabled) return;

    await _plugin.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'instant_channel',
          'Info',
          channelDescription: 'Notifikasi info instan Daily Note',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: payload,
    );
  }

  dynamic _toTZDateTime(DateTime dateTime) {
    // TODO: ganti dengan TZDateTime dari package `timezone`
    // setelah timezone.initializeTimeZones() dipanggil di main.dart.
    return dateTime;
  }
}