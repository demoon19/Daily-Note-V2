import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../intent_router.dart';
import '../../../features/todo/data/repositories/todo_repository_impl.dart';
import '../../../features/notes/data/repositories/notes_repository_impl.dart';
import '../../../features/expense/data/repositories/expense_repository.dart';
import '../../../features/calendar/data/repositories/event_repository_impl.dart';
import '../../../features/reminder/data/repositories/reminder_repository_impl.dart';
import '../../../features/todo/providers/todo_providers.dart' show appDatabaseProvider;
import '../../../features/reminder/providers/reminder_providers.dart'
    show reminderNotificationServiceProvider;

/// Provider khusus yang expose implementasi konkret (bukan interface
/// ITodoRepository dsb) sehingga bisa langsung dipakai sebagai
/// TodoRepository/CalendarRepository/dst tanpa cast.
final todoRepoConcreteProvider = Provider<TodoRepositoryImpl>((ref) {
  return TodoRepositoryImpl(db: ref.watch(appDatabaseProvider));
});

final notesRepoConcreteProvider = Provider<NotesRepositoryImpl>((ref) {
  return NotesRepositoryImpl(db: ref.watch(appDatabaseProvider));
});

final expenseRepoConcreteProvider = Provider<ExpenseRepositoryImpl>((ref) {
  return ExpenseRepositoryImpl(db: ref.watch(appDatabaseProvider));
});

final eventRepoConcreteProvider = Provider<EventRepositoryImpl>((ref) {
  return EventRepositoryImpl(db: ref.watch(appDatabaseProvider));
});

final reminderRepoConcreteProvider = Provider<ReminderRepositoryImpl>((ref) {
  return ReminderRepositoryImpl(
    db: ref.watch(appDatabaseProvider),
    notificationService: ref.watch(reminderNotificationServiceProvider),
  );
});

/// Router siap pakai. onChatReply default no-op — chat_providers.dart
/// membuat instance IntentRouter baru dari repository yang sama
/// (lihat features/chat_assistant/providers/chat_providers.dart)
/// untuk mengarahkan callback ke state chat spesifik.
final intentRouterProvider = Provider<IntentRouter>((ref) {
  return IntentRouter(
    calendarRepository: ref.watch(eventRepoConcreteProvider),
    todoRepository: ref.watch(todoRepoConcreteProvider),
    notesRepository: ref.watch(notesRepoConcreteProvider),
    expenseRepository: ref.watch(expenseRepoConcreteProvider),
    reminderService: ref.watch(reminderRepoConcreteProvider),
    onChatReply: (_) {},
  );
});