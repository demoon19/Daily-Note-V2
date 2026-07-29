import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../todo/providers/todo_providers.dart' show appDatabaseProvider;
import '../data/repositories/event_repository_impl.dart';
import '../domain/entities/event_entity.dart';
import '../domain/repositories/event_repository.dart';
import '../../../../core/network/google_calendar_service.dart';

final eventRepositoryProvider = Provider<IEventRepository>((ref) {
  return EventRepositoryImpl(db: ref.watch(appDatabaseProvider));
});

final eventListProvider = FutureProvider.autoDispose<List<EventEntity>>((ref) async {
  return ref.watch(eventRepositoryProvider).getAll();
});

final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

final eventsByDateProvider = FutureProvider.autoDispose<List<EventEntity>>((ref) async {
  final date = ref.watch(selectedDateProvider);
  return ref.watch(eventRepositoryProvider).getByDate(date);
});

class CalendarActionsNotifier extends StateNotifier<AsyncValue<void>> {
  final IEventRepository _repository;
  final Ref _ref;
  CalendarActionsNotifier(this._repository, this._ref) : super(const AsyncValue.data(null));

  Future<void> addEvent(EventEntity event) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.add(event));
    _ref.invalidate(eventListProvider);
    _ref.invalidate(eventsByDateProvider);
  }

  Future<void> deleteEvent(int id) async {
    await _repository.delete(id);
    _ref.invalidate(eventListProvider);
    _ref.invalidate(eventsByDateProvider);
  }

  Future<void> updateEvent(EventEntity event) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.update(event));
    _ref.invalidate(eventListProvider);
    _ref.invalidate(eventsByDateProvider);
  }

  Future<void> syncGoogleCalendar() async {
    state = const AsyncValue.loading();
    try {
      await _repository.syncFromGoogle();
      state = const AsyncValue.data(null);
      _ref.invalidate(eventListProvider);
      _ref.invalidate(eventsByDateProvider);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

final calendarActionsProvider = StateNotifierProvider<CalendarActionsNotifier, AsyncValue<void>>((ref) {
  return CalendarActionsNotifier(ref.watch(eventRepositoryProvider), ref);
});

final googleCalendarAuthProvider = StateNotifierProvider<GoogleCalendarAuthNotifier, AsyncValue<bool>>((ref) {
  return GoogleCalendarAuthNotifier();
});

class GoogleCalendarAuthNotifier extends StateNotifier<AsyncValue<bool>> {
  GoogleCalendarAuthNotifier() : super(const AsyncValue.loading()) {
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return await GoogleCalendarService().isSignedIn();
    });
  }

  Future<void> connect() async {
    try {
      final success = await GoogleCalendarService().login();
      if (!success) {
        state = const AsyncValue.data(false);
        return;
      }
      await _checkStatus();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> disconnect() async {
    await GoogleCalendarService().disconnect();
    await _checkStatus();
  }
}