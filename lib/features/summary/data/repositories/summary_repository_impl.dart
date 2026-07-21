import '../../../calendar/domain/repositories/event_repository.dart';
import '../../../todo/domain/repositories/todo_repository.dart';
import '../../../expense/data/repositories/expense_repository.dart';
import '../../../notes/data/repositories/notes_repository.dart';
import '../../../reminder/domain/repositories/reminder_repository.dart';
import '../../../../core/utils/date_utils.dart';
import '../../domain/entities/daily_summary_entity.dart';
import '../../domain/entities/weekly_summary_entity.dart';
import '../../domain/repositories/summary_repository.dart';

class SummaryRepositoryImpl implements ISummaryRepository {
  final IEventRepository _eventRepository;
  final ITodoRepository _todoRepository;
  final IExpenseRepository _expenseRepository;
  final INotesRepository _notesRepository;
  final IReminderRepository _reminderRepository;

  SummaryRepositoryImpl({
    required IEventRepository eventRepository,
    required ITodoRepository todoRepository,
    required IExpenseRepository expenseRepository,
    required INotesRepository notesRepository,
    required IReminderRepository reminderRepository,
  })  : _eventRepository = eventRepository,
        _todoRepository = todoRepository,
        _expenseRepository = expenseRepository,
        _notesRepository = notesRepository,
        _reminderRepository = reminderRepository;

  @override
  Future<DailySummaryEntity> getDailySummary(DateTime date) async {
    final events = await _eventRepository.getByDate(date);
    final todos = await _todoRepository.getAll();
    final notes = await _notesRepository.getAll();
    final reminders = await _reminderRepository.getAll();
    final expenseTotal = await _expenseRepository.getTotalByRange(
      AppDateUtils.startOfDay(date),
      AppDateUtils.endOfDay(date),
    );

    final notesToday = notes.where((n) =>
        n.createdAt != null && AppDateUtils.isSameDay(n.createdAt!, date));

    final remindersTriggeredToday = reminders.where((r) =>
        AppDateUtils.isSameDay(r.triggerAt, date) &&
        r.triggerAt.isBefore(DateTime.now()));

    final todosToday = todos.where((t) =>
        t.dueDate != null && AppDateUtils.isSameDay(t.dueDate!, date));

    return DailySummaryEntity(
      date: date,
      totalEvents: events.length,
      totalTodosCompleted: todosToday.where((t) => t.isDone).length,
      totalTodosPending: todosToday.where((t) => !t.isDone).length,
      totalExpense: expenseTotal,
      totalNotes: notesToday.length,
      totalRemindersTriggered: remindersTriggeredToday.length,
    );
  }

  @override
  Future<WeeklySummaryEntity> getWeeklySummary({DateTime? reference}) async {
    final range = AppDateUtils.lastSevenDaysRange(reference: reference);

    final dailyBreakdown = <DailySummaryEntity>[];
    for (int i = 0; i < 7; i++) {
      final day = range.start.add(Duration(days: i));
      if (day.isAfter(range.end)) break;
      dailyBreakdown.add(await getDailySummary(day));
    }

    final totalExpense =
        dailyBreakdown.fold<double>(0, (sum, d) => sum + d.totalExpense);
    final totalTodosCompleted =
        dailyBreakdown.fold<int>(0, (sum, d) => sum + d.totalTodosCompleted);
    final totalEvents =
        dailyBreakdown.fold<int>(0, (sum, d) => sum + d.totalEvents);

    return WeeklySummaryEntity(
      rangeStart: range.start,
      rangeEnd: range.end,
      dailyBreakdown: dailyBreakdown,
      totalExpense: totalExpense,
      totalTodosCompleted: totalTodosCompleted,
      totalEvents: totalEvents,
    );
  }
}