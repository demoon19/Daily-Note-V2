import 'daily_summary_entity.dart';

class WeeklySummaryEntity {
  final DateTime rangeStart;
  final DateTime rangeEnd;
  final List<DailySummaryEntity> dailyBreakdown;
  final double totalExpense;
  final int totalTodosCompleted;
  final int totalEvents;

  const WeeklySummaryEntity({
    required this.rangeStart,
    required this.rangeEnd,
    required this.dailyBreakdown,
    required this.totalExpense,
    required this.totalTodosCompleted,
    required this.totalEvents,
  });

  double get averageExpensePerDay =>
      dailyBreakdown.isEmpty ? 0 : totalExpense / dailyBreakdown.length;
}