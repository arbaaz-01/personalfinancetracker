class BudgetModel {
  final String? id;
  final String category;
  final double amount;
  final String month; // Format: "YYYY-MM"
  final String userId;
  
  BudgetModel({
    this.id,
    required this.category,
    required this.amount,
    required this.month,
    required this.userId,
  });
}
