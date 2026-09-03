import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../models/period_type.dart';

part 'database.g.dart';

class CapitalEntries extends Table {
  TextColumn get id => text()();
  DateTimeColumn get date => dateTime()();
  RealColumn get amount => real()();
  TextColumn get note => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class SalesEntries extends Table {
  TextColumn get id => text()();
  DateTimeColumn get date => dateTime()();
  IntColumn get period => intEnum<PeriodType>()();
  RealColumn get amount => real()();
  TextColumn get note => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class ExpenseEntries extends Table {
  TextColumn get id => text()();
  DateTimeColumn get date => dateTime()();
  RealColumn get amount => real()();
  TextColumn get note => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Settings extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();
  TextColumn get currency => text().withDefault(const Constant('د.ل'))();
  IntColumn get defaultPeriod =>
      intEnum<PeriodType>().withDefault(const Constant(0))();
  IntColumn get themeMode => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(
  tables: [CapitalEntries, SalesEntries, ExpenseEntries, Settings],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(super.connection);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await into(settings).insert(
        const SettingsCompanion(id: Value(1)),
      );
    },
    beforeOpen: (details) async {
      if (details.wasCreated) return;
      final s = await (select(settings)..where((t) => t.id.equals(1))).getSingleOrNull();
      if (s != null && s.currency == 'ر.س') {
        await (update(settings)..where((t) => t.id.equals(1)))
          .write(const SettingsCompanion(currency: Value('د.ل')));
      }
    },
  );

  // ───────────────── Capital ─────────────────
  Stream<List<CapitalEntry>> watchAllCapital() {
    return (select(capitalEntries)
      ..orderBy([(t) => OrderingTerm.desc(t.date)]))
      .watch();
  }

  Future<List<CapitalEntry>> getAllCapital() {
    return (select(capitalEntries)
      ..orderBy([(t) => OrderingTerm.desc(t.date)]))
      .get();
  }

  Future<void> upsertCapital(CapitalEntry entry) async {
    await into(capitalEntries).insertOnConflictUpdate(entry);
  }

  Future<void> deleteCapital(String id) {
    return (delete(capitalEntries)..where((t) => t.id.equals(id))).go();
  }

  // ───────────────── Sales ─────────────────
  Stream<List<SalesEntry>> watchAllSales() {
    return (select(salesEntries)
      ..orderBy([(t) => OrderingTerm.desc(t.date)]))
      .watch();
  }

  Future<List<SalesEntry>> getAllSales() {
    return (select(salesEntries)
      ..orderBy([(t) => OrderingTerm.desc(t.date)]))
      .get();
  }

  Future<void> upsertSales(SalesEntry entry) async {
    await into(salesEntries).insertOnConflictUpdate(entry);
  }

  Future<void> deleteSales(String id) {
    return (delete(salesEntries)..where((t) => t.id.equals(id))).go();
  }

  // ───────────────── Expenses ─────────────────
  Stream<List<ExpenseEntry>> watchAllExpenses() {
    return (select(expenseEntries)
      ..orderBy([(t) => OrderingTerm.desc(t.date)]))
      .watch();
  }

  Future<List<ExpenseEntry>> getAllExpenses() {
    return (select(expenseEntries)
      ..orderBy([(t) => OrderingTerm.desc(t.date)]))
      .get();
  }

  Future<void> upsertExpense(ExpenseEntry entry) async {
    await into(expenseEntries).insertOnConflictUpdate(entry);
  }

  Future<void> deleteExpense(String id) {
    return (delete(expenseEntries)..where((t) => t.id.equals(id))).go();
  }

  // ───────────────── Settings ─────────────────
  Stream<Setting> watchSettings() {
    return (select(settings)..where((t) => t.id.equals(1))).watchSingle();
  }

  Future<Setting> getSettings() async {
    return (select(settings)..where((t) => t.id.equals(1))).getSingle();
  }

  Future<void> updateSettings({
    String? currency,
    PeriodType? defaultPeriod,
    int? themeMode,
  }) async {
    await (update(settings)..where((t) => t.id.equals(1))).write(
      SettingsCompanion(
        currency: currency == null ? const Value.absent() : Value(currency),
        defaultPeriod: defaultPeriod == null
            ? const Value.absent()
            : Value(defaultPeriod),
        themeMode: themeMode == null ? const Value.absent() : Value(themeMode),
      ),
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'maksabi.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
