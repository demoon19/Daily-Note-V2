import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/utils/date_utils.dart';
import '../../domain/entities/event_entity.dart';
import '../../domain/repositories/event_repository.dart';
import '../../../../core/notification/remindere_notification_service.dart';
import '../../../../core/ai/intent_router.dart' show CalendarRepository;
import '../../../../core/ai/intent_models.dart';
import '../models/event_model.dart';
import '../../../../core/network/google_calendar_service.dart';

class EventRepositoryImpl implements IEventRepository, CalendarRepository {
  final AppDatabase _db;
  EventRepositoryImpl({required AppDatabase db}) : _db = db;

  @override
  Future<List<EventEntity>> getAll() async {
    final rows = await (_db.select(_db.calendarEvents)
          ..orderBy([(t) => OrderingTerm.asc(t.datetime)]))
        .get();
    return rows.map((r) => EventModel.fromDrift(r).toEntity()).toList();
  }

  @override
  Future<List<EventEntity>> getByDate(DateTime date) async {
    final start = AppDateUtils.startOfDay(date);
    final end = AppDateUtils.endOfDay(date);
    
    final exactRows = await (_db.select(_db.calendarEvents)
          ..where((t) => t.datetime.isBetweenValues(start, end)))
        .get();

    final recurringRows = await (_db.select(_db.calendarEvents)
          ..where((t) => t.recurrence.isNotNull() & t.datetime.isSmallerOrEqualValue(end)))
        .get();

    final allRows = <CalendarEvent>{};
    allRows.addAll(exactRows);

    for (final row in recurringRows) {
      if (row.recurrence == 'harian') {
        allRows.add(row);
      } else if (row.recurrence == 'bulanan' && row.datetime.day == date.day) {
        allRows.add(row);
      } else if (row.recurrence == 'tahunan' &&
          row.datetime.day == date.day &&
          row.datetime.month == date.month) {
        allRows.add(row);
      }
    }

    final events = allRows.map((r) {
      var entity = EventModel.fromDrift(r).toEntity();
      if (entity.recurrence != null) {
        entity = EventEntity(
          id: entity.id,
          title: entity.title,
          datetime: DateTime(
            date.year,
            date.month,
            date.day,
            entity.datetime.hour,
            entity.datetime.minute,
          ),
          location: entity.location,
          notes: entity.notes,
          recurrence: entity.recurrence,
        );
      }
      return entity;
    }).toList();

    events.sort((a, b) => a.datetime.compareTo(b.datetime));
    return events;
  }

  @override
  Future<int> add(EventEntity event) async {
    final model = EventModel.fromEntity(event);
    final id = await _db.into(_db.calendarEvents).insert(
          CalendarEventsCompanion.insert(
            title: model.title,
            datetime: model.datetime,
            location: Value(model.location),
            notes: Value(model.notes),
            recurrence: Value(model.recurrence),
          ),
        );

    await ReminderNotificationService().showInstantNotification(
      id: DateTime.now().millisecondsSinceEpoch % 100000,
      title: 'Jadwal Ditambahkan',
      body: event.title,
      payload: event.datetime.toIso8601String(),
    );
    
    // Auto-sync ke Google Calendar (tidak nge-blok UI karena berjalan asinkron)
    GoogleCalendarService().syncEventToGoogle(event);
    
    return id;
  }

  @override
  Future<void> delete(int id) async {
    final row = await (_db.select(_db.calendarEvents)..where((t) => t.id.equals(id))).getSingleOrNull();
    if (row != null) {
      final eventEntity = EventModel.fromDrift(row).toEntity();
      GoogleCalendarService().deleteEventFromGoogle(eventEntity);
    }
    await (_db.delete(_db.calendarEvents)..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<void> update(EventEntity event) async {
    final model = EventModel.fromEntity(event);
    await (_db.update(_db.calendarEvents)..where((t) => t.id.equals(model.id!))).write(
      CalendarEventsCompanion(
        title: Value(model.title),
        datetime: Value(model.datetime),
        location: Value(model.location),
        notes: Value(model.notes),
        recurrence: Value(model.recurrence),
      ),
    );
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

  @override
  Future<void> syncFromGoogle() async {
    final googleEvents = await GoogleCalendarService().fetchEventsFromGoogle(interactive: true);
    for (var gEvent in googleEvents) {
      bool isAllDay = gEvent.notes != null && gEvent.notes!.startsWith('__ALL_DAY__');
      
      if (isAllDay) {
        // Rute ke Todo
        final existingTodos = await (_db.select(_db.todos)
          ..where((t) => t.title.equals(gEvent.title)))
          .get();
          
        bool isDuplicate = existingTodos.any((e) {
          if (e.dueDate == null) return false;
          final diff = e.dueDate!.difference(gEvent.datetime).inMinutes.abs();
          return diff < 60;
        });
          
        if (!isDuplicate) {
          await _db.into(_db.todos).insert(
            TodosCompanion.insert(
              title: gEvent.title,
              isDone: const Value(false),
              dueDate: Value(gEvent.datetime),
            ),
          );
        }
      } else {
        // Rute normal ke Calendar
        final existing = await (_db.select(_db.calendarEvents)
          ..where((t) => t.title.equals(gEvent.title)))
          .get();
          
        bool isDuplicate = existing.any((e) {
          final diff = e.datetime.difference(gEvent.datetime).inMinutes.abs();
          return diff < 60;
        });
          
        if (!isDuplicate) {
          final model = EventModel.fromEntity(gEvent);
          await _db.into(_db.calendarEvents).insert(
            CalendarEventsCompanion.insert(
              title: model.title,
              datetime: model.datetime,
              location: Value(model.location),
              notes: Value(model.notes),
              recurrence: Value(model.recurrence),
            ),
          );
        }
      }
    }
  }
}