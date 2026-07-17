import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/notification/reminder_notification_service.dart';
import '../../../../core/constants/app_constants.dart';
import '../entities/reminder_entity.dart';
import 'reminder_repository.dart';
import '../../../../core/ai/intent_router.dart' show ReminderService;
import '../../../../core/ai/intent_models.dart';

/// Class ini mengimplementasikan `ReminderService` dari intent_router.dart
/// (nama beda dengan `ReminderNotificationService` di core — yang satu
/// menangani jadwal push notif lokal, yang ini menangani penyimpanan
/// data reminder + orkestrasi dengan notification service).
class ReminderRepositoryImpl implements IReminderRepository, ReminderService {
  final AppDatabase _db;
  final ReminderNotificationService _notificationService;

  ReminderRepositoryImpl({
    required AppDatabase db,
    required ReminderNotificationService notificationService,
  })  : _db = db,
        _notificationService = notificationService;

  @override
  Future<List<ReminderEntity>> getAll() async {
    final rows = await _db.select(_db.reminders).get();
    return rows
        .map((r) => ReminderEntity(
              id: r.id,
              title: r.title,
              triggerAt: r.triggerAt,
              linkedEventId: r.linkedEventId,
            ))
        .toList();
  }

  @override
  Future<void> add(ReminderEntity reminder) async {
    final id = await _db.into(_db.reminders).insert(
          RemindersCompanion.insert(
            title: reminder.title,
            triggerAt: reminder.triggerAt,
            linkedEventId: Value(reminder.linkedEventId),
          ),
        );
    await _notificationService.scheduleReminder(
      id: id,
      title: reminder.title,
      body: 'Pengingat: ${reminder.title}',
      scheduledTime: reminder.triggerAt,
      linkedEventId: reminder.linkedEventId,
    );
  }

  @override
  Future<void> delete(int id) async {
    await (_db.delete(_db.reminders)..where((t) => t.id.equals(id))).go();
    await _notificationService.cancelReminder(id);
  }

  /// Dipanggil oleh IntentRouter. [linkedEventId] didapat dari
  /// intent.linked_intent_ref yang sudah di-resolve ke id event asli
  /// oleh IntentRouter sebelum memanggil method ini.
  @override
  Future<void> schedule(IntentResult intent, {int? linkedEventId}) async {
    final offsetMinutes =
        intent.triggerOffsetMinutes ?? AppConstants.defaultReminderOffsetMinutes;
    final baseTime = intent.datetime ?? DateTime.now();
    final triggerAt = baseTime.subtract(Duration(minutes: offsetMinutes));

    await add(ReminderEntity(
      title: intent.title ?? 'Pengingat',
      triggerAt: triggerAt,
      linkedEventId: linkedEventId,
    ));
  }
}