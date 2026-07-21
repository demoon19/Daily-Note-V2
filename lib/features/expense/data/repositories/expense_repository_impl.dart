import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';
import '../../domain/entities/expense_entity.dart';
import 'expense_repository.dart';
import '../../../../core/notification/remindere_notification_service.dart';
import '../../../../core/ai/intent_router.dart' show ExpenseRepository;
import '../../../../core/ai/intent_models.dart';

class ExpenseRepositoryImpl implements IExpenseRepository, ExpenseRepository {
  final AppDatabase _db;
  ExpenseRepositoryImpl({required AppDatabase db}) : _db = db;

  @override
  Future<List<ExpenseEntity>> getAll() async {
    final rows = await _db.select(_db.expenses).get();
    return rows
        .map((r) => ExpenseEntity(
              id: r.id,
              title: r.title,
              amount: r.amount,
              category: r.category,
              datetime: r.datetime,
            ))
        .toList();
  }

  @override
  Future<void> add(ExpenseEntity expense) async {
    await _db.into(_db.expenses).insert(
          ExpensesCompanion.insert(
            title: expense.title,
            amount: expense.amount,
            category: Value(expense.category),
            datetime: expense.datetime,
          ),
        );
        
    await ReminderNotificationService().showInstantNotification(
      id: DateTime.now().millisecondsSinceEpoch % 100000,
      title: 'Pengeluaran Dicatat',
      body: '${expense.title} - Rp${expense.amount.toInt()}',
    );
  }

  @override
  Future<void> delete(int id) async {
    await (_db.delete(_db.expenses)..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<double> getTotalByRange(DateTime start, DateTime end) async {
    final rows = await (_db.select(_db.expenses)
          ..where((t) => t.datetime.isBetweenValues(start, end)))
        .get();
    return rows.fold<double>(0, (sum, r) => sum + r.amount);
  }

  @override
  Future<void> addExpense(IntentResult intent) async {
    await add(ExpenseEntity(
      title: intent.title ?? 'Pengeluaran',
      amount: intent.amount ?? 0,
      category: intent.category,
      datetime: intent.datetime ?? DateTime.now(),
    ));
  }
}
