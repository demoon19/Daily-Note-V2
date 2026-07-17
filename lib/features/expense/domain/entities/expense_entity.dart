class ExpenseEntity {
  final int? id;
  final String title;
  final double amount;
  final String? category;
  final DateTime datetime;

  const ExpenseEntity({
    this.id,
    required this.title,
    required this.amount,
    this.category,
    required this.datetime,
  });
}