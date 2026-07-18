import '../../../calendar/domain/repositories/event_repository.dart';
import '../../../todo/domain/repositories/todo_repository.dart';
import '../../../expense/data/repositories/expense_repository.dart';
import '../../../reminder/domain/repositories/reminder_repository.dart';
import '../../../../core/utils/date_utils.dart';
import '../../domain/entities/home_summary_entity.dart';
import '../../domain/repositories/home_repository.dart';

class HomeRepositoryImpl implements IHomeRepository {
  final IEventRepository _eventRepository;
  final ITodoRepository _todoRepository;
  final IExpenseRepository _expenseRepository;
  final IReminderRepository _reminderRepository;

  HomeRepositoryImpl({
    required IEventRepository eventRepository,
    required ITodoRepository todoRepository,
    required IExpenseRepository expenseRepository,
    required IReminderRepository reminderRepository,
  })  : _eventRepository = eventRepository,
        _todoRepository = todoRepository,
        _expenseRepository = expenseRepository,
        _reminderRepository = reminderRepository;

  @override
  Future<HomeSummaryEntity> getTodaySummary() async {
    final now = DateTime.now();

    final events = await _eventRepository.getByDate(now);
    final todos = await _todoRepository.getAll();
    final reminders = await _reminderRepository.getAll();
    final totalExpenseToday = await _expenseRepository.getTotalByRange(
      AppDateUtils.startOfDay(now),
      AppDateUtils.endOfDay(now),
    );

    final upcomingReminders = reminders.where((r) => r.triggerAt.isAfter(now));

    return HomeSummaryEntity(
      totalEventsToday: events.length,
      totalPendingTodos: todos.where((t) => !t.isDone).length,
      totalCompletedTodos: todos.where((t) => t.isDone).length,
      totalExpenseToday: totalExpenseToday,
      totalUpcomingReminders: upcomingReminders.length,
    );
  }
}