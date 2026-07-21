import 'package:drift/drift.dart' as drift;
import '../../../../core/database/app_database.dart';
import '../../domain/entities/event_entity.dart';

/// Data model — jembatan antara row Drift (CalendarEvent) dan
/// EventEntity di domain layer. Semua konversi format (row <-> entity,
/// json <-> entity) WAJIB lewat model ini, bukan langsung di repository.
class EventModel {
  final int? id;
  final String title;
  final DateTime datetime;
  final String? location;
  final String? notes;
  final String? recurrence;

  const EventModel({
    this.id,
    required this.title,
    required this.datetime,
    this.location,
    this.notes,
    this.recurrence,
  });

  /// Konversi dari row Drift hasil query.
  factory EventModel.fromDrift(CalendarEvent row) {
    return EventModel(
      id: row.id,
      title: row.title,
      datetime: row.datetime,
      location: row.location,
      notes: row.notes,
      recurrence: row.recurrence,
    );
  }

  /// Konversi ke Companion untuk insert/update ke Drift.
  CalendarEventsCompanion toCompanion() {
    return CalendarEventsCompanion.insert(
      title: title,
      datetime: datetime,
      location: drift.Value(location),
      notes: drift.Value(notes),
      recurrence: drift.Value(recurrence),
    );
  }

  /// Konversi ke domain entity — dipakai repository sebelum
  /// dikembalikan ke provider/UI layer.
  EventEntity toEntity() {
    return EventEntity(
      id: id,
      title: title,
      datetime: datetime,
      location: location,
      notes: notes,
      recurrence: recurrence,
    );
  }

  /// Konversi dari domain entity — dipakai repository saat
  /// menerima data dari UI/IntentRouter sebelum disimpan.
  factory EventModel.fromEntity(EventEntity entity) {
    return EventModel(
      id: entity.id,
      title: entity.title,
      datetime: entity.datetime,
      location: entity.location,
      notes: entity.notes,
      recurrence: entity.recurrence,
    );
  }

  /// Opsional: dipakai jika event di-serialize ke JSON
  /// (mis. untuk debugging/log atau nanti sync ke cloud DB).
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'datetime': datetime.toIso8601String(),
        'location': location,
        'notes': notes,
        'recurrence': recurrence,
      };

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] as int?,
      title: json['title'] as String,
      datetime: DateTime.parse(json['datetime'] as String),
      location: json['location'] as String?,
      notes: json['notes'] as String?,
      recurrence: json['recurrence'] as String?,
    );
  }
}