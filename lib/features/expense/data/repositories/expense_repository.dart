import '../../domain/entities/expense_entity.dart';

abstract class IExpenseRepository {
  Future<List<ExpenseEntity>> getAll();
  Future<void> add(ExpenseEntity expense);
  Future<void> delete(int id);
  Future<double> getTotalByRange(DateTime start, DateTime end);
}
