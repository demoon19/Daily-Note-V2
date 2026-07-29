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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: const ColorScheme.dark(
                                primary: AppColors.cyan,
                                onPrimary: Colors.black,
                                surface: AppColors.surfaceVariant,
                                onSurface: Colors.white,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null) {
                        ref.read(selectedDateProvider.notifier).state = picked;
                      }
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('JADWAL', style: AppTextStyles.eyebrow.copyWith(letterSpacing: 2)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              '${_getMonthName(selectedDate.month)} ${selectedDate.year}',
                              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.arrow_drop_down, color: Colors.white, size: 28),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Menyinkronkan dengan Google Calendar...')),
                      );
                      ref.read(calendarActionsProvider.notifier).syncGoogleCalendar().then((_) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Sinkronisasi berhasil!')),
                          );
                        }
                      }).catchError((err) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(err.toString(), style: const TextStyle(color: Colors.white)), backgroundColor: Colors.red),
                          );
                        }
                      });
                    },
                    icon: const Icon(Icons.sync, color: AppColors.cyan),
                    tooltip: 'Sync Google Calendar',
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
                          final event = events[index];
                          return EventTile(
                            event: event,
                            isFirst: index == 0,
                            onTap: () => _showEventDetailsDialog(context, event),
                            onDelete: () => ref
                                .read(calendarActionsProvider.notifier)
                                .deleteEvent(event.id!),
                            onEdit: () => _showEditEventDialog(context, ref, event),
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

  void _showEventDetailsDialog(BuildContext context, EventEntity event) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: Text(event.title, style: const TextStyle(fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 16, color: AppColors.teal),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          AppDateUtils.formatDateTime(event.datetime),
                          style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                  if (event.location != null && event.location!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.location_on_outlined, size: 16, color: AppColors.cyan),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            event.location!,
                            style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (event.notes != null && event.notes!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Divider(color: AppColors.line),
                    const SizedBox(height: 12),
                    Text(
                      'Catatan / Isi Email:',
                      style: AppTextStyles.eyebrow.copyWith(color: AppColors.textDisabled),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        event.notes!,
                        style: const TextStyle(fontSize: 13, height: 1.5),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  void _showAddEventDialog(BuildContext context, WidgetRef ref, DateTime initialDate) {
    final titleController = TextEditingController();
    final notesController = TextEditingController();
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
                      Expanded(
                        child: Text('Waktu: ${AppDateUtils.formatDateTime(selectedDateTime)}'),
                      ),
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
                  const SizedBox(height: 16),
                  TextField(
                    controller: notesController,
                    maxLines: 5,
                    minLines: 1,
                    decoration: const InputDecoration(
                      labelText: 'Catatan / Detail',
                      hintText: 'Tulis keterangan atau isi email...',
                    ),
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
                            notes: notesController.text.trim().isNotEmpty ? notesController.text.trim() : null,
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
    final notesController = TextEditingController(text: event.notes ?? '');
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
                      Expanded(
                        child: Text('Waktu: ${AppDateUtils.formatDateTime(selectedDateTime)}'),
                      ),
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
                  const SizedBox(height: 16),
                  TextField(
                    controller: notesController,
                    maxLines: 5,
                    minLines: 1,
                    decoration: const InputDecoration(
                      labelText: 'Catatan / Detail',
                      hintText: 'Tulis keterangan atau isi email...',
                    ),
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
                            notes: notesController.text.trim().isNotEmpty ? notesController.text.trim() : null,
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