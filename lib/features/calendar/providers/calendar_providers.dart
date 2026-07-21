import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../todo/providers/todo_providers.dart' show appDatabaseProvider;
import '../data/repositories/event_repository_impl.dart';
import '../domain/entities/event_entity.dart';
import '../domain/repositories/event_repository.dart';

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
}

final calendarActionsProvider = StateNotifierProvider<CalendarActionsNotifier, AsyncValue<void>>((ref) {
  return CalendarActionsNotifier(ref.watch(eventRepositoryProvider), ref);
});