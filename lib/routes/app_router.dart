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

/// Semua path terpusat di sini. Jangan buat Navigator.push manual
/// dengan MaterialPageRoute di dalam fitur — selalu lewat go_router.
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

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  routes: [
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: AppRoutes.chat,
      builder: (context, state) => const ChatScreen(),
    ),
    GoRoute(
      path: AppRoutes.calendar,
      builder: (context, state) => const CalendarScreen(),
    ),
    GoRoute(
      path: AppRoutes.todo,
      builder: (context, state) => const TodoScreen(),
    ),
    GoRoute(
      path: AppRoutes.notes,
      builder: (context, state) => const NotesScreen(),
    ),
    GoRoute(
      path: AppRoutes.expense,
      builder: (context, state) => const ExpenseScreen(),
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
