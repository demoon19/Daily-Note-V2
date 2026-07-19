import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../calendar/providers/calendar_providers.dart'
    show eventRepositoryProvider;
import '../../../todo/providers/todo_providers.dart'
    show todoRepositoryProvider;
import '../../../expense/providers/expense_providers.dart'
    show expenseRepositoryProvider;
import '../../../notes/providers/notes_providers.dart'
    show notesRepositoryProvider;
import '../../../reminder/providers/reminder_providers.dart'
    show reminderRepositoryProvider;
import '../../data/repositories/summary_repository_impl.dart';
import '../../domain/entities/daily_summary_entity.dart';
import '../../domain/repositories/summary_repository.dart';

final summaryRepositoryProvider = Provider<ISummaryRepository>((ref) {
  return SummaryRepositoryImpl(
    eventRepository: ref.watch(eventRepositoryProvider),
    todoRepository: ref.watch(todoRepositoryProvider),
    expenseRepository: ref.watch(expenseRepositoryProvider),
    notesRepository: ref.watch(notesRepositoryProvider),
    reminderRepository: ref.watch(reminderRepositoryProvider),
  );
});

final selectedSummaryDateProvider =
    StateProvider<DateTime>((ref) => DateTime.now());

final dailySummaryProvider =
    FutureProvider.autoDispose<DailySummaryEntity>((ref) async {
  final date = ref.watch(selectedSummaryDateProvider);
  return ref.watch(summaryRepositoryProvider).getDailySummary(date);
});
