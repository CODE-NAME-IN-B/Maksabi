import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../db/database.dart';
import '../models/period_type.dart';
import '../services/entry_service.dart';
import '../services/profit_calculator.dart' show ProfitCalculator, TrendBucket, ProfitSummary;

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final entryServiceProvider = Provider<EntryService>((ref) {
  final db = ref.watch(databaseProvider);
  return EntryService(db);
});

final capitalEntriesProvider = StreamProvider<List<CapitalEntry>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchAllCapital();
});

final salesEntriesProvider = StreamProvider<List<SalesEntry>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchAllSales();
});

final expenseEntriesProvider = StreamProvider<List<ExpenseEntry>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchAllExpenses();
});

final settingsProvider = StreamProvider<Setting>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchSettings();
});

final profitSummaryProvider = Provider<ProfitSummary>((ref) {
  final capital = ref.watch(capitalEntriesProvider).value ?? [];
  final sales = ref.watch(salesEntriesProvider).value ?? [];
  final expenses = ref.watch(expenseEntriesProvider).value ?? [];

  return ProfitCalculator.compute(
    sales: sales,
    capital: capital,
    expenses: expenses,
  );
});

final trendProvider = Provider<List<TrendBucket>>((ref) {
  final capital = ref.watch(capitalEntriesProvider).value ?? [];
  final sales = ref.watch(salesEntriesProvider).value ?? [];

  return ProfitCalculator.trend(
    sales: sales,
    capital: capital,
    bucketSize: const Duration(days: 7),
  );
});

class SettingsNotifier extends AutoDisposeAsyncNotifier<Setting> {
  @override
  Future<Setting> build() async {
    final db = ref.watch(databaseProvider);
    return db.getSettings();
  }

  Future<void> updateSettings({
    String? currency,
    PeriodType? defaultPeriod,
    int? themeMode,
  }) async {
    final db = ref.read(databaseProvider);
    await db.updateSettings(
      currency: currency,
      defaultPeriod: defaultPeriod,
      themeMode: themeMode,
    );
    ref.invalidateSelf();
  }
}

final settingsNotifierProvider =
    AutoDisposeAsyncNotifierProvider<SettingsNotifier, Setting>(
  SettingsNotifier.new,
);

final currencyProvider = Provider<String>((ref) {
  final settings = ref.watch(settingsProvider).value;
  return settings?.currency ?? 'د.ل';
});

final defaultPeriodProvider = Provider<PeriodType>((ref) {
  final settings = ref.watch(settingsProvider).value;
  return settings?.defaultPeriod ?? PeriodType.day;
});

final themeModeProvider = Provider<int>((ref) {
  final settings = ref.watch(settingsProvider).value;
  return settings?.themeMode ?? 0;
});
