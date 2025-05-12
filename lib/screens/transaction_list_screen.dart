import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';
import '../services/transaction_service.dart';
import '../widgets/budget_progress_card.dart';
import 'edit_transaction_screen.dart';
import '../utils/theme_config.dart';

class TransactionListScreen extends StatefulWidget {
  @override
  _TransactionListScreenState createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  final TransactionService _transactionService = TransactionService();
  String _selectedCategory = 'All';
  DateTime _startDate = DateTime.now().subtract(Duration(days: 30));
  DateTime _endDate = DateTime.now();
  bool _isFiltering = false;
  bool _isLoading = false;

  List<String> categories = [
    'All',
    'Food',
    'Transportation',
    'Entertainment',
    'Bills',
    'Shopping',
    'Health',
    'Education',
    'Salary',
    'Freelance',
    'Investments',
    'Gifts',
    'Other Income',
    'Other Expense',
  ];

  @override
  Widget build(BuildContext context) {
    // Get current month in YYYY-MM format for budget tracking
    String currentMonth =
        '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}';

    return Scaffold(
      body: Column(
        children: [
          _buildFilterBar(),
          // Show budget progress for the selected category if filtering by category
          if (_isFiltering && _selectedCategory != 'All')
            BudgetProgressCard(
              category: _selectedCategory,
              month: currentMonth,
            ),
          Expanded(
            child: _buildTransactionList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Card(
      margin: EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isFiltering
                      ? ThemeConfig.expenseColor
                      : Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
                icon: Icon(_isFiltering ? Icons.clear : Icons.filter_list),
                label: Text(_isFiltering ? 'Clear Filters' : 'Filter'),
                onPressed: () {
                  setState(() {
                    if (_isFiltering) {
                      _selectedCategory = 'All';
                      _startDate = DateTime.now().subtract(Duration(days: 30));
                      _endDate = DateTime.now();
                      _isFiltering = false;
                    } else {
                      _showFilterDialog();
                    }
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionList() {
    Stream<List<TransactionModel>> stream;

    try {
      if (_selectedCategory != 'All' && _isFiltering) {
        stream =
            _transactionService.getTransactionsByCategory(_selectedCategory);
      } else if (_isFiltering) {
        stream = _transactionService.getTransactionsByDateRange(
            _startDate, _endDate);
      } else {
        stream = _transactionService.getTransactions();
      }
    } catch (e) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 70,
              color: ThemeConfig.expenseColor.withOpacity(0.7),
            ),
            SizedBox(height: 16),
            Text(
              'Error loading transactions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: ThemeConfig.expenseColor,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              e.toString(),
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _isFiltering = false;
                  _selectedCategory = 'All';
                });
              },
              icon: Icon(Icons.refresh),
              label: Text('Reset Filters'),
            ),
          ],
        ),
      );
    }

    return StreamBuilder<List<TransactionModel>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 70,
                  color: ThemeConfig.expenseColor.withOpacity(0.7),
                ),
                SizedBox(height: 16),
                Text(
                  'Error loading transactions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: ThemeConfig.expenseColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Text(
                    snapshot.error.toString(),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _isFiltering = false;
                      _selectedCategory = 'All';
                    });
                  },
                  icon: Icon(Icons.refresh),
                  label: Text('Reset Filters'),
                ),
              ],
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.receipt_long,
                  size: 70,
                  color: Colors.grey.withOpacity(0.5),
                ),
                SizedBox(height: 16),
                Text(
                  _isFiltering
                      ? 'No transactions found with current filters'
                      : 'No transactions found',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (_isFiltering) ...[
                  SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _isFiltering = false;
                        _selectedCategory = 'All';
                      });
                    },
                    icon: Icon(Icons.clear),
                    label: Text('Clear Filters'),
                  ),
                ],
              ],
            ),
          );
        }

        // Group transactions by date
        Map<String, List<TransactionModel>> groupedTransactions = {};
        for (var transaction in snapshot.data!) {
          String dateKey = DateFormat('yyyy-MM-dd').format(transaction.date);
          if (!groupedTransactions.containsKey(dateKey)) {
            groupedTransactions[dateKey] = [];
          }
          groupedTransactions[dateKey]!.add(transaction);
        }

        // Sort dates in descending order
        List<String> sortedDates = groupedTransactions.keys.toList()
          ..sort((a, b) => b.compareTo(a));

        return ListView.builder(
          itemCount: sortedDates.length,
          itemBuilder: (context, index) {
            String dateKey = sortedDates[index];
            List<TransactionModel> dayTransactions =
                groupedTransactions[dateKey]!;
            DateTime date = DateFormat('yyyy-MM-dd').parse(dateKey);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          DateFormat.yMMMd().format(date),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          indent: 8,
                          endIndent: 8,
                        ),
                      ),
                    ],
                  ),
                ),
                ...dayTransactions
                    .map((transaction) => _buildTransactionCard(transaction))
                    .toList(),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildTransactionCard(TransactionModel transaction) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: transaction.isExpense
              ? ThemeConfig.expenseColor.withOpacity(0.2)
              : ThemeConfig.incomeColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  EditTransactionScreen(transaction: transaction),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: transaction.isExpense
                      ? ThemeConfig.expenseColor.withOpacity(0.1)
                      : ThemeConfig.incomeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  transaction.isExpense ? Icons.remove : Icons.add,
                  color: transaction.isExpense
                      ? ThemeConfig.expenseColor
                      : ThemeConfig.incomeColor,
                  size: 28,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.description,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      transaction.category,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${transaction.isExpense ? '-' : '+'} ₹${transaction.amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: transaction.isExpense
                          ? ThemeConfig.expenseColor
                          : ThemeConfig.incomeColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    DateFormat.jm().format(transaction.date),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Filter Transactions'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Category',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: _selectedCategory,
                          items: categories.map((String category) {
                            return DropdownMenuItem<String>(
                              value: category,
                              child: Text(category),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedCategory = newValue!;
                            });
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Date Range',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
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
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 12),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                DateFormat('MMM dd, yyyy').format(_startDate),
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text('to'),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
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
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 12),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                DateFormat('MMM dd, yyyy').format(_endDate),
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  child: Text('Apply'),
                  onPressed: () {
                    this.setState(() {
                      _isFiltering = true;
                    });
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
