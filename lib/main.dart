import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app.dart';
import 'core/notification/remindere_notification_service.dart';

import 'routes/app_router.dart';
import 'features/calendar/providers/calendar_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  await initializeDateFormatting('id_ID', null);
  
  final container = ProviderContainer();
  
  await ReminderNotificationService().init(
    onNotificationClick: (payload) {
      if (payload != null) {
        try {
          final date = DateTime.parse(payload);
          container.read(selectedDateProvider.notifier).state = date;
          appRouter.go(AppRoutes.calendar);
        } catch (_) {}
      }
    }
  );

  runApp(UncontrolledProviderScope(container: container, child: const DailyNoteApp()));
}
