import '../entities/app_settings_entity.dart';

abstract class ISettingsRepository {
  Future<AppSettingsEntity> load();
  Future<void> save(AppSettingsEntity settings);
}