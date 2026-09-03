import '../db/database.dart';
import '../models/period_type.dart';

class ProfitSummary {
  final double totalCapital;
  final double totalSales;
  final double totalExpenses;
  final double netProfit;
  final double profitMargin;
  final double roi;

  const ProfitSummary({
    required this.totalCapital,
    required this.totalSales,
    required this.totalExpenses,
    required this.netProfit,
    required this.profitMargin,
    required this.roi,
  });

  static const empty = ProfitSummary(
    totalCapital: 0,
    totalSales: 0,
    totalExpenses: 0,
    netProfit: 0,
    profitMargin: 0,
    roi: 0,
  );

  bool get hasData => totalCapital > 0 || totalSales > 0;
  bool get isProfit => netProfit >= 0;
}

class ProfitCalculator {
  static double totalCapital(List<CapitalEntry> entries) =>
      entries.fold(0.0, (sum, e) => sum + e.amount);

  static double totalSales(List<SalesEntry> entries) =>
      entries.fold(0.0, (sum, e) => sum + e.amount);

  static double totalExpenses(List<ExpenseEntry> entries) =>
      entries.fold(0.0, (sum, e) => sum + e.amount);

  static double netProfit({
    required List<SalesEntry> sales,
    required List<CapitalEntry> capital,
    List<ExpenseEntry> expenses = const [],
  }) {
    return totalSales(sales) - totalCapital(capital) - totalExpenses(expenses);
  }

  static double profitMargin(double profit, double sales) =>
      sales == 0 ? 0 : (profit / sales) * 100;

  static double roi({
    required List<SalesEntry> sales,
    required List<CapitalEntry> capital,
    List<ExpenseEntry> expenses = const [],
  }) {
    final c = totalCapital(capital);
    if (c == 0) return 0;
    final profit = netProfit(
      sales: sales,
      capital: capital,
      expenses: expenses,
    );
    return (profit / c) * 100;
  }

  static ProfitSummary compute({
    required List<SalesEntry> sales,
    required List<CapitalEntry> capital,
    List<ExpenseEntry> expenses = const [],
  }) {
    final s = totalSales(sales);
    final c = totalCapital(capital);
    final e = totalExpenses(expenses);
    final profit = s - c - e;
    return ProfitSummary(
      totalCapital: c,
      totalSales: s,
      totalExpenses: e,
      netProfit: profit,
      profitMargin: profitMargin(profit, s),
      roi: roi(sales: sales, capital: capital, expenses: expenses),
    );
  }

  static List<TrendBucket> trend({
    required List<SalesEntry> sales,
    required List<CapitalEntry> capital,
    required Duration bucketSize,
  }) {
    if (sales.isEmpty && capital.isEmpty) return const [];

    final allDates = [
      ...sales.map((e) => e.date),
      ...capital.map((e) => e.date),
    ];
    final earliest = allDates.reduce((a, b) => a.isBefore(b) ? a : b);
    final latest = allDates.reduce((a, b) => a.isAfter(b) ? a : b);

    final buckets = <DateTime, _BucketAcc>{};
    var cursor = DateTime(earliest.year, earliest.month, earliest.day);
    final end = DateTime(latest.year, latest.month, latest.day);

    while (!cursor.isAfter(end)) {
      buckets[cursor] = _BucketAcc();
      cursor = cursor.add(bucketSize);
    }

    for (final s in sales) {
      final key = DateTime(s.date.year, s.date.month, s.date.day);
      final b = buckets[key];
      if (b != null) b.sales += s.amount;
    }
    for (final c in capital) {
      final key = DateTime(c.date.year, c.date.month, c.date.day);
      final b = buckets[key];
      if (b != null) b.capital += c.amount;
    }

    final keys = buckets.keys.toList()..sort();
    return keys.map((k) {
      final b = buckets[k]!;
      return TrendBucket(
        date: k,
        sales: b.sales,
        capital: b.capital,
        profit: b.sales - b.capital,
      );
    }).toList();
  }
}

class TrendBucket {
  final DateTime date;
  final double sales;
  final double capital;
  final double profit;

  const TrendBucket({
    required this.date,
    required this.sales,
    required this.capital,
    required this.profit,
  });
}

class _BucketAcc {
  double sales = 0;
  double capital = 0;
}

extension PeriodBucketing on PeriodType {
  Duration get bucketDuration {
    switch (this) {
      case PeriodType.day:
        return const Duration(days: 1);
      case PeriodType.week:
        return const Duration(days: 7);
      case PeriodType.month:
        return const Duration(days: 30);
      case PeriodType.custom:
        return const Duration(days: 1);
    }
  }
}
