import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/ai/intent_models.dart';
import '../../../core/ai/providers/llm_providers.dart';
import '../../../core/ai/providers/intent_router_provider.dart';
import '../../../core/ai/intent_router.dart';
import '../../../core/utils/logger.dart';
import '../domain/entities/chat_message_entity.dart';
import '../../calendar/providers/calendar_providers.dart';
import '../../todo/providers/todo_providers.dart';
import '../../expense/providers/expense_providers.dart';
import '../../home/providers/home_providers.dart';
import '../../summary/providers/summary_providers.dart';

const _uuid = Uuid();

/// State list pesan chat, ditampilkan di chat_screen.dart.
final chatMessagesProvider =
    StateNotifierProvider<ChatMessagesNotifier, List<ChatMessageEntity>>(
        (ref) => ChatMessagesNotifier(ref));

class ChatMessagesNotifier extends StateNotifier<List<ChatMessageEntity>> {
  final Ref _ref;
  ChatMessagesNotifier(this._ref) : super([]);

  /// Alur utama chat: user input -> IntentParserService.parse()
  /// -> IntentRouter.route() -> tampilkan hasil/balasan di chat.
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMessage = ChatMessageEntity(
      id: _uuid.v4(),
      text: text,
      sender: ChatSender.user,
      timestamp: DateTime.now(),
    );

    final loadingMessage = ChatMessageEntity(
      id: _uuid.v4(),
      text: '',
      sender: ChatSender.assistant,
      timestamp: DateTime.now(),
      isLoading: true,
    );

    state = [...state, userMessage, loadingMessage];

    try {
      AppLogger.logIntentFlow('parsing_started', detail: text);

      final parserService = _ref.read(intentParserServiceProvider);
      final response = await parserService.parse(text, source: 'text');

      AppLogger.logIntentFlow('parsing_done',
          detail: '${response.intents.length} intent(s)');

      // Buat router baru dengan onChatReply diarahkan ke state chat ini,
      // memakai repository konkret yang sama dari intentRouterProvider.
      final baseRouter = _ref.read(intentRouterProvider);
      final router = IntentRouter(
        calendarRepository: baseRouter.calendarRepository,
        todoRepository: baseRouter.todoRepository,
        notesRepository: baseRouter.notesRepository,
        expenseRepository: baseRouter.expenseRepository,
        reminderService: baseRouter.reminderService,
        onChatReply: (message) => _appendAssistantReply(message),
      );

      await router.route(response);

      // Invalidate UI providers so screens refresh immediately
      _ref.invalidate(eventListProvider);
      _ref.invalidate(eventsByDateProvider);
      _ref.invalidate(todoListProvider);
      _ref.invalidate(expenseListProvider);
      _ref.invalidate(homeSummaryProvider);
      _ref.invalidate(weeklySummaryProvider);

      // Jika bukan tipe chat murni (ada intent actionable yang tersimpan),
      // beri konfirmasi ringkas ke user.
      final hasActionable =
          response.intents.any((i) => i.type != IntentType.chat);
      if (hasActionable) {
        _replaceLoadingWith(
          _summarizeActions(response.intents),
        );
      } else {
        // onChatReply sudah mengisi balasan lewat _appendAssistantReply
        _removeLoadingIfStillPresent();
      }
    } catch (e, st) {
      AppLogger.error('Gagal memproses pesan', error: e, stackTrace: st);
      _replaceLoadingWith(
        'Maaf, terjadi kesalahan saat memproses pesanmu. Coba lagi ya.',
      );
    }
  }

  void _appendAssistantReply(String message) {
    _replaceLoadingWith(message);
  }

  void _replaceLoadingWith(String message) {
    final index = state.indexWhere((m) => m.isLoading);
    if (index == -1) {
      state = [
        ...state,
        ChatMessageEntity(
          id: _uuid.v4(),
          text: message,
          sender: ChatSender.assistant,
          timestamp: DateTime.now(),
        ),
      ];
      return;
    }
    final updated = [...state];
    updated[index] = updated[index].copyWith(text: message, isLoading: false);
    state = updated;
  }

  void _removeLoadingIfStillPresent() {
    final stillLoading = state.any((m) => m.isLoading);
    if (stillLoading) {
      state = state.where((m) => !m.isLoading).toList();
    }
  }

  String _summarizeActions(List<IntentResult> intents) {
    final actionable = intents.where((i) => i.type != IntentType.chat);
    final labels = actionable.map((i) {
      switch (i.type) {
        case IntentType.calendar:
          return 'menambahkan jadwal "${i.title}"';
        case IntentType.todo:
          return 'menambahkan tugas "${i.title}"';
        case IntentType.note:
          return 'menyimpan catatan "${i.title}"';
        case IntentType.expense:
          return 'mencatat pengeluaran "${i.title}"';
        case IntentType.reminder:
          return 'mengatur pengingat "${i.title}"';
        case IntentType.chat:
          return '';
      }
    }).where((s) => s.isNotEmpty);

    return 'Oke, aku sudah ${labels.join(', ')}.';
  }
}