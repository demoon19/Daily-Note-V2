import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/chat_assistant/presentation/screens/chat_screen.dart';
import '../features/calendar/presentation/screens/calendar_screen.dart';
import '../features/todo/presentation/screens/todo_screens.dart';
import '../features/notes/presentation/screens/note_screen.dart';
import '../features/expense/presentation/screens/expense_screen.dart';
import '../features/reminder/presentation/screens/reminder_screen.dart';
import '../features/summary/presentation/screens/daily_summary_screen.dart';
import '../features/summary/presentation/screens/weekly_summary_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';
import '../core/widgets/main_layout.dart';

class AppRoutes {
  AppRoutes._();

  static const String home = '/';
  static const String chat = '/chat';
  static const String calendar = '/calendar';
  static const String todo = '/todo';
  static const String notes = '/notes';
  static const String expense = '/expense';
  static const String reminder = '/reminder';
  static const String dailySummary = '/summary/daily';
  static const String weeklySummary = '/summary/weekly';
  static const String settings = '/settings';
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: AppRoutes.home,
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return MainLayout(child: child);
      },
      routes: [
        GoRoute(
          path: AppRoutes.home,
          pageBuilder: (context, state) => const NoTransitionPage(child: HomeScreen()),
        ),
        GoRoute(
          path: AppRoutes.chat,
          pageBuilder: (context, state) => const NoTransitionPage(child: ChatScreen()),
        ),
        GoRoute(
          path: AppRoutes.calendar,
          pageBuilder: (context, state) => const NoTransitionPage(child: CalendarScreen()),
        ),
        GoRoute(
          path: AppRoutes.todo,
          pageBuilder: (context, state) => const NoTransitionPage(child: TodoScreen()),
        ),
        GoRoute(
          path: AppRoutes.expense,
          pageBuilder: (context, state) => const NoTransitionPage(child: ExpenseScreen()),
        ),
      ],
    ),
    // Layar yang tidak menggunakan MainLayout ditaruh di luar ShellRoute (misal full screen)
    GoRoute(
      path: AppRoutes.notes,
      builder: (context, state) => const NotesScreen(),
    ),
    GoRoute(
      path: AppRoutes.reminder,
      builder: (context, state) => const ReminderScreen(),
    ),
    GoRoute(
      path: AppRoutes.dailySummary,
      builder: (context, state) => const DailySummaryScreen(),
    ),
    GoRoute(
      path: AppRoutes.weeklySummary,
      builder: (context, state) => const WeeklySummaryScreen(),
    ),
    GoRoute(
      path: AppRoutes.settings,
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);
