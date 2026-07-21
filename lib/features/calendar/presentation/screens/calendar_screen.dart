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
      appBar: AppBar(title: Text('Jadwal', style: AppTextStyles.heading3)),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEventDialog(context, ref, selectedDate),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () {
                    ref.read(selectedDateProvider.notifier).state = 
                        selectedDate.subtract(const Duration(days: 1));
                  },
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (date != null) {
                        ref.read(selectedDateProvider.notifier).state = date;
                      }
                    },
                    child: Text(
                      AppDateUtils.formatDate(selectedDate),
                      style: AppTextStyles.heading2,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () {
                    ref.read(selectedDateProvider.notifier).state = 
                        selectedDate.add(const Duration(days: 1));
                  },
                ),
              ],
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
                        onEdit: () => _showEditEventDialog(context, ref, events[index]),
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

  void _showAddEventDialog(BuildContext context, WidgetRef ref, DateTime initialDate) {
    final titleController = TextEditingController();
    DateTime selectedDateTime = initialDate;
    String? recurrenceValue;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Jadwal Baru'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(hintText: 'Judul acara'),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Waktu: ${AppDateUtils.formatDateTime(selectedDateTime)}'),
                      TextButton(
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: selectedDateTime,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (date != null) {
                            if (!context.mounted) return;
                            final time = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.fromDateTime(selectedDateTime),
                            );
                            if (time != null) {
                              setState(() {
                                selectedDateTime = DateTime(
                                  date.year, date.month, date.day,
                                  time.hour, time.minute,
                                );
                              });
                            }
                          }
                        },
                        child: const Text('Ubah'),
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: recurrenceValue,
                    decoration: const InputDecoration(labelText: 'Perulangan'),
                    items: const [
                      DropdownMenuItem(value: null, child: Text('Tidak Berulang')),
                      DropdownMenuItem(value: 'harian', child: Text('Harian')),
                      DropdownMenuItem(value: 'bulanan', child: Text('Bulanan')),
                      DropdownMenuItem(value: 'tahunan', child: Text('Tahunan')),
                    ],
                    onChanged: (val) {
                      setState(() {
                        recurrenceValue = val;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
                TextButton(
                  onPressed: () {
                    if (titleController.text.trim().isEmpty) return;
                    ref.read(calendarActionsProvider.notifier).addEvent(
                          EventEntity(
                            title: titleController.text.trim(),
                            datetime: selectedDateTime,
                            recurrence: recurrenceValue,
                          ),
                        ).then((_) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Jadwal berhasil ditambahkan!')),
                        );
                      }
                    });
                    Navigator.pop(ctx);
                  },
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditEventDialog(BuildContext context, WidgetRef ref, EventEntity event) {
    final titleController = TextEditingController(text: event.title);
    DateTime selectedDateTime = event.datetime;
    String? recurrenceValue = event.recurrence;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Jadwal'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(hintText: 'Judul acara'),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Waktu: ${AppDateUtils.formatDateTime(selectedDateTime)}'),
                      TextButton(
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: selectedDateTime,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (date != null) {
                            if (!context.mounted) return;
                            final time = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.fromDateTime(selectedDateTime),
                            );
                            if (time != null) {
                              setState(() {
                                selectedDateTime = DateTime(
                                  date.year, date.month, date.day,
                                  time.hour, time.minute,
                                );
                              });
                            }
                          }
                        },
                        child: const Text('Ubah'),
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: recurrenceValue,
                    decoration: const InputDecoration(labelText: 'Perulangan'),
                    items: const [
                      DropdownMenuItem(value: null, child: Text('Tidak Berulang')),
                      DropdownMenuItem(value: 'harian', child: Text('Harian')),
                      DropdownMenuItem(value: 'bulanan', child: Text('Bulanan')),
                      DropdownMenuItem(value: 'tahunan', child: Text('Tahunan')),
                    ],
                    onChanged: (val) {
                      setState(() {
                        recurrenceValue = val;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
                TextButton(
                  onPressed: () {
                    if (titleController.text.trim().isEmpty) return;
                    ref.read(calendarActionsProvider.notifier).updateEvent(
                          EventEntity(
                            id: event.id,
                            title: titleController.text.trim(),
                            datetime: selectedDateTime,
                            location: event.location,
                            notes: event.notes,
                            recurrence: recurrenceValue,
                          ),
                        ).then((_) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Jadwal berhasil diperbarui!')),
                        );
                      }
                    });
                    Navigator.pop(ctx);
                  },
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}