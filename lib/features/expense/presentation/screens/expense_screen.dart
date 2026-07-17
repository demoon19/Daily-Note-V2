import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_utils.dart';
import '../../providers/expense_providers.dart';

class ExpenseScreen extends ConsumerWidget {
  const ExpenseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(expenseListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Pengeluaran', style: AppTextStyles.heading3)),
      body: expensesAsync.when(
        data: (expenses) {
          if (expenses.isEmpty) return const Center(child: Text('Belum ada pengeluaran.'));
          final total = expenses.fold<double>(0, (sum, e) => sum + e.amount);
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: AppCard(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total', style: AppTextStyles.bodyMedium),
                      Text(CurrencyFormatter.format(total), style: AppTextStyles.heading3),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: expenses.length,
                  itemBuilder: (context, index) {
                    final e = expenses[index];
                    return ListTile(
                      title: Text(e.title),
                      subtitle: Text('${e.category ?? '-'} • ${AppDateUtils.formatDate(e.datetime)}'),
                      trailing: Text(CurrencyFormatter.format(e.amount)),
                      onLongPress: () =>
                          ref.read(expenseActionsProvider.notifier).deleteExpense(e.id!),
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }
}