import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/repositories/settings_repository_impl.dart';
import '../domain/entities/app_settings_entity.dart';
import '../domain/repositories/settings_repository.dart';
import '../../../core/notification/remindere_notification_service.dart';

final settingsRepositoryProvider =
    Provider<ISettingsRepository>((ref) => SettingsRepositoryImpl());

final appSettingsProvider =
    StateNotifierProvider<AppSettingsNotifier, AsyncValue<AppSettingsEntity>>(
        (ref) => AppSettingsNotifier(ref.watch(settingsRepositoryProvider)));

class AppSettingsNotifier extends StateNotifier<AsyncValue<AppSettingsEntity>> {
  final ISettingsRepository _repository;

  AppSettingsNotifier(this._repository) : super(const AsyncValue.loading()) {
    _load();
  }

  Future<void> _load() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.load());
  }

  Future<void> _update(
      AppSettingsEntity Function(AppSettingsEntity) transform) async {
    final current = state.value ?? const AppSettingsEntity();
    final updated = transform(current);
    state = AsyncValue.data(updated);
    await _repository.save(updated);
  }

  Future<void> toggleDarkMode(bool value) =>
      _update((s) => s.copyWith(isDarkMode: value));

  Future<void> toggleVoice(bool value) =>
      _update((s) => s.copyWith(isVoiceEnabled: value));

  Future<void> toggleTts(bool value) =>
      _update((s) => s.copyWith(isTtsEnabled: value));

  Future<void> toggleEmailIntegration(bool value) =>
      _update((s) => s.copyWith(isEmailIntegrationEnabled: value));

  Future<void> toggleNotification(bool value) async {
    await _update((s) => s.copyWith(isNotificationEnabled: value));
    if (!value) {
      await ReminderNotificationService().cancelAll();
    }
  }

  Future<void> setLlmMode(LlmMode mode) =>
      _update((s) => s.copyWith(llmMode: mode));

  Future<void> setReminderOffset(int minutes) =>
      _update((s) => s.copyWith(defaultReminderOffsetMinutes: minutes));
}
