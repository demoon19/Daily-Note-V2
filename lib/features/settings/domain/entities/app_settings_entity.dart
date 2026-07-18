enum LlmMode { onDeviceOnly, hybrid, cloudOnly }

class AppSettingsEntity {
  final bool isDarkMode;
  final bool isVoiceEnabled;
  final bool isTtsEnabled;
  final bool isEmailIntegrationEnabled;
  final LlmMode llmMode;
  final int defaultReminderOffsetMinutes;

  const AppSettingsEntity({
    this.isDarkMode = true,
    this.isVoiceEnabled = true,
    this.isTtsEnabled = false,
    this.isEmailIntegrationEnabled = false,
    this.llmMode = LlmMode.hybrid,
    this.defaultReminderOffsetMinutes = 30,
  });

  AppSettingsEntity copyWith({
    bool? isDarkMode,
    bool? isVoiceEnabled,
    bool? isTtsEnabled,
    bool? isEmailIntegrationEnabled,
    LlmMode? llmMode,
    int? defaultReminderOffsetMinutes,
  }) {
    return AppSettingsEntity(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      isVoiceEnabled: isVoiceEnabled ?? this.isVoiceEnabled,
      isTtsEnabled: isTtsEnabled ?? this.isTtsEnabled,
      isEmailIntegrationEnabled:
          isEmailIntegrationEnabled ?? this.isEmailIntegrationEnabled,
      llmMode: llmMode ?? this.llmMode,
      defaultReminderOffsetMinutes:
          defaultReminderOffsetMinutes ?? this.defaultReminderOffsetMinutes,
    );
  }
}