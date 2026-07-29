import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' hide Column;
import '../../../core/ai/intent_models.dart';
import '../../../core/ai/providers/llm_providers.dart';
import '../../../core/ai/providers/intent_router_provider.dart';
import '../../../core/ai/intent_router.dart';
import '../../../core/utils/logger.dart';
import '../../../core/database/app_database.dart';
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
  ChatMessagesNotifier(this._ref) : super([]) {
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    final db = _ref.read(appDatabaseProvider);
    final messages = await (db.select(db.chatMessages)
          ..orderBy([(t) => OrderingTerm(expression: t.timestamp, mode: OrderingMode.asc)]))
        .get();
    
    if (messages.isEmpty) {
      final welcome = ChatMessageEntity(
        id: _uuid.v4(),
        text: 'Halo! Aku asisten cerdasmu. Ada yang bisa aku bantu hari ini?',
        sender: ChatSender.assistant,
        timestamp: DateTime.now(),
      );
      await _saveToDb(welcome);
      state = [welcome];
    } else {
      state = messages.map((m) => ChatMessageEntity(
        id: m.id,
        text: m.textContent,
        sender: m.sender == 0 ? ChatSender.user : ChatSender.assistant,
        timestamp: m.timestamp,
        intents: m.intentsJson != null ? IntentParseResponse.fromJsonString(m.intentsJson!).intents : null,
      )).toList();
    }
  }

  Future<void> _saveToDb(ChatMessageEntity msg) async {
    final db = _ref.read(appDatabaseProvider);
    await db.into(db.chatMessages).insert(
      ChatMessagesCompanion.insert(
        id: msg.id,
        textContent: msg.text,
        sender: msg.sender == ChatSender.user ? 0 : 1,
        timestamp: msg.timestamp,
        intentsJson: msg.intents == null 
            ? const Value.absent() 
            : Value(jsonEncode(IntentParseResponse(intents: msg.intents!).toJson())),
      ),
      mode: InsertMode.replace,
    );
  }

  Future<void> _deleteFromDb(String id) async {
    final db = _ref.read(appDatabaseProvider);
    await (db.delete(db.chatMessages)..where((t) => t.id.equals(id))).go();
  }

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
    await _saveToDb(userMessage);

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
        _replaceLoadingWith('', intents: response.intents);
        final summaryMsg = ChatMessageEntity(
          id: _uuid.v4(),
          text: _summarizeActions(response.intents),
          sender: ChatSender.assistant,
          timestamp: DateTime.now(),
        );
        state = [
          ...state,
          summaryMsg
        ];
        _saveToDb(summaryMsg);
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

  void _replaceLoadingWith(String message, {List<IntentResult>? intents}) {
    final index = state.indexWhere((m) => m.isLoading);
    if (index == -1) {
      final msg = ChatMessageEntity(
        id: _uuid.v4(),
        text: message,
        sender: ChatSender.assistant,
        timestamp: DateTime.now(),
        intents: intents,
      );
      state = [
        ...state,
        msg,
      ];
      _saveToDb(msg);
      return;
    }
    final updated = [...state];
    updated[index] = updated[index].copyWith(text: message, isLoading: false, intents: intents);
    state = updated;
    _saveToDb(updated[index]);
  }

  void _removeLoadingIfStillPresent() {
    final stillLoading = state.any((m) => m.isLoading);
    if (stillLoading) {
      state = state.where((m) => !m.isLoading).toList();
    }
  }

  void deleteMessage(String id) {
    state = state.where((m) => m.id != id).toList();
    _deleteFromDb(id);
  }

  void editMessage(String id, String newText) {
    final index = state.indexWhere((m) => m.id == id);
    if (index != -1) {
      final updatedMsg = state[index].copyWith(text: newText);
      final updatedList = [...state];
      updatedList[index] = updatedMsg;
      state = updatedList;
      _saveToDb(updatedMsg);
    }
  }

  String _summarizeActions(List<IntentResult> intents) {
    final actionable = intents.where((i) => i.type != IntentType.chat).toList();
    final uniqueTypes = actionable.map((i) => i.type.name).toSet().toList();
    
    if (uniqueTypes.isEmpty) return 'Selesai diproses.';
    
    final formattedTypes = uniqueTypes.map((t) => t[0].toUpperCase() + t.substring(1)).toList();
    String targetStr = formattedTypes.join(', ');
    if (formattedTypes.length > 1) {
      targetStr = '${formattedTypes.sublist(0, formattedTypes.length - 1).join(', ')} dan ${formattedTypes.last}';
    }
    
    return 'Sudah kusimpan ke $targetStr ✅ Ada lagi?';
  }
}
