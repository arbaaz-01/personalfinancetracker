import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/budget_model.dart';
import '../models/transaction_model.dart';

class BudgetService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection reference
  CollectionReference get budgetsCollection => _firestore
      .collection('users')
      .doc(_auth.currentUser!.uid)
      .collection('budgets');

  // Add budget
  Future<void> addBudget(BudgetModel budget) async {
    // Check if budget for this category and month already exists
    QuerySnapshot existingBudgets = await budgetsCollection
        .where('category', isEqualTo: budget.category)
        .where('month', isEqualTo: budget.month)
        .get();

    if (existingBudgets.docs.isNotEmpty) {
      // Update existing budget
      String docId = existingBudgets.docs.first.id;
      return await budgetsCollection.doc(docId).update({
        'amount': budget.amount,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } else {
      // Create new budget
      await budgetsCollection.add({
        'category': budget.category,
        'amount': budget.amount,
        'month': budget.month,
        'userId': _auth.currentUser!.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  // Update budget
  Future<void> updateBudget(String id, BudgetModel budget) async {
    return await budgetsCollection.doc(id).update({
      'category': budget.category,
      'amount': budget.amount,
      'month': budget.month,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Delete budget
  Future<void> deleteBudget(String id) async {
    return await budgetsCollection.doc(id).delete();
  }

  // Get all budgets for a specific month
  Stream<List<BudgetModel>> getBudgetsByMonth(String month) {
    return budgetsCollection
        .where('month', isEqualTo: month)
        .snapshots()
        .map(_budgetsFromSnapshot);
  }

  // Helper method to convert snapshot to list of budgets
  List<BudgetModel> _budgetsFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      return BudgetModel(
        id: doc.id,
        category: data['category'] ?? '',
        amount: (data['amount'] is int)
            ? (data['amount'] as int).toDouble()
            : data['amount'] ?? 0.0,
        month: data['month'] ?? '',
        userId: data['userId'] ?? '',
      );
    }).toList();
  }

  // Get budget for a specific category and month
  Future<BudgetModel?> getBudgetByCategoryAndMonth(
      String category, String month) async {
    try {
      QuerySnapshot snapshot = await budgetsCollection
          .where('category', isEqualTo: category)
          .where('month', isEqualTo: month)
          .get();

      if (snapshot.docs.isEmpty) {
        return null;
      }

      DocumentSnapshot doc = snapshot.docs.first;
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      return BudgetModel(
        id: doc.id,
        category: data['category'] ?? '',
        amount: (data['amount'] is int)
            ? (data['amount'] as int).toDouble()
            : data['amount'] ?? 0.0,
        month: data['month'] ?? '',
        userId: data['userId'] ?? '',
      );
    } catch (e) {
      print('Error getting budget: $e');
      return null;
    }
  }

  // Calculate spending for a specific category and month
  Future<double> getSpendingForCategoryAndMonth(
      String category, String month) async {
    try {
      // Parse the month string to get year and month
      int year = int.parse(month.split('-')[0]);
      int monthNum = int.parse(month.split('-')[1]);

      // Create DateTime objects for the start and end of the month
      DateTime startDate = DateTime(year, monthNum, 1);
      DateTime endDate = DateTime(year, monthNum + 1, 0, 23, 59, 59);

      // Get transactions for this category and date range
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('transactions')
          .where('category', isEqualTo: category)
          .where('isExpense', isEqualTo: true)
          .where('date', isGreaterThanOrEqualTo: startDate)
          .where('date', isLessThanOrEqualTo: endDate)
          .get();

      // Calculate total spending
      double totalSpending = 0;
      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        var amount = data['amount'];
        if (amount is int) {
          totalSpending += amount.toDouble();
        } else if (amount is double) {
          totalSpending += amount;
        }
      }

      return totalSpending;
    } catch (e) {
      print('Error calculating spending: $e');
      return 0.0;
    }
  }

  // Get budget progress for all categories in a month
  Future<List<Map<String, dynamic>>> getBudgetProgressForMonth(
      String month) async {
    try {
      List<BudgetModel> budgets = await getBudgetsByMonth(month).first;
      List<Map<String, dynamic>> budgetProgress = [];

      for (var budget in budgets) {
        double spending =
            await getSpendingForCategoryAndMonth(budget.category, month);
        double percentage =
            budget.amount > 0 ? (spending / budget.amount) * 100 : 0;

        budgetProgress.add({
          'budget': budget,
          'spending': spending,
          'percentage': percentage,
          'remaining': budget.amount - spending,
        });
      }

      return budgetProgress;
    } catch (e) {
      print('Error getting budget progress: $e');
      return [];
    }
  }
}
