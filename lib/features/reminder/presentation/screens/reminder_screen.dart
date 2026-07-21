import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_utils.dart';
import '../../providers/reminder_providers.dart';

class ReminderScreen extends ConsumerWidget {
  const ReminderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remindersAsync = ref.watch(reminderListProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Reminder', style: AppTextStyles.heading3)),
      body: remindersAsync.when(
        data: (reminders) => reminders.isEmpty
            ? const Center(child: Text('Belum ada reminder.'))
            : ListView.builder(
                itemCount: reminders.length,
                itemBuilder: (context, index) {
                  final r = reminders[index];
                  return ListTile(
                    leading: const Icon(Icons.notifications_active_outlined),
                    title: Text(r.title),
                    subtitle: Text(AppDateUtils.formatDateTime(r.triggerAt)),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () =>
                          ref.read(reminderActionsProvider.notifier).deleteReminder(r.id!),
                    ),
                  );
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }
}