class TransactionModel {
  final String? id;
  final double amount;
  final String category;
  final String description;
  final DateTime date;
  final bool isExpense;
  
  TransactionModel({
    this.id,
    required this.amount,
    required this.category,
    required this.description,
    required this.date,
    required this.isExpense,
  });
}
