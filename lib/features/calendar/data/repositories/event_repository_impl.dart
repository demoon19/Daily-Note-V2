import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/utils/date_utils.dart';
import '../../domain/entities/event_entity.dart';
import '../../domain/repositories/event_repository.dart';
import '../../../../core/ai/intent_router.dart' show CalendarRepository;
import '../../../../core/ai/intent_models.dart';
import '../models/event_model.dart';

class EventRepositoryImpl implements IEventRepository, CalendarRepository {
  final AppDatabase _db;
  EventRepositoryImpl({required AppDatabase db}) : _db = db;

  @override
  Future<List<EventEntity>> getAll() async {
    final rows = await _db.select(_db.calendarEvents).get();
    return rows.map((r) => EventModel.fromDrift(r).toEntity()).toList();
  }

  @override
  Future<List<EventEntity>> getByDate(DateTime date) async {
    final start = AppDateUtils.startOfDay(date);
    final end = AppDateUtils.endOfDay(date);
    final rows = await (_db.select(_db.calendarEvents)
          ..where((t) => t.datetime.isBetweenValues(start, end)))
        .get();
    return rows.map((r) => EventModel.fromDrift(r).toEntity()).toList();
  }

  @override
  Future<int> add(EventEntity event) async {
    final model = EventModel.fromEntity(event);
    return _db.into(_db.calendarEvents).insert(
          CalendarEventsCompanion.insert(
            title: model.title,
            datetime: model.datetime,
            location: Value(model.location),
            notes: Value(model.notes),
          ),
        );
  }

  @override
  Future<void> delete(int id) async {
    await (_db.delete(_db.calendarEvents)..where((t) => t.id.equals(id))).go();
  }

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