import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/app_settings_entity.dart';
import '../../providers/settings_providers.dart';
import '../../../../core/email/providers/email_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(appSettingsProvider);
    final gmailAuthAsync = ref.watch(gmailAuthStatusProvider);

    return Scaffold(
      appBar: AppBar(
          title: Text('Pengaturan', style: AppTextStyles.heading3)),
      body: settingsAsync.when(
        data: (settings) => ListView(
          children: [
            SwitchListTile(
              title: const Text('Mode Gelap'),
              value: settings.isDarkMode,
              onChanged: (v) =>
                  ref.read(appSettingsProvider.notifier).toggleDarkMode(v),
            ),
            const Divider(),
            SwitchListTile(
              title: const Text('Notifikasi'),
              subtitle: const Text('Aktifkan pengingat jadwal dan tugas'),
              value: settings.isNotificationEnabled,
              onChanged: (v) =>
                  ref.read(appSettingsProvider.notifier).toggleNotification(v),
            ),
            const Divider(),
            SwitchListTile(
              title: const Text('Integrasi Email (Auto-schedule)'),
              subtitle: const Text('Deteksi jadwal otomatis dari email masuk'),
              value: settings.isEmailIntegrationEnabled,
              onChanged: (v) async {
                if (v) {
                  await ref.read(gmailAuthStatusProvider.notifier).connect();
                }
                ref
                    .read(appSettingsProvider.notifier)
                    .toggleEmailIntegration(v);
              },
            ),
            gmailAuthAsync.when(
              data: (isConnected) => ListTile(
                leading: Icon(
                  isConnected ? Icons.check_circle : Icons.error_outline,
                  color: isConnected ? Colors.green : Colors.grey,
                ),
                title: Text(isConnected
                    ? 'Akun Gmail terhubung'
                    : 'Belum terhubung ke Gmail'),
                trailing: isConnected
                    ? TextButton(
                        onPressed: () => ref
                            .read(gmailAuthStatusProvider.notifier)
                            .disconnect(),
                        child: const Text('Putuskan'),
                      )
                    : null,
              ),
              loading: () =>
                  const ListTile(title: Text('Memeriksa status Gmail...')),
              error: (_, __) =>
                  const ListTile(title: Text('Gagal memeriksa status Gmail')),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  String _llmModeLabel(LlmMode mode) {
    switch (mode) {
      case LlmMode.onDeviceOnly:
        return 'On-device saja';
      case LlmMode.hybrid:
        return 'Hybrid (default)';
      case LlmMode.cloudOnly:
        return 'Cloud saja';
    }
  }
}
