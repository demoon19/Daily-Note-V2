class DailySummaryEntity {
  final DateTime date;
  final int totalEvents;
  final int totalTodosCompleted;
  final int totalTodosPending;
  final double totalExpense;
  final int totalNotes;
  final int totalRemindersTriggered;

  const DailySummaryEntity({
    required this.date,
    required this.totalEvents,
    required this.totalTodosCompleted,
    required this.totalTodosPending,
    required this.totalExpense,
    required this.totalNotes,
    required this.totalRemindersTriggered,
  });
}