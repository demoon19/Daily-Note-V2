import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'tables/tables.dart'; // export semua tabel di core/database/tables/

part 'app_database.g.dart';

/// Satu instance Drift database dipakai lintas fitur.
/// Definisi tabel HANYA boleh ada di core/database/tables/ —
/// jangan duplikasi definisi tabel di dalam folder fitur.
@DriftDatabase(tables: [
  CalendarEvents,
  Todos,
  Notes,
  Expenses,
  Reminders,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'daily_note_db');
  }
}