import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../todo/providers/todo_providers.dart' show appDatabaseProvider;
import '../data/repositories/expense_repository_impl.dart';
import '../domain/entities/expense_entity.dart';
import '../domain/repositories/expense_repository.dart';

final expenseRepositoryProvider = Provider<IExpenseRepository>((ref) {
  return ExpenseRepositoryImpl(db: ref.watch(appDatabaseProvider));
});

final expenseListProvider = FutureProvider.autoDispose<List<ExpenseEntity>>((ref) async {
  return ref.watch(expenseRepositoryProvider).getAll();
});

class ExpenseActionsNotifier extends StateNotifier<AsyncValue<void>> {
  final IExpenseRepository _repository;
  final Ref _ref;
  ExpenseActionsNotifier(this._repository, this._ref) : super(const AsyncValue.data(null));

  Future<void> addExpense(ExpenseEntity expense) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.add(expense));
    _ref.invalidate(expenseListProvider);
  }

  Future<void> deleteExpense(int id) async {
    await _repository.delete(id);
    _ref.invalidate(expenseListProvider);
  }
}

final expenseActionsProvider = StateNotifierProvider<ExpenseActionsNotifier, AsyncValue<void>>((ref) {
  return ExpenseActionsNotifier(ref.watch(expenseRepositoryProvider), ref);
});