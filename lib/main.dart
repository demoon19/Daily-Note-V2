import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app.dart';
import 'core/notification/remindere_notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('id_ID', null);
  await ReminderNotificationService().init();
  final container = ProviderContainer();

  runApp(UncontrolledProviderScope(container: container, child: const DailyNoteApp()));
}
