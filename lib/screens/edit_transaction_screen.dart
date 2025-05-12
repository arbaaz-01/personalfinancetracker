import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';
import '../services/transaction_service.dart';

class EditTransactionScreen extends StatefulWidget {
  final TransactionModel transaction;

  EditTransactionScreen({required this.transaction});

  @override
  _EditTransactionScreenState createState() => _EditTransactionScreenState();
}

class _EditTransactionScreenState extends State<EditTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final TransactionService _transactionService = TransactionService();

  late double _amount;
  late String _description;
  late String _category;
  late DateTime _date;
  late bool _isExpense;
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
    _amount = widget.transaction.amount;
    _description = widget.transaction.description;
    _category = widget.transaction.category;
    _date = widget.transaction.date;
    _isExpense = widget.transaction.isExpense;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Transaction'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              _showDeleteConfirmation();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isExpense
                            ? Theme.of(context).primaryColor
                            : Colors.grey,
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text('Expense'),
                      onPressed: () {
                        setState(() {
                          _isExpense = true;
                          _category = expenseCategories.contains(_category)
                              ? _category
                              : expenseCategories.first;
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: !_isExpense
                            ? Theme.of(context).primaryColor
                            : Colors.grey,
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text('Income'),
                      onPressed: () {
                        setState(() {
                          _isExpense = false;
                          _category = incomeCategories.contains(_category)
                              ? _category
                              : incomeCategories.first;
                        });
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Amount',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.currency_rupee),
                ),
                initialValue: _amount.toString(),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (val) => val!.isEmpty ? 'Enter an amount' : null,
                onChanged: (val) {
                  setState(() => _amount = double.tryParse(val) ?? 0);
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                initialValue: _description,
                validator: (val) => val!.isEmpty ? 'Enter a description' : null,
                onChanged: (val) {
                  setState(() => _description = val);
                },
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                value: _category,
                items: (_isExpense ? expenseCategories : incomeCategories)
                    .map((String category) {
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
              SizedBox(height: 20),
              InkWell(
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _date,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
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
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(DateFormat('MMM dd, yyyy').format(_date)),
                ),
              ),
              SizedBox(height: 30),
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          padding: EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: Text(
                          'Update Transaction',
                          style: TextStyle(fontSize: 16),
                        ),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            setState(() => _isLoading = true);

                            TransactionModel transaction = TransactionModel(
                              id: widget.transaction.id,
                              amount: _amount,
                              category: _category,
                              description: _description,
                              date: _date,
                              isExpense: _isExpense,
                            );

                            await _transactionService.updateTransaction(
                              widget.transaction.id!,
                              transaction,
                            );

                            setState(() => _isLoading = false);

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text('Transaction updated successfully'),
                                backgroundColor: Colors.green,
                              ),
                            );

                            Navigator.pop(context);
                          }
                        },
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Transaction'),
          content: Text('Are you sure you want to delete this transaction?'),
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
                await _transactionService
                    .deleteTransaction(widget.transaction.id!);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Transaction deleted successfully'),
                    backgroundColor: Colors.red,
                  ),
                );

                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
