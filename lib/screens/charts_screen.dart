import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';
import '../services/transaction_service.dart';
import '../utils/theme_config.dart';

class ChartsScreen extends StatefulWidget {
  @override
  _ChartsScreenState createState() => _ChartsScreenState();
}

class _ChartsScreenState extends State<ChartsScreen>
    with SingleTickerProviderStateMixin {
  final TransactionService _transactionService = TransactionService();
  late TabController _tabController;
  DateTime _startDate = DateTime.now().subtract(Duration(days: 30));
  DateTime _endDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Card(
            margin: EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: Icon(Icons.calendar_today, size: 16),
                      label:
                          Text(DateFormat('MMM dd, yyyy').format(_startDate)),
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
            ),
          ),
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
            margin: EdgeInsets.symmetric(horizontal: 16),
            child: TabBar(
              controller: _tabController,
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor:
                  Theme.of(context).textTheme.bodySmall?.color,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                color: Theme.of(context).primaryColor.withOpacity(0.1),
              ),
              tabs: [
                Tab(
                  icon: Icon(Icons.pie_chart),
                  text: 'Pie Chart',
                ),
                Tab(
                  icon: Icon(Icons.bar_chart),
                  text: 'Bar Chart',
                ),
                Tab(
                  icon: Icon(Icons.show_chart),
                  text: 'Line Chart',
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPieChart(),
                _buildBarChart(),
                _buildLineChart(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart() {
    return StreamBuilder<List<TransactionModel>>(
      stream:
          _transactionService.getTransactionsByDateRange(_startDate, _endDate),
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
        Map<String, double> categoryTotals = {};

        for (var transaction in transactions.where((t) => t.isExpense)) {
          categoryTotals.update(
            transaction.category,
            (value) => value + transaction.amount,
            ifAbsent: () => transaction.amount,
          );
        }

        List<MapEntry<String, double>> sortedCategories = categoryTotals.entries
            .toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        double totalExpense =
            sortedCategories.fold(0, (sum, entry) => sum + entry.value);

        List<PieChartSectionData> sections = sortedCategories.isEmpty
            ? []
            : List.generate(
                sortedCategories.length,
                (index) {
                  final category = sortedCategories[index];
                  final percentage = (category.value / totalExpense) * 100;

                  return PieChartSectionData(
                    color: ThemeConfig.categoryColors[
                        index % ThemeConfig.categoryColors.length],
                    value: category.value,
                    title: '${percentage.toStringAsFixed(1)}%',
                    radius: 80,
                    titleStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    titlePositionPercentageOffset: 0.6,
                  );
                },
              );

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                'Expense Categories',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: sortedCategories.isEmpty
                    ? _buildEmptyDataWidget('No expense transactions found')
                    : Column(
                        children: [
                          Expanded(
                            child: PieChart(
                              PieChartData(
                                sections: sections,
                                centerSpaceRadius: 40,
                                sectionsSpace: 2,
                                pieTouchData: PieTouchData(
                                  touchCallback:
                                      (FlTouchEvent event, pieTouchResponse) {
                                    // Handle touch events if needed
                                  },
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 16,
                            runSpacing: 8,
                            children: List.generate(
                              sortedCategories.length,
                              (index) => _buildLegendItem(
                                sortedCategories[index].key,
                                ThemeConfig.categoryColors[
                                    index % ThemeConfig.categoryColors.length],
                                '₹${sortedCategories[index].value.toStringAsFixed(0)}',
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBarChart() {
    return StreamBuilder<List<TransactionModel>>(
      stream:
          _transactionService.getTransactionsByDateRange(_startDate, _endDate),
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
        Map<String, Map<String, double>> monthlyData = {};

        for (var transaction in transactions) {
          String month = DateFormat('MMM yyyy').format(transaction.date);

          monthlyData.putIfAbsent(month, () => {'income': 0.0, 'expense': 0.0});

          if (transaction.isExpense) {
            monthlyData[month]!['expense'] =
                monthlyData[month]!['expense']! + transaction.amount;
          } else {
            monthlyData[month]!['income'] =
                monthlyData[month]!['income']! + transaction.amount;
          }
        }

        List<String> months = monthlyData.keys.toList();
        months.sort((a, b) {
          DateTime dateA = DateFormat('MMM yyyy').parse(a);
          DateTime dateB = DateFormat('MMM yyyy').parse(b);
          return dateA.compareTo(dateB);
        });

        if (months.isEmpty) {
          return _buildEmptyDataWidget('No data available for bar chart');
        }

        double maxY = monthlyData.values
                .expand((e) => [e['income']!, e['expense']!])
                .fold(0.0, (a, b) => a > b ? a : b) *
            1.2;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                'Monthly Income vs Expenses',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: maxY > 0 ? maxY : 100.0,
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipColor: (_) => Theme.of(context).cardColor,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          String month = months[groupIndex];
                          String type = rodIndex == 0 ? 'Income' : 'Expense';
                          double value = rod.toY;
                          return BarTooltipItem(
                            '$type: ₹${value.toStringAsFixed(2)}',
                            TextStyle(
                              color: rodIndex == 0
                                  ? ThemeConfig.incomeColor
                                  : ThemeConfig.expenseColor,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) => Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              value.toInt() < months.length
                                  ? months[value.toInt()]
                                  : '',
                              style: TextStyle(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.color,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                          reservedSize: 40,
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) => Text(
                            '₹${value.toInt()}',
                            style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodyMedium?.color,
                              fontSize: 10,
                            ),
                          ),
                          reservedSize: 40,
                        ),
                      ),
                      topTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: maxY / 5,
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: Theme.of(context).dividerTheme.color,
                        strokeWidth: 1,
                        dashArray: [5, 5],
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: List.generate(
                      months.length,
                      (index) {
                        String month = months[index];
                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: monthlyData[month]!['income']!,
                              color: ThemeConfig.incomeColor,
                              width: 16,
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(4)),
                            ),
                            BarChartRodData(
                              toY: monthlyData[month]!['expense']!,
                              color: ThemeConfig.expenseColor,
                              width: 16,
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(4)),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLegendItem('Income', ThemeConfig.incomeColor, null),
                  SizedBox(width: 20),
                  _buildLegendItem('Expense', ThemeConfig.expenseColor, null),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLineChart() {
    return StreamBuilder<List<TransactionModel>>(
      stream:
          _transactionService.getTransactionsByDateRange(_startDate, _endDate),
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
        Map<DateTime, double> dailyBalance = {};

        transactions.sort((a, b) => a.date.compareTo(b.date));

        double runningBalance = 0;
        for (var transaction in transactions) {
          DateTime day = DateTime(
            transaction.date.year,
            transaction.date.month,
            transaction.date.day,
          );

          if (transaction.isExpense) {
            runningBalance -= transaction.amount;
          } else {
            runningBalance += transaction.amount;
          }

          dailyBalance[day] = runningBalance;
        }

        List<DateTime> days = dailyBalance.keys.toList();
        days.sort();

        if (days.isEmpty) {
          return _buildEmptyDataWidget('No data available for line chart');
        }

        List<FlSpot> spots = [];
        for (int i = 0; i < days.length; i++) {
          spots.add(FlSpot(i.toDouble(), dailyBalance[days[i]]!));
        }

        double minY = spots.isNotEmpty
            ? spots.map((e) => e.y).reduce((a, b) => a < b ? a : b) * 1.2
            : -100.0;
        double maxY = spots.isNotEmpty
            ? spots.map((e) => e.y).reduce((a, b) => a > b ? a : b) * 1.2
            : 100.0;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                'Balance Over Time',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: true,
                      horizontalInterval: (maxY - minY) / 5,
                      verticalInterval: 1,
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: Theme.of(context).dividerTheme.color,
                        strokeWidth: 1,
                        dashArray: [5, 5],
                      ),
                      getDrawingVerticalLine: (value) => FlLine(
                        color: Theme.of(context).dividerTheme.color,
                        strokeWidth: 1,
                        dashArray: [5, 5],
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) => Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              value.toInt() < days.length
                                  ? DateFormat('MM/dd')
                                      .format(days[value.toInt()])
                                  : '',
                              style: TextStyle(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.color,
                                fontSize: 10,
                              ),
                            ),
                          ),
                          reservedSize: 30,
                          interval: days.length > 10 ? days.length / 5 : 1,
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) => Text(
                            '₹${value.toInt()}',
                            style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodyMedium?.color,
                              fontSize: 10,
                            ),
                          ),
                          reservedSize: 40,
                          interval: (maxY - minY) / 5,
                        ),
                      ),
                      topTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border(
                        bottom: BorderSide(
                          color: Theme.of(context).dividerTheme.color ??
                              Colors.grey,
                          width: 1,
                        ),
                        left: BorderSide(
                          color: Theme.of(context).dividerTheme.color ??
                              Colors.grey,
                          width: 1,
                        ),
                      ),
                    ),
                    minX: 0,
                    maxX: (days.length - 1).toDouble(),
                    minY: minY,
                    maxY: maxY,
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipColor: (_) => Theme.of(context).cardColor,
                        getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                          return touchedBarSpots.map((barSpot) {
                            final DateTime date = days[barSpot.x.toInt()];
                            return LineTooltipItem(
                              '${DateFormat('MMM dd, yyyy').format(date)}\n₹${barSpot.y.toStringAsFixed(2)}',
                              TextStyle(
                                color: barSpot.y >= 0
                                    ? ThemeConfig.incomeColor
                                    : ThemeConfig.expenseColor,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          }).toList();
                        },
                      ),
                      handleBuiltInTouches: true,
                      touchSpotThreshold: 20,
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        curveSmoothness: 0.3,
                        color: Theme.of(context).primaryColor,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: FlDotData(
                          show: days.length < 15,
                          getDotPainter: (spot, percent, barData, index) =>
                              FlDotCirclePainter(
                            radius: 4,
                            color: Theme.of(context).primaryColor,
                            strokeWidth: 2,
                            strokeColor: Theme.of(context).cardColor,
                          ),
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.2),
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context).primaryColor.withOpacity(0.4),
                              Theme.of(context).primaryColor.withOpacity(0.1),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLegendItem(String title, Color color, String? value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        if (value != null) ...[
          SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildEmptyDataWidget(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
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
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
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
              'Error loading chart data',
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
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {});
              },
              icon: Icon(Icons.refresh),
              label: Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
