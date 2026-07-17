import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_utils.dart';
import '../../domain/entities/event_entity.dart';
import '../../providers/calendar_providers.dart';
import '../widgets/event_tile.dart';

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final eventsAsync = ref.watch(eventsByDateProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Jadwal', style: AppTextStyles.heading3)),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEventDialog(context, ref, selectedDate),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              AppDateUtils.formatDate(selectedDate),
              style: AppTextStyles.heading2,
            ),
          ),
          Expanded(
            child: eventsAsync.when(
              data: (events) => events.isEmpty
                  ? const Center(child: Text('Tidak ada jadwal hari ini.'))
                  : ListView.builder(
                      itemCount: events.length,
                      itemBuilder: (context, index) => EventTile(
                        event: events[index],
                        onDelete: () => ref
                            .read(calendarActionsProvider.notifier)
                            .deleteEvent(events[index].id!),
                      ),
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddEventDialog(BuildContext context, WidgetRef ref, DateTime date) {
    final titleController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Jadwal Baru'),
        content: TextField(controller: titleController, decoration: const InputDecoration(hintText: 'Judul acara')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          TextButton(
            onPressed: () {
              if (titleController.text.trim().isEmpty) return;
              ref.read(calendarActionsProvider.notifier).addEvent(
                    EventEntity(title: titleController.text.trim(), datetime: date),
                  );
              Navigator.pop(ctx);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}