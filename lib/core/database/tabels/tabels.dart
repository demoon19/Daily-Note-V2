import 'package:drift/drift.dart';

class CalendarEvents extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  DateTimeColumn get datetime => dateTime()();
  TextColumn get location => text().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get recurrence => text().nullable()(); // 'daily', 'monthly', 'yearly'
}

class Todos extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  BoolColumn get isDone => boolean().withDefault(const Constant(false))();
  DateTimeColumn get dueDate => dateTime().nullable()();
}

class Notes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get content => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class Expenses extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  RealColumn get amount => real()();
  TextColumn get category => text().nullable()();
  DateTimeColumn get datetime => dateTime()();
}

class Reminders extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  DateTimeColumn get triggerAt => dateTime()();
  IntColumn get linkedEventId => integer().nullable()();
}

class ChatMessages extends Table {
  TextColumn get id => text()();
  TextColumn get textContent => text()();
  IntColumn get sender => integer()(); // 0 for user, 1 for assistant
  DateTimeColumn get timestamp => dateTime()();
  TextColumn get intentsJson => text().nullable()(); // To store IntentResult list if any
  
  @override
  Set<Column> get primaryKey => {id};
}