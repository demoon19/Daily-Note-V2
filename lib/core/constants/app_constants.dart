/// Konstanta global dipakai lintas fitur — jangan hardcode
/// magic number/string di widget atau service.
class AppConstants {
  AppConstants._();

  static const String appName = 'Daily Note';

  // Default reminder offset (menit) sesuai kontrak JSON LLM (bagian 4.3)
  static const int defaultReminderOffsetMinutes = 30;

  // Database
  static const String databaseName = 'daily_note_db';

  // Local notification channel
  static const String reminderChannelId = 'reminder_channel';
  static const String reminderChannelName = 'Reminder';

  // Email polling fallback interval (bagian 5)
  static const Duration emailPollingInterval = Duration(minutes: 15);

  // Batas retry LLM sebelum minta klarifikasi ke user
  static const int maxLlmRetryAttempts = 2;

  // Intent type valid (harus sinkron dengan intent_models.dart)
  static const List<String> validIntentTypes = [
    'calendar',
    'todo',
    'note',
    'expense',
    'reminder',
    'chat',
  ];
}