import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // TODO: init dependencies berat di sini, mis:
  // await AppDatabase.instance; (Drift auto-init on first query)
  // await ReminderNotificationService().init();
  runApp(const ProviderScope(child: DailyNoteApp()));
}