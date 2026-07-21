import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'tabels/tabels.dart'; // export semua tabel di core/database/tabels/

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
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 3) {
          await m.addColumn(calendarEvents, calendarEvents.recurrence);
        }
        await m.createAll();
      },
      beforeOpen: (details) async {
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'daily_note_db');
  }
}
