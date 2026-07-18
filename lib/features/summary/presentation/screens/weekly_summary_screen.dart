import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_card.dart';
import '../../providers/summary_providers.dart';

class WeeklySummaryScreen extends ConsumerWidget {
  const WeeklySummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(weeklySummaryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Ringkasan Mingguan', style: AppTextStyles.heading3)),
      body: summaryAsync.when(
        data: (summary) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              '${AppDateUtils.formatDate(summary.rangeStart)} — '
              '${AppDateUtils.formatDate(summary.rangeEnd)}',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 16),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _StatRow(label: 'Total Jadwal', value: '${summary.totalEvents}'),
                  const SizedBox(height: 8),
                  _StatRow(label: 'Total Tugas Selesai', value: '${summary.totalTodosCompleted}'),
                  const SizedBox(height: 8),
                  _StatRow(
                    label: 'Total Pengeluaran',
                    value: CurrencyFormatter.format(summary.totalExpense),
                  ),
                  const SizedBox(height: 8),
                  _StatRow(
                    label: 'Rata-rata/hari',
                    value: CurrencyFormatter.format(summary.averageExpensePerDay),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('Rincian Harian', style: AppTextStyles.heading3),
            const SizedBox(height: 12),
            ...summary.dailyBreakdown.map((day) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: AppCard(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppDateUtils.formatDayName(day.date),
                          style: AppTextStyles.bodyLarge,
                        ),
                        Text(
                          '${day.totalEvents} jadwal • ${day.totalTodosCompleted} tugas',
                          style: AppTextStyles.caption,
                        ),
                        Text(
                          CurrencyFormatter.format(day.totalExpense),
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.expenseAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  const _StatRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodyMedium),
        Text(value, style: AppTextStyles.bodyLarge),
      ],
    );
  }
}