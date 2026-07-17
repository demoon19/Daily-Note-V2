import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Reminder terhubung ke Calendar/Todo lewat relasi ID
/// (linked_intent_ref / linkedEventId), BUKAN duplikasi data.
/// Tidak butuh server sama sekali (flutter_local_notifications).
class ReminderNotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _plugin.initialize(initSettings);
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

  dynamic _toTZDateTime(DateTime dateTime) {
    // TODO: ganti dengan TZDateTime dari package `timezone`
    // setelah timezone.initializeTimeZones() dipanggil di main.dart.
    return dateTime;
  }
}