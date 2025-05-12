import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';
import '../services/transaction_service.dart';
import '../utils/theme_config.dart';

class AddTransactionScreen extends StatefulWidget {
  @override
  _AddTransactionScreenState createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TransactionService _transactionService = TransactionService();
  late TabController _tabController;

  double _amount = 0;
  String _description = '';
  String _category = 'Food';
  DateTime _date = DateTime.now();
  bool _isExpense = true;
  bool _isLoading = false;

  List<String> expenseCategories = [
    'Food',
    'Transportation',
    'Entertainment',
    'Bills',
    'Shopping',
    'Health',
    'Education',
    'Other Expense',
  ];

  List<String> incomeCategories = [
    'Salary',
    'Freelance',
    'Investments',
    'Gifts',
    'Other Income',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _isExpense = _tabController.index == 0;
          _category =
              _isExpense ? expenseCategories.first : incomeCategories.first;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add Transaction',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 24),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: _tabController.index == 0
                          ? ThemeConfig.expenseColor
                          : ThemeConfig.incomeColor,
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor:
                        Theme.of(context).textTheme.bodyMedium?.color,
                    tabs: [
                      Tab(
                        icon: Icon(Icons.remove_circle_outline),
                        text: 'Expense',
                      ),
                      Tab(
                        icon: Icon(Icons.add_circle_outline),
                        text: 'Income',
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),
                _buildAmountField(),
                SizedBox(height: 16),
                _buildDescriptionField(),
                SizedBox(height: 16),
                _buildCategoryDropdown(),
                SizedBox(height: 16),
                _buildDatePicker(),
                SizedBox(height: 32),
                _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isExpense
                                ? ThemeConfig.expenseColor
                                : ThemeConfig.incomeColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: Icon(_isExpense ? Icons.remove : Icons.add),
                          label: Text(
                            'Add Transaction',
                            style: TextStyle(fontSize: 16),
                          ),
                          onPressed: _submitForm,
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAmountField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Amount',
        hintText: 'Enter amount',
        prefixIcon: Icon(Icons.currency_rupee),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      validator: (val) =>
          val!.isEmpty || double.tryParse(val) == null || double.parse(val) <= 0
              ? 'Enter a valid amount'
              : null,
      onChanged: (val) {
        setState(() => _amount = double.tryParse(val) ?? 0);
      },
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Description',
        hintText: 'What was this for?',
        prefixIcon: Icon(Icons.description),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: (val) => val!.isEmpty ? 'Enter a description' : null,
      onChanged: (val) {
        setState(() => _description = val);
      },
    );
  }

  Widget _buildCategoryDropdown() {
    List<String> categories = _isExpense ? expenseCategories : incomeCategories;

    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Category',
        prefixIcon: Icon(Icons.category),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      value: categories.contains(_category) ? _category : categories.first,
      items: categories.map((String category) {
        return DropdownMenuItem<String>(
          value: category,
          child: Text(category),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _category = newValue!;
        });
      },
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: _date,
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: Theme.of(context).primaryColor,
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null && picked != _date) {
          setState(() {
            _date = picked;
          });
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Date',
          prefixIcon: Icon(Icons.calendar_today),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              DateFormat('MMM dd, yyyy').format(_date),
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            Icon(
              Icons.arrow_drop_down,
              color: Theme.of(context).iconTheme.color,
            ),
          ],
        ),
      ),
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        TransactionModel transaction = TransactionModel(
          amount: _amount,
          category: _category,
          description: _description,
          date: _date,
          isExpense: _isExpense,
        );

        await _transactionService.addTransaction(transaction);

        setState(() {
          _isLoading = false;
          _amount = 0;
          _description = '';
          _category =
              _isExpense ? expenseCategories.first : incomeCategories.first;
          _date = DateTime.now();
          _formKey.currentState?.reset();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Transaction added successfully'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      } catch (e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding transaction: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }
}
