import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../providers/summary_providers.dart';
import '../widgets/summary_stat_tile.dart';

class DailySummaryScreen extends ConsumerWidget {
  const DailySummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(dailySummaryProvider);
    final selectedDate = ref.watch(selectedSummaryDateProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Ringkasan Harian', style: AppTextStyles.heading3)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => ref.read(selectedSummaryDateProvider.notifier).state =
                      selectedDate.subtract(const Duration(days: 1)),
                ),
                Text(AppDateUtils.formatDate(selectedDate), style: AppTextStyles.heading3),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () => ref.read(selectedSummaryDateProvider.notifier).state =
                      selectedDate.add(const Duration(days: 1)),
                ),
              ],
            ),
          ),
          Expanded(
            child: summaryAsync.when(
              data: (summary) => GridView.count(
                padding: const EdgeInsets.all(16),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.4,
                children: [
                  SummaryStatTile(
                    label: 'Jadwal',
                    value: '${summary.totalEvents}',
                    icon: Icons.calendar_today_outlined,
                    accentColor: AppColors.calendarAccent,
                  ),
                  SummaryStatTile(
                    label: 'Tugas Selesai',
                    value: '${summary.totalTodosCompleted}',
                    icon: Icons.check_circle_outline,
                    accentColor: AppColors.todoAccent,
                  ),
                  SummaryStatTile(
                    label: 'Tugas Pending',
                    value: '${summary.totalTodosPending}',
                    icon: Icons.pending_actions_outlined,
                    accentColor: AppColors.warning,
                  ),
                  SummaryStatTile(
                    label: 'Pengeluaran',
                    value: CurrencyFormatter.format(summary.totalExpense),
                    icon: Icons.attach_money_outlined,
                    accentColor: AppColors.expenseAccent,
                  ),
                  SummaryStatTile(
                    label: 'Catatan Baru',
                    value: '${summary.totalNotes}',
                    icon: Icons.note_outlined,
                    accentColor: AppColors.notesAccent,
                  ),
                ],
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }
}