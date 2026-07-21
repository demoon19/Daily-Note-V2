import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'routes/app_router.dart';
import 'features/settings/providers/settings_providers.dart';

class DailyNoteApp extends ConsumerWidget {
  const DailyNoteApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(appSettingsProvider);

    final isDarkMode = settingsAsync.maybeWhen(
      data: (settings) => settings.isDarkMode,
      orElse: () => true,
    );

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme,
      routerConfig: appRouter,
    );
  }
}