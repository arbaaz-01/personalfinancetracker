import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/budget_model.dart';
import '../services/budget_service.dart';
import '../utils/theme_config.dart';

class AddBudgetScreen extends StatefulWidget {
  final String selectedMonth;
  final BudgetModel? budget;

  AddBudgetScreen({
    required this.selectedMonth,
    this.budget,
  });

  @override
  _AddBudgetScreenState createState() => _AddBudgetScreenState();
}

class _AddBudgetScreenState extends State<AddBudgetScreen> {
  final _formKey = GlobalKey<FormState>();
  final BudgetService _budgetService = BudgetService();

  String _category = 'Food';
  double _amount = 0;
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

  @override
  void initState() {
    super.initState();
    if (widget.budget != null) {
      _category = widget.budget!.category;
      _amount = widget.budget!.amount;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Parse the selected month
    int year = int.parse(widget.selectedMonth.split('-')[0]);
    int month = int.parse(widget.selectedMonth.split('-')[1]);
    DateTime selectedDate = DateTime(year, month);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.budget == null ? 'Add Budget' : 'Edit Budget'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.calendar_today,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Budget for',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            DateFormat('MMMM yyyy').format(selectedDate),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),
              Text(
                'Category',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 8),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: Icon(Icons.category),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                value: _category,
                items: expenseCategories.map((String category) {
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
              ),
              SizedBox(height: 24),
              Text(
                'Budget Amount',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 8),
              TextFormField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: Icon(Icons.currency_rupee),
                  hintText: 'Enter amount',
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                initialValue: widget.budget != null ? _amount.toString() : '',
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (val) => val!.isEmpty ||
                        double.tryParse(val) == null ||
                        double.parse(val) <= 0
                    ? 'Enter a valid amount'
                    : null,
                onChanged: (val) {
                  setState(() => _amount = double.tryParse(val) ?? 0);
                },
              ),
              SizedBox(height: 32),
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          widget.budget == null
                              ? 'Add Budget'
                              : 'Update Budget',
                          style: TextStyle(fontSize: 16),
                        ),
                        onPressed: _submitForm,
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        BudgetModel budget = BudgetModel(
          id: widget.budget?.id,
          category: _category,
          amount: _amount,
          month: widget.selectedMonth,
          userId: '', // Will be set by the service
        );

        if (widget.budget == null) {
          await _budgetService.addBudget(budget);
        } else {
          await _budgetService.updateBudget(widget.budget!.id!, budget);
        }

        setState(() => _isLoading = false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.budget == null
                ? 'Budget added successfully'
                : 'Budget updated successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );

        // Return true to indicate success
        Navigator.pop(context, true);
      } catch (e) {
        setState(() => _isLoading = false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
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
