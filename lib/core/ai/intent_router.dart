import 'intent_models.dart';

/// Kontrak minimal yang harus diimplementasikan tiap repository
/// fitur agar bisa "berlangganan" hasil intent parsing.
/// Implementasi konkret ada di masing-masing folder
/// features/<fitur>/data/repositories/.
abstract class CalendarRepository {
  Future<void> addEvent(IntentResult intent);
}

abstract class TodoRepository {
  Future<void> addTask(IntentResult intent);
}

abstract class NotesRepository {
  Future<void> addNote(IntentResult intent);
}

abstract class ExpenseRepository {
  Future<void> addExpense(IntentResult intent);
}

abstract class ReminderService {
  Future<void> schedule(IntentResult intent, {int? linkedEventId});
}

typedef ChatReplyHandler = void Function(String message);

/// Mendistribusikan setiap IntentResult ke modul terkait.
/// Tidak boleh ada fitur yang memanggil LLM langsung — semua
/// lewat router ini setelah IntentParserService selesai parsing.
class IntentRouter {
  final CalendarRepository calendarRepository;
  final TodoRepository todoRepository;
  final NotesRepository notesRepository;
  final ExpenseRepository expenseRepository;
  final ReminderService reminderService;
  final ChatReplyHandler onChatReply;

  IntentRouter({
    required this.calendarRepository,
    required this.todoRepository,
    required this.notesRepository,
    required this.expenseRepository,
    required this.reminderService,
    required this.onChatReply,
  });

  Future<void> route(IntentParseResponse response) async {
    for (final intent in response.intents) {
      switch (intent.type) {
        case IntentType.calendar:
          await calendarRepository.addEvent(intent);
          break;
        case IntentType.todo:
          await todoRepository.addTask(intent);
          break;
        case IntentType.note:
          await notesRepository.addNote(intent);
          break;
        case IntentType.expense:
          await expenseRepository.addExpense(intent);
          break;
        case IntentType.reminder:
          await reminderService.schedule(
            intent,
            linkedEventId: intent.linkedIntentRef,
          );
          break;
        case IntentType.chat:
          onChatReply(intent.notes ?? '');
          break;
      }
    }
  }
}