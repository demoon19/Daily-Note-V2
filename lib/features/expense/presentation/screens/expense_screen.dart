import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_utils.dart';
import '../../domain/entities/expense_entity.dart';
import '../../providers/expense_providers.dart';

class ExpenseScreen extends ConsumerWidget {
  const ExpenseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(expenseListProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Pengeluaran', style: AppTextStyles.heading3)),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddExpenseDialog(context, ref),
        child: const Icon(Icons.add),
      ),
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

  void _showAddExpenseDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    final categoryController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Catat Pengeluaran'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(hintText: 'Judul (mis: Makan Siang)'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: 'Jumlah (mis: 25000)'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: categoryController,
              decoration: const InputDecoration(hintText: 'Kategori (opsional)'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          TextButton(
            onPressed: () {
              if (titleController.text.trim().isEmpty || amountController.text.trim().isEmpty) return;
              final amount = double.tryParse(amountController.text.trim()) ?? 0.0;
              if (amount <= 0) return;
              
              ref.read(expenseActionsProvider.notifier).addExpense(
                    ExpenseEntity(
                      title: titleController.text.trim(),
                      amount: amount,
                      category: categoryController.text.trim().isEmpty ? null : categoryController.text.trim(),
                      datetime: DateTime.now(),
                    ),
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