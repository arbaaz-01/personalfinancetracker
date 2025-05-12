import 'package:flutter/material.dart';
import '../models/budget_model.dart';
import '../services/budget_service.dart';
import '../utils/theme_config.dart';

class BudgetProgressCard extends StatelessWidget {
  final String category;
  final String month;

  BudgetProgressCard({
    required this.category,
    required this.month,
  });

  @override
  Widget build(BuildContext context) {
    final BudgetService _budgetService = BudgetService();

    return FutureBuilder<BudgetModel?>(
      future: _budgetService.getBudgetByCategoryAndMonth(category, month),
      builder: (context, budgetSnapshot) {
        if (budgetSnapshot.connectionState == ConnectionState.waiting) {
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (!budgetSnapshot.hasData || budgetSnapshot.data == null) {
          return SizedBox(); // No budget set for this category
        }

        BudgetModel budget = budgetSnapshot.data!;

        return FutureBuilder<double>(
          future:
              _budgetService.getSpendingForCategoryAndMonth(category, month),
          builder: (context, spendingSnapshot) {
            if (spendingSnapshot.connectionState == ConnectionState.waiting) {
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                ),
              );
            }

            double spending = spendingSnapshot.data ?? 0;
            double percentage =
                budget.amount > 0 ? (spending / budget.amount) * 100 : 0;
            double remaining = budget.amount - spending;

            Color progressColor = percentage < 80
                ? ThemeConfig.budgetGoodColor
                : percentage < 100
                    ? ThemeConfig.budgetWarningColor
                    : ThemeConfig.budgetDangerColor;

            return Card(
              elevation: 2,
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.account_balance_wallet,
                                color: Theme.of(context).primaryColor,
                                size: 20,
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Budget: ${category}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
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
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: percentage / 100 > 1 ? 1 : percentage / 100,
                        backgroundColor: Colors.grey[200],
                        valueColor:
                            AlwaysStoppedAnimation<Color>(progressColor),
                        minHeight: 8,
                      ),
                    ),
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '₹${spending.toStringAsFixed(2)} / ₹${budget.amount.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
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
                            fontSize: 14,
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
      },
    );
  }
}
