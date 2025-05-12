import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';
import '../services/transaction_service.dart';
import '../services/budget_service.dart';
import '../utils/theme_config.dart';
import 'add_budget_screen.dart';

class SummaryScreen extends StatefulWidget {
  @override
  _SummaryScreenState createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  final TransactionService _transactionService = TransactionService();
  final BudgetService _budgetService = BudgetService();
  DateTime _startDate = DateTime.now().subtract(Duration(days: 30));
  DateTime _endDate = DateTime.now();
  String _currentMonth = '';
  bool _isLoadingBudgets = true;
  List<Map<String, dynamic>> _budgetProgress = [];

  @override
  void initState() {
    super.initState();
    // Set current month in YYYY-MM format for budget tracking
    _currentMonth =
        '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}';
    _loadBudgetProgress();
  }

  Future<void> _loadBudgetProgress() async {
    setState(() {
      _isLoadingBudgets = true;
    });

    try {
      List<Map<String, dynamic>> progress =
          await _budgetService.getBudgetProgressForMonth(_currentMonth);

      if (mounted) {
        setState(() {
          _budgetProgress = progress;
          _isLoadingBudgets = false;
        });
      }

      // Debug output
      print(
          'Loaded ${_budgetProgress.length} budgets for $_currentMonth in Summary');
    } catch (e) {
      print('Error loading budget progress in Summary: $e');
      if (mounted) {
        setState(() {
          _isLoadingBudgets = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadBudgetProgress();
        },
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDateRangeCard(),
              SizedBox(height: 20),
              StreamBuilder<List<TransactionModel>>(
                stream: _transactionService.getTransactionsByDateRange(
                    _startDate, _endDate),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return _buildErrorWidget(snapshot.error.toString());
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return _buildEmptyDataWidget(
                        'No transactions found in this date range');
                  }

                  List<TransactionModel> transactions = snapshot.data!;
                  double totalIncome = transactions
                      .where((t) => !t.isExpense)
                      .fold(0, (sum, t) => sum + t.amount);
                  double totalExpense = transactions
                      .where((t) => t.isExpense)
                      .fold(0, (sum, t) => sum + t.amount);
                  double balance = totalIncome - totalExpense;

                  Map<String, double> categoryTotals = {};

                  for (var transaction
                      in transactions.where((t) => t.isExpense)) {
                    categoryTotals.update(
                      transaction.category,
                      (value) => value + transaction.amount,
                      ifAbsent: () => transaction.amount,
                    );
                  }

                  List<MapEntry<String, double>> sortedCategories =
                      categoryTotals.entries.toList()
                        ..sort((a, b) => b.value.compareTo(a.value));

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSummaryCard(
                        'Monthly Summary',
                        [
                          {
                            'title': 'Total Income',
                            'amount': totalIncome,
                            'color': ThemeConfig.incomeColor
                          },
                          {
                            'title': 'Total Expenses',
                            'amount': totalExpense,
                            'color': ThemeConfig.expenseColor
                          },
                          {
                            'title': 'Balance',
                            'amount': balance,
                            'color': balance >= 0
                                ? Colors.blue
                                : ThemeConfig.expenseColor
                          },
                        ],
                      ),
                      SizedBox(height: 24),
                      _buildBudgetStatusSection(),
                      SizedBox(height: 24),
                      Text(
                        'Expense Breakdown',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      ...sortedCategories
                          .map((entry) => _buildCategoryItem(
                                entry.key,
                                entry.value,
                                totalExpense,
                              ))
                          .toList(),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateRangeCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Date Range',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: Icon(Icons.calendar_today, size: 16),
                    label: Text(DateFormat('MMM dd, yyyy').format(_startDate)),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: _startDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null && picked != _startDate) {
                        setState(() {
                          _startDate = picked;
                        });
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text('to'),
                ),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: Icon(Icons.calendar_today, size: 16),
                    label: Text(DateFormat('MMM dd, yyyy').format(_endDate)),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: _endDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null && picked != _endDate) {
                        setState(() {
                          _endDate = picked;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, List<Map<String, dynamic>> items) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            ...items
                .map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            item['title'],
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '₹${item['amount'].toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: item['color'],
                            ),
                          ),
                        ],
                      ),
                    ))
                .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetStatusSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Budget Status (Current Month)',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),
        _isLoadingBudgets
            ? Center(child: CircularProgressIndicator())
            : _budgetProgress.isEmpty
                ? _buildNoBudgetsCard()
                : Column(
                    children: _budgetProgress.map((item) {
                      return _buildBudgetProgressItem(item);
                    }).toList(),
                  ),
      ],
    );
  }

  Widget _buildNoBudgetsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text(
              'No budgets set for this month',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              icon: Icon(Icons.add),
              label: Text('Set a Budget'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddBudgetScreen(
                      selectedMonth: _currentMonth,
                    ),
                  ),
                );

                if (result == true) {
                  _loadBudgetProgress();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryItem(String category, double amount, double total) {
    double percentage = total > 0 ? (amount / total) * 100 : 0;

    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  category,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '₹${amount.toStringAsFixed(2)} (${percentage.toStringAsFixed(1)}%)',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percentage / 100,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor),
                minHeight: 6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetProgressItem(Map<String, dynamic> item) {
    final budget = item['budget'];
    final spending = item['spending'];
    final percentage = item['percentage'];
    final remaining = item['remaining'];

    Color progressColor = percentage < 80
        ? ThemeConfig.budgetGoodColor
        : percentage < 100
            ? ThemeConfig.budgetWarningColor
            : ThemeConfig.budgetDangerColor;

    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.category,
                        color: Theme.of(context).primaryColor,
                        size: 16,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      budget.category,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Text(
                  '₹${spending.toStringAsFixed(2)} / ₹${budget.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percentage / 100 > 1 ? 1 : percentage / 100,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                minHeight: 6,
              ),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: progressColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${percentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: progressColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                Text(
                  remaining >= 0
                      ? 'Remaining: ₹${remaining.toStringAsFixed(2)}'
                      : 'Over budget: ₹${(-remaining).toStringAsFixed(2)}',
                  style: TextStyle(
                    color: remaining >= 0
                        ? ThemeConfig.budgetGoodColor
                        : ThemeConfig.budgetDangerColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyDataWidget(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            Icon(
              Icons.bar_chart,
              size: 70,
              color: Colors.grey.withOpacity(0.5),
            ),
            SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              size: 70,
              color: ThemeConfig.expenseColor.withOpacity(0.7),
            ),
            SizedBox(height: 16),
            Text(
              'Error loading data',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: ThemeConfig.expenseColor,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              error,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
