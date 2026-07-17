import '../entities/todo_entity.dart';

/// Interface domain — implementasi konkret ada di data/repositories/.
abstract class ITodoRepository {
  Future<List<TodoEntity>> getAll();
  Future<void> add(TodoEntity todo);
  Future<void> update(TodoEntity todo);
  Future<void> delete(int id);
  Future<void> toggleDone(int id, bool isDone);
}