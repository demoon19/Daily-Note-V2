import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_utils.dart';
import '../../domain/entities/expense_entity.dart';
import '../../providers/expense_providers.dart';

class ExpenseScreen extends ConsumerStatefulWidget {
  const ExpenseScreen({super.key});

  @override
  ConsumerState<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends ConsumerState<ExpenseScreen> {
  @override
  Widget build(BuildContext context) {
    final expensesAsync = ref.watch(expenseListProvider);
    final budget = ref.watch(budgetProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddExpenseDialog(context, ref),
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
                  Text('EXPENSE TRACKER', style: AppTextStyles.eyebrow.copyWith(letterSpacing: 2)),
                  const SizedBox(height: 4),
                  const Text(
                    'Pengeluaran',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
            ),

            Expanded(
              child: expensesAsync.when(
                data: (expenses) {
                  final now = DateTime.now();
                  final thisMonthExpenses = expenses.where((e) => e.datetime.year == now.year && e.datetime.month == now.month).toList();
                  final totalThisMonth = thisMonthExpenses.fold<double>(0, (sum, e) => sum + e.amount);
                  
                  final isOverBudget = totalThisMonth > budget;
                  final double progress = (budget > 0) ? (totalThisMonth / budget).clamp(0.0, 1.0) : 0.0;
                  final int pct = (budget > 0) ? ((totalThisMonth / budget) * 100).toInt() : 0;

                  // Group by category
                  Map<String, double> categorySums = {};
                  for (var e in thisMonthExpenses) {
                    final cat = e.category != null && e.category!.trim().isNotEmpty 
                        ? e.category!.trim() 
                        : 'Lainnya';
                    categorySums[cat] = (categorySums[cat] ?? 0) + e.amount;
                  }
                  final sortedCategories = categorySums.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

                  return ListView(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 80),
                    children: [
                      // Summary Card
                      GestureDetector(
                        onLongPress: () => _showEditBudgetDialog(context, ref, budget),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.rose.withOpacity(0.3), width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.rose.withOpacity(0.05),
                                blurRadius: 20,
                                spreadRadius: 5,
                              )
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Total bulan ini', style: TextStyle(color: AppColors.textDisabled, fontSize: 13)),
                              const SizedBox(height: 8),
                              Text(
                                CurrencyFormatter.format(totalThisMonth),
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: isOverBudget ? AppColors.rose : Colors.white,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: AppColors.line,
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                      child: FractionallySizedBox(
                                        alignment: Alignment.centerLeft,
                                        widthFactor: progress,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(3),
                                            gradient: LinearGradient(
                                              colors: [AppColors.rose, AppColors.violet, AppColors.cyan.withOpacity(0.8)],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    '$pct% budget',
                                    style: AppTextStyles.caption.copyWith(fontFamily: AppTextStyles.fontMono.fontFamily, color: AppColors.textDisabled),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Kategori Teratas
                      Text('KATEGORI TERATAS', style: AppTextStyles.eyebrow.copyWith(letterSpacing: 2)),
                      const SizedBox(height: 12),

                      if (sortedCategories.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Center(child: Text('Belum ada pengeluaran bulan ini.', style: TextStyle(color: AppColors.textDisabled))),
                        )
                      else
                        ...sortedCategories.map((entry) => _buildCategoryCard(entry.key, entry.value)),
                        
                      const SizedBox(height: 24),
                      Text('RIWAYAT BULAN INI', style: AppTextStyles.eyebrow.copyWith(letterSpacing: 2)),
                      const SizedBox(height: 12),
                      if (thisMonthExpenses.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Center(child: Text('Tidak ada riwayat.', style: TextStyle(color: AppColors.textDisabled))),
                        )
                      else
                        ...thisMonthExpenses.map((e) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(e.title, style: const TextStyle(color: Colors.white, fontSize: 14)),
                          subtitle: Text('${e.category ?? 'Lainnya'} • ${AppDateUtils.formatDate(e.datetime)}', style: const TextStyle(color: AppColors.textDisabled, fontSize: 12)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(CurrencyFormatter.format(e.amount), style: AppTextStyles.caption.copyWith(fontFamily: AppTextStyles.fontMono.fontFamily, color: Colors.white)),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, size: 16, color: AppColors.textDisabled),
                                onPressed: () => ref.read(expenseActionsProvider.notifier).deleteExpense(e.id!),
                              )
                            ],
                          ),
                        ))
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text('Error: $err')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(String title, double amount) {
    IconData iconData;
    Color iconColor;

    final lowerTitle = title.toLowerCase();
    if (lowerTitle.contains('transport') || lowerTitle.contains('bensin') || lowerTitle.contains('gojek') || lowerTitle.contains('grab')) {
      iconData = Icons.directions_car_outlined;
      iconColor = AppColors.cyan;
    } else if (lowerTitle.contains('makan') || lowerTitle.contains('minum') || lowerTitle.contains('food')) {
      iconData = Icons.restaurant_outlined;
      iconColor = AppColors.amber;
    } else if (lowerTitle.contains('kuliah') || lowerTitle.contains('alat') || lowerTitle.contains('belajar')) {
      iconData = Icons.menu_book_outlined;
      iconColor = AppColors.violet;
    } else {
      iconData = Icons.favorite_border;
      iconColor = AppColors.rose;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(iconData, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
          ),
          Text(
            CurrencyFormatter.format(amount),
            style: AppTextStyles.bodyMedium.copyWith(
              fontFamily: AppTextStyles.fontMono.fontFamily,
              color: iconColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
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
                  ).then((_) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Pengeluaran berhasil dicatat!')),
                  );
                }
              });
              Navigator.pop(ctx);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showEditBudgetDialog(BuildContext context, WidgetRef ref, double currentBudget) {
    final budgetController = TextEditingController(text: currentBudget.toInt().toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Set Budget Bulanan'),
        content: TextField(
          controller: budgetController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: 'Masukkan jumlah (mis: 3000000)'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          TextButton(
            onPressed: () {
              final newBudget = double.tryParse(budgetController.text.trim()) ?? 3000000.0;
              ref.read(budgetProvider.notifier).setBudget(newBudget);
              Navigator.pop(ctx);
            },
            child: const Text('Simpan'),
          )
        ],
      ),
    );
  }
}