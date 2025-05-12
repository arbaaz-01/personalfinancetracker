import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/budget_model.dart';
import '../services/budget_service.dart';
import 'add_budget_screen.dart';
import '../utils/theme_config.dart';

class BudgetScreen extends StatefulWidget {
  @override
  _BudgetScreenState createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final BudgetService _budgetService = BudgetService();
  String _selectedMonth = '';
  bool _isLoading = true;
  List<Map<String, dynamic>> _budgetProgress = [];

  @override
  void initState() {
    super.initState();
    // Set default month to current month
    DateTime now = DateTime.now();
    _selectedMonth = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    _loadBudgetProgress();
  }

  Future<void> _loadBudgetProgress() async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<Map<String, dynamic>> progress =
          await _budgetService.getBudgetProgressForMonth(_selectedMonth);

      if (mounted) {
        setState(() {
          _budgetProgress = progress;
          _isLoading = false;
        });
      }

      // Debug output
      print('Loaded ${_budgetProgress.length} budgets for $_selectedMonth');
      for (var item in _budgetProgress) {
        print(
            'Budget: ${item['budget'].category}, Amount: ${item['budget'].amount}');
      }
    } catch (e) {
      print('Error loading budget progress: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildMonthSelector(),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _budgetProgress.isEmpty
                    ? _buildEmptyState()
                    : _buildBudgetList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  AddBudgetScreen(selectedMonth: _selectedMonth),
            ),
          );

          if (result == true) {
            _loadBudgetProgress();
          }
        },
        child: Icon(Icons.add),
        tooltip: 'Add Budget',
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildMonthSelector() {
    // Parse the selected month
    int year = int.parse(_selectedMonth.split('-')[0]);
    int month = int.parse(_selectedMonth.split('-')[1]);
    DateTime selectedDate = DateTime(year, month);

    return Card(
      margin: EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(Icons.chevron_left),
              onPressed: () {
                setState(() {
                  DateTime newDate =
                      DateTime(selectedDate.year, selectedDate.month - 1);
                  _selectedMonth =
                      '${newDate.year}-${newDate.month.toString().padLeft(2, '0')}';
                  _loadBudgetProgress();
                });
              },
            ),
            Text(
              DateFormat('MMMM yyyy').format(selectedDate),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: Icon(Icons.chevron_right),
              onPressed: () {
                setState(() {
                  DateTime newDate =
                      DateTime(selectedDate.year, selectedDate.month + 1);
                  _selectedMonth =
                      '${newDate.year}-${newDate.month.toString().padLeft(2, '0')}';
                  _loadBudgetProgress();
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.account_balance_wallet,
              size: 50,
              color: Colors.grey[400],
            ),
          ),
          SizedBox(height: 24),
          Text(
            'No budgets set for this month',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      AddBudgetScreen(selectedMonth: _selectedMonth),
                ),
              );

              if (result == true) {
                _loadBudgetProgress();
              }
            },
            child: Text(
              'Set a Budget',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetList() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _budgetProgress.length,
      itemBuilder: (context, index) {
        Map<String, dynamic> item = _budgetProgress[index];
        BudgetModel budget = item['budget'];
        double spending = item['spending'];
        double percentage = item['percentage'];
        double remaining = item['remaining'];

        Color progressColor = percentage < 80
            ? ThemeConfig.budgetGoodColor
            : percentage < 100
                ? ThemeConfig.budgetWarningColor
                : ThemeConfig.budgetDangerColor;

        return Card(
          elevation: 2,
          margin: EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.category,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          budget.category,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    PopupMenuButton(
                      icon: Icon(Icons.more_vert),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 18),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 18, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Delete',
                                  style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (value) async {
                        if (value == 'edit') {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddBudgetScreen(
                                selectedMonth: _selectedMonth,
                                budget: budget,
                              ),
                            ),
                          );

                          if (result == true) {
                            _loadBudgetProgress();
                          }
                        } else if (value == 'delete') {
                          _showDeleteConfirmation(budget);
                        }
                      },
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Budget: ₹${budget.amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Spent: ₹${spending.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16,
                        color: spending > budget.amount ? Colors.red : null,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: percentage / 100 > 1 ? 1 : percentage / 100,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                    minHeight: 8,
                  ),
                ),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: progressColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${percentage.toStringAsFixed(1)}%',
                        style: TextStyle(
                          color: progressColor,
                          fontWeight: FontWeight.bold,
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
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(BudgetModel budget) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Budget'),
          content: Text(
              'Are you sure you want to delete the budget for ${budget.category}?'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: Text('Delete'),
              onPressed: () async {
                await _budgetService.deleteBudget(budget.id!);
                Navigator.of(context).pop();
                _loadBudgetProgress();
              },
            ),
          ],
        );
      },
    );
  }
}
