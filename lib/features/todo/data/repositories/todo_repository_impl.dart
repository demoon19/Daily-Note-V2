import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';
import '../../domain/entities/todo_entity.dart';
import '../../domain/repositories/todo_repository.dart';
import '../../../../core/notification/remindere_notification_service.dart';
import '../../../../core/ai/intent_router.dart' show TodoRepository;
import '../../../../core/ai/intent_models.dart';

/// Implementasi konkret memakai Drift (core/database/app_database.dart).
/// Class ini juga mengimplementasikan `TodoRepository` dari
/// core/ai/intent_router.dart supaya bisa dipanggil langsung
/// oleh IntentRouter (Fase 2), tanpa file duplikat.
class TodoRepositoryImpl implements ITodoRepository, TodoRepository {
  final AppDatabase _db;

  TodoRepositoryImpl({required AppDatabase db}) : _db = db;

  @override
  Future<List<TodoEntity>> getAll() async {
    final rows = await _db.select(_db.todos).get();
    return rows
        .map((row) => TodoEntity(
              id: row.id,
              title: row.title,
              isDone: row.isDone,
              dueDate: row.dueDate,
            ))
        .toList();
  }

  @override
  Future<void> add(TodoEntity todo) async {
    await _db.into(_db.todos).insert(
          TodosCompanion.insert(
            title: todo.title,
            isDone: Value(todo.isDone),
            dueDate: Value(todo.dueDate),
          ),
        );
        
    await ReminderNotificationService().showInstantNotification(
      id: DateTime.now().millisecondsSinceEpoch % 100000,
      title: 'Tugas Ditambahkan',
      body: todo.title,
    );
  }

  @override
  Future<void> update(TodoEntity todo) async {
    await (_db.update(_db.todos)..where((t) => t.id.equals(todo.id!))).write(
      TodosCompanion(
        title: Value(todo.title),
        isDone: Value(todo.isDone),
        dueDate: Value(todo.dueDate),
      ),
    );
  }

  @override
  Future<void> delete(int id) async {
    await (_db.delete(_db.todos)..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<void> toggleDone(int id, bool isDone) async {
    await (_db.update(_db.todos)..where((t) => t.id.equals(id)))
        .write(TodosCompanion(isDone: Value(isDone)));
  }

  /// Dipanggil oleh IntentRouter (Fase 2) — mengonversi IntentResult
  /// menjadi TodoEntity lalu menyimpannya lewat method add() yang sama.
  @override
  Future<void> addTask(IntentResult intent) async {
    await add(TodoEntity(
      title: intent.title ?? 'Tanpa judul',
      dueDate: intent.datetime,
    ));
  }
}