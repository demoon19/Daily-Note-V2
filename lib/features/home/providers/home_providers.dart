import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../calendar/providers/calendar_providers.dart' show eventRepositoryProvider;
import '../../todo/providers/todo_providers.dart' show todoRepositoryProvider;
import '../../expense/providers/expense_providers.dart' show expenseRepositoryProvider;
import '../../reminder/providers/reminder_providers.dart' show reminderRepositoryProvider;
import '../data/repositories/home_repository_impl.dart';
import '../domain/entities/home_summary_entity.dart';
import '../domain/repositories/home_repository.dart';

final homeRepositoryProvider = Provider<IHomeRepository>((ref) {
  return HomeRepositoryImpl(
    eventRepository: ref.watch(eventRepositoryProvider),
    todoRepository: ref.watch(todoRepositoryProvider),
    expenseRepository: ref.watch(expenseRepositoryProvider),
    reminderRepository: ref.watch(reminderRepositoryProvider),
  );
});

final homeSummaryProvider =
    FutureProvider.autoDispose<HomeSummaryEntity>((ref) async {
  return ref.watch(homeRepositoryProvider).getTodaySummary();
});