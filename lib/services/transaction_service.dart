import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/transaction_model.dart';

class TransactionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection reference
  CollectionReference get transactionsCollection => _firestore
      .collection('users')
      .doc(_auth.currentUser!.uid)
      .collection('transactions');

  // Add transaction
  Future<void> addTransaction(TransactionModel transaction) async {
    await transactionsCollection.add({
      'amount': transaction.amount,
      'category': transaction.category,
      'description': transaction.description,
      'date': transaction.date,
      'isExpense': transaction.isExpense,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Update transaction
  Future<void> updateTransaction(
      String id, TransactionModel transaction) async {
    return await transactionsCollection.doc(id).update({
      'amount': transaction.amount,
      'category': transaction.category,
      'description': transaction.description,
      'date': transaction.date,
      'isExpense': transaction.isExpense,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Delete transaction
  Future<void> deleteTransaction(String id) async {
    return await transactionsCollection.doc(id).delete();
  }

  // Get transactions
  Stream<List<TransactionModel>> getTransactions() {
    return transactionsCollection
        .orderBy('date', descending: true)
        .limit(50) // Limit to prevent loading too many transactions
        .snapshots()
        .map(_transactionsFromSnapshot);
  }

  // Get transactions by date range
  Stream<List<TransactionModel>> getTransactionsByDateRange(
      DateTime start, DateTime end) {
    // Create a timestamp for the end of the day
    DateTime endOfDay = DateTime(end.year, end.month, end.day, 23, 59, 59);

    return transactionsCollection
        .where('date', isGreaterThanOrEqualTo: start)
        .where('date', isLessThanOrEqualTo: endOfDay)
        .orderBy('date', descending: true)
        .snapshots()
        .map(_transactionsFromSnapshot);
  }

  // Get transactions by category
  Stream<List<TransactionModel>> getTransactionsByCategory(String category) {
    // Create a composite index in Firestore for this query
    return transactionsCollection
        .where('category', isEqualTo: category)
        .orderBy('date', descending: true)
        .snapshots()
        .map(_transactionsFromSnapshot);
  }

  // Helper method to convert snapshot to list of transactions
  List<TransactionModel> _transactionsFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      return TransactionModel(
        id: doc.id,
        amount: data['amount'] ?? 0.0,
        category: data['category'] ?? 'Other',
        description: data['description'] ?? '',
        date: (data['date'] as Timestamp).toDate(),
        isExpense: data['isExpense'] ?? true,
      );
    }).toList();
  }

  // Get total income for a specific period
  Future<double> getTotalIncome(DateTime start, DateTime end) async {
    DateTime endOfDay = DateTime(end.year, end.month, end.day, 23, 59, 59);

    QuerySnapshot snapshot = await transactionsCollection
        .where('date', isGreaterThanOrEqualTo: start)
        .where('date', isLessThanOrEqualTo: endOfDay)
        .where('isExpense', isEqualTo: false)
        .get();

    double total = 0;
    for (var doc in snapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      total += data['amount'] ?? 0.0;
    }

    return total;
  }

  // Get total expense for a specific period
  Future<double> getTotalExpense(DateTime start, DateTime end) async {
    DateTime endOfDay = DateTime(end.year, end.month, end.day, 23, 59, 59);

    QuerySnapshot snapshot = await transactionsCollection
        .where('date', isGreaterThanOrEqualTo: start)
        .where('date', isLessThanOrEqualTo: endOfDay)
        .where('isExpense', isEqualTo: true)
        .get();

    double total = 0;
    for (var doc in snapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      total += data['amount'] ?? 0.0;
    }

    return total;
  }
}
