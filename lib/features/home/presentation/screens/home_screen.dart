import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../routes/app_router.dart';
import '../../../chat_assistant/providers/chat_providers.dart';
import '../../../chat_assistant/presentation/screens/chat_screen.dart'
    show speechToTextServiceProvider, isListeningProvider;
import '../widgets/greeting_widget.dart';
import '../widgets/motivation_widget.dart';
import '../widgets/daily_summary_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _controller = TextEditingController();

  void _sendQuickInput() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    // Kirim lewat chat provider yang sama, lalu arahkan user ke chat screen
    // untuk melihat hasil/balasan.
    ref.read(chatMessagesProvider.notifier).sendMessage(text);
    _controller.clear();
    context.push(AppRoutes.chat);
  }

  Future<void> _toggleMic() async {
    final service = ref.read(speechToTextServiceProvider);
    final isListening = ref.read(isListeningProvider);
    if (isListening) {
      await service.stopListening();
      ref.read(isListeningProvider.notifier).state = false;
      return;
    }
    ref.read(isListeningProvider.notifier).state = true;
    await service.startListening(
      onResult: (recognizedText) => _controller.text = recognizedText,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isListening = ref.watch(isListeningProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Note'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push(AppRoutes.settings),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const GreetingWidget(),
            const SizedBox(height: 16),
            const MotivationWidget(),
            const SizedBox(height: 16),
            const DailySummaryCard(),
            const SizedBox(height: 24),
            Text(
              'Apa yang bisa kubantu?',
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: _controller,
              hintText: 'Mis: "Ingatkan meeting jam 9 besok"',
              isListening: isListening,
              onMicPressed: _toggleMic,
              onSubmitted: _sendQuickInput,
            ),
            const SizedBox(height: 24),
            _QuickAccessGrid(),
          ],
        ),
      ),
    );
  }
}

class _QuickAccessGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final items = [
      ('Jadwal', Icons.calendar_today_outlined, AppRoutes.calendar),
      ('To-do', Icons.check_circle_outline, AppRoutes.todo),
      ('Catatan', Icons.note_outlined, AppRoutes.notes),
      ('Pengeluaran', Icons.attach_money_outlined, AppRoutes.expense),
      ('Reminder', Icons.notifications_outlined, AppRoutes.reminder),
      ('Ringkasan', Icons.bar_chart_outlined, AppRoutes.dailySummary),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        final (label, icon, route) = items[index];
        return InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => GoRouter.of(context).push(route),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 28),
                const SizedBox(height: 8),
                Text(label, style: Theme.of(context).textTheme.labelSmall),
              ],
            ),
          ),
        );
      },
    );
  }
}