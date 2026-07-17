import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/utils/date_utils.dart';
import '../../domain/entities/event_entity.dart';
import '../../domain/repositories/event_repository.dart';
import '../../../../core/ai/intent_router.dart' show CalendarRepository;
import '../../../../core/ai/intent_models.dart';

class EventRepositoryImpl implements IEventRepository, CalendarRepository {
  final AppDatabase _db;
  EventRepositoryImpl({required AppDatabase db}) : _db = db;

  @override
  Future<List<EventEntity>> getAll() async {
    final rows = await _db.select(_db.calendarEvents).get();
    return rows
        .map((r) => EventEntity(
              id: r.id,
              title: r.title,
              datetime: r.datetime,
              location: r.location,
              notes: r.notes,
            ))
        .toList();
  }

  @override
  Future<List<EventEntity>> getByDate(DateTime date) async {
    final start = AppDateUtils.startOfDay(date);
    final end = AppDateUtils.endOfDay(date);
    final rows = await (_db.select(_db.calendarEvents)
          ..where((t) => t.datetime.isBetweenValues(start, end)))
        .get();
    return rows
        .map((r) => EventEntity(id: r.id, title: r.title, datetime: r.datetime, location: r.location, notes: r.notes))
        .toList();
  }

  @override
  Future<int> add(EventEntity event) async {
    return _db.into(_db.calendarEvents).insert(
          CalendarEventsCompanion.insert(
            title: event.title,
            datetime: event.datetime,
            location: Value(event.location),
            notes: Value(event.notes),
          ),
        );
  }

  @override
  Future<void> delete(int id) async {
    await (_db.delete(_db.calendarEvents)..where((t) => t.id.equals(id))).go();
  }

  /// Dipanggil oleh IntentRouter. Mengembalikan id event baru agar
  /// bisa direlasikan oleh ReminderService (linked_intent_ref).
  @override
  Future<void> addEvent(IntentResult intent) async {
    await add(EventEntity(
      title: intent.title ?? 'Acara baru',
      datetime: intent.datetime ?? DateTime.now(),
      location: intent.location,
      notes: intent.notes,
    ));
  }
}