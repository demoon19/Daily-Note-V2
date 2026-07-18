class HomeSummaryEntity {
  final int totalEventsToday;
  final int totalPendingTodos;
  final int totalCompletedTodos;
  final double totalExpenseToday;
  final int totalUpcomingReminders;

  const HomeSummaryEntity({
    required this.totalEventsToday,
    required this.totalPendingTodos,
    required this.totalCompletedTodos,
    required this.totalExpenseToday,
    required this.totalUpcomingReminders,
  });

  factory HomeSummaryEntity.empty() => const HomeSummaryEntity(
        totalEventsToday: 0,
        totalPendingTodos: 0,
        totalCompletedTodos: 0,
        totalExpenseToday: 0,
        totalUpcomingReminders: 0,
      );
}