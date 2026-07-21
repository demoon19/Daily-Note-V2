import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
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
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEventDialog(context, ref, selectedDate),
        backgroundColor: AppColors.cyan,
        foregroundColor: AppColors.background,
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('JADWAL', style: AppTextStyles.eyebrow.copyWith(letterSpacing: 2)),
                  const SizedBox(height: 4),
                  Text(
                    '${_getMonthName(selectedDate.month)} ${selectedDate.year}',
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Horizontal Week View
            SizedBox(
              height: 70,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 7,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemBuilder: (context, index) {
                  // Get monday of the selected date's week
                  final diff = selectedDate.weekday - 1;
                  final monday = selectedDate.subtract(Duration(days: diff));
                  final date = monday.add(Duration(days: index));
                  
                  final isSelected = date.day == selectedDate.day &&
                      date.month == selectedDate.month &&
                      date.year == selectedDate.year;

                  return GestureDetector(
                    onTap: () => ref.read(selectedDateProvider.notifier).state = date,
                    child: Container(
                      width: 50,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: isSelected
                          ? BoxDecoration(
                              color: AppColors.cyan,
                              borderRadius: BorderRadius.circular(16),
                            )
                          : null,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _getShortDayName(date.weekday),
                            style: TextStyle(
                              color: isSelected ? AppColors.background : AppColors.textDisabled,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${date.day}',
                            style: TextStyle(
                              color: isSelected ? AppColors.background : Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),
            
            // Subtitle Hari ini
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Text(
                _isToday(selectedDate) ? 'HARI INI' : 'TANGGAL TERPILIH',
                style: AppTextStyles.eyebrow.copyWith(letterSpacing: 2),
              ),
            ),

            // Timeline List
            Expanded(
              child: eventsAsync.when(
                data: (events) => events.isEmpty
                    ? const Center(child: Text('Tidak ada jadwal untuk tanggal ini.', style: TextStyle(color: AppColors.textDisabled)))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: events.length,
                        itemBuilder: (context, index) {
                          return EventTile(
                            event: events[index],
                            isFirst: index == 0,
                            onDelete: () => ref
                                .read(calendarActionsProvider.notifier)
                                .deleteEvent(events[index].id!),
                            onEdit: () => _showEditEventDialog(context, ref, events[index]),
                          );
                        },
                      ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text('Error: $err')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  String _getMonthName(int month) {
    const months = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return months[month];
  }

  String _getShortDayName(int weekday) {
    const days = ['', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    return days[weekday];
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