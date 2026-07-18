import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'core/notification/reminder_notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await ReminderNotificationService().init();

  final container = ProviderContainer();

  // TODO: cek appSettingsProvider — jika isEmailIntegrationEnabled true
  // dan gmailAuthStatusProvider terhubung, panggil:
  // container.read(emailListenerServiceProvider).startPolling(
  //   onNewEmails: (emails) async {
  //     final router = container.read(emailRouterProvider);
  //     for (final email in emails) {
  //       await router.processIncomingEmail(
  //         subject: email['subject'] as String,
  //         bodySnippet: email['snippet'] as String,
  //       );
  //     }
  //   },
  // );

  runApp(UncontrolledProviderScope(container: container, child: const DailyNoteApp()));
}