import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../providers/home_providers.dart';

class DailySummaryCard extends ConsumerWidget {
  const DailySummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(homeSummaryProvider);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ringkasan Hari Ini', style: AppTextStyles.heading3),
          const SizedBox(height: 12),
          summaryAsync.when(
            data: (summary) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${summary.totalEventsToday} jadwal', style: AppTextStyles.bodyMedium),
                const SizedBox(height: 4),
                Text('${summary.totalPendingTodos} tugas belum selesai', style: AppTextStyles.bodyMedium),
                const SizedBox(height: 4),
                Text('${summary.totalUpcomingReminders} reminder mendatang', style: AppTextStyles.bodyMedium),
                const SizedBox(height: 4),
                Text(
                  'Pengeluaran: ${CurrencyFormatter.format(summary.totalExpenseToday)}',
                  style: AppTextStyles.bodyMedium,
                ),
              ],
            ),
            loading: () => const SizedBox(
              height: 16,
              width: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            error: (_, __) => const Text('-'),
          ),
        ],
      ),
    );
  }
}