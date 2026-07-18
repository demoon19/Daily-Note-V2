import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/app_settings_entity.dart';
import '../../domain/repositories/settings_repository.dart';

/// Settings ringan pakai SharedPreferences sesuai guide bagian 2:
/// "Hive/SharedPreferences untuk settings ringan" (bukan Drift,
/// karena bukan data terstruktur relasional).
class SettingsRepositoryImpl implements ISettingsRepository {
  static const _keyDarkMode = 'settings_dark_mode';
  static const _keyVoiceEnabled = 'settings_voice_enabled';
  static const _keyTtsEnabled = 'settings_tts_enabled';
  static const _keyEmailIntegration = 'settings_email_integration';
  static const _keyLlmMode = 'settings_llm_mode';
  static const _keyReminderOffset = 'settings_reminder_offset';

  @override
  Future<AppSettingsEntity> load() async {
    final prefs = await SharedPreferences.getInstance();
    return AppSettingsEntity(
      isDarkMode: prefs.getBool(_keyDarkMode) ?? true,
      isVoiceEnabled: prefs.getBool(_keyVoiceEnabled) ?? true,
      isTtsEnabled: prefs.getBool(_keyTtsEnabled) ?? false,
      isEmailIntegrationEnabled: prefs.getBool(_keyEmailIntegration) ?? false,
      llmMode: LlmMode.values.firstWhere(
        (e) => e.name == (prefs.getString(_keyLlmMode) ?? LlmMode.hybrid.name),
        orElse: () => LlmMode.hybrid,
      ),
      defaultReminderOffsetMinutes: prefs.getInt(_keyReminderOffset) ?? 30,
    );
  }

  @override
  Future<void> save(AppSettingsEntity settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDarkMode, settings.isDarkMode);
    await prefs.setBool(_keyVoiceEnabled, settings.isVoiceEnabled);
    await prefs.setBool(_keyTtsEnabled, settings.isTtsEnabled);
    await prefs.setBool(_keyEmailIntegration, settings.isEmailIntegrationEnabled);
    await prefs.setString(_keyLlmMode, settings.llmMode.name);
    await prefs.setInt(_keyReminderOffset, settings.defaultReminderOffsetMinutes);
  }
}