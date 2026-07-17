import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/app_database.dart';
import '../data/repositories/todo_repository_impl.dart';
import '../domain/entities/todo_entity.dart';
import '../domain/repositories/todo_repository.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) => AppDatabase());

final todoRepositoryProvider = Provider<ITodoRepository>((ref) {
  return TodoRepositoryImpl(db: ref.watch(appDatabaseProvider));
});

final todoListProvider =
    FutureProvider.autoDispose<List<TodoEntity>>((ref) async {
  final repo = ref.watch(todoRepositoryProvider);
  return repo.getAll();
});

class TodoActionsNotifier extends StateNotifier<AsyncValue<void>> {
  final ITodoRepository _repository;
  final Ref _ref;

  TodoActionsNotifier(this._repository, this._ref)
      : super(const AsyncValue.data(null));

  Future<void> addTodo(TodoEntity todo) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.add(todo));
    _ref.invalidate(todoListProvider);
  }

  Future<void> toggleDone(int id, bool isDone) async {
    await _repository.toggleDone(id, isDone);
    _ref.invalidate(todoListProvider);
  }

  Future<void> deleteTodo(int id) async {
    await _repository.delete(id);
    _ref.invalidate(todoListProvider);
  }
}

final todoActionsProvider =
    StateNotifierProvider<TodoActionsNotifier, AsyncValue<void>>((ref) {
  return TodoActionsNotifier(ref.watch(todoRepositoryProvider), ref);
});