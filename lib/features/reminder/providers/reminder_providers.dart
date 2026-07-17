import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../todo/providers/todo_providers.dart' show appDatabaseProvider;
import '../../../core/notification/reminder_notification_service.dart';
import '../data/repositories/reminder_repository_impl.dart';
import '../domain/entities/reminder_entity.dart';
import '../domain/repositories/reminder_repository.dart';

final reminderNotificationServiceProvider =
    Provider<ReminderNotificationService>((ref) => ReminderNotificationService());

final reminderRepositoryProvider = Provider<IReminderRepository>((ref) {
  return ReminderRepositoryImpl(
    db: ref.watch(appDatabaseProvider),
    notificationService: ref.watch(reminderNotificationServiceProvider),
  );
});

final reminderListProvider = FutureProvider.autoDispose<List<ReminderEntity>>((ref) async {
  return ref.watch(reminderRepositoryProvider).getAll();
});

class ReminderActionsNotifier extends StateNotifier<AsyncValue<void>> {
  final IReminderRepository _repository;
  final Ref _ref;
  ReminderActionsNotifier(this._repository, this._ref) : super(const AsyncValue.data(null));

  Future<void> addReminder(ReminderEntity reminder) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.add(reminder));
    _ref.invalidate(reminderListProvider);
  }

  Future<void> deleteReminder(int id) async {
    await _repository.delete(id);
    _ref.invalidate(reminderListProvider);
  }
}

final reminderActionsProvider = StateNotifierProvider<ReminderActionsNotifier, AsyncValue<void>>((ref) {
  return ReminderActionsNotifier(ref.watch(reminderRepositoryProvider), ref);
});