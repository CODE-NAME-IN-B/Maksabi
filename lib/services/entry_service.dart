import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../models/period_type.dart';
import '../db/database.dart';

class EntryService {
  final AppDatabase db;
  EntryService(this.db);

  static const _uuid = Uuid();

  // ───────────────── Capital ─────────────────
  Future<String> addCapital({
    required DateTime date,
    required double amount,
    String? note,
  }) async {
    final id = _uuid.v4();
    await db.into(db.capitalEntries).insert(
      CapitalEntriesCompanion.insert(
        id: id,
        date: date,
        amount: amount,
        note: Value(note),
      ),
    );
    return id;
  }

  Future<void> updateCapital(CapitalEntry entry) async {
    await db.into(db.capitalEntries).insertOnConflictUpdate(
      CapitalEntriesCompanion(
        id: Value(entry.id),
        date: Value(entry.date),
        amount: Value(entry.amount),
        note: Value(entry.note),
      ),
    );
  }

  Future<void> deleteCapital(String id) async {
    await (db.delete(db.capitalEntries)..where((t) => t.id.equals(id))).go();
  }

  // ───────────────── Sales ─────────────────
  Future<String> addSales({
    required DateTime date,
    required PeriodType period,
    required double amount,
    String? note,
  }) async {
    final id = _uuid.v4();
    await db.into(db.salesEntries).insert(
      SalesEntriesCompanion.insert(
        id: id,
        date: date,
        period: period,
        amount: amount,
        note: Value(note),
      ),
    );
    return id;
  }

  Future<void> updateSales(SalesEntry entry) async {
    await db.into(db.salesEntries).insertOnConflictUpdate(
      SalesEntriesCompanion(
        id: Value(entry.id),
        date: Value(entry.date),
        period: Value(entry.period),
        amount: Value(entry.amount),
        note: Value(entry.note),
      ),
    );
  }

  Future<void> deleteSales(String id) async {
    await (db.delete(db.salesEntries)..where((t) => t.id.equals(id))).go();
  }

  // ───────────────── Expenses ─────────────────
  Future<String> addExpense({
    required DateTime date,
    required double amount,
    String? note,
  }) async {
    final id = _uuid.v4();
    await db.into(db.expenseEntries).insert(
      ExpenseEntriesCompanion.insert(
        id: id,
        date: date,
        amount: amount,
        note: Value(note),
      ),
    );
    return id;
  }

  Future<void> updateExpense(ExpenseEntry entry) async {
    await db.into(db.expenseEntries).insertOnConflictUpdate(
      ExpenseEntriesCompanion(
        id: Value(entry.id),
        date: Value(entry.date),
        amount: Value(entry.amount),
        note: Value(entry.note),
      ),
    );
  }

  Future<void> deleteExpense(String id) async {
    await (db.delete(db.expenseEntries)..where((t) => t.id.equals(id))).go();
  }

  // ───────────────── Clear All ─────────────────
  Future<void> clearAllCapital() async {
    await db.delete(db.capitalEntries).go();
  }

  Future<void> clearAllSales() async {
    await db.delete(db.salesEntries).go();
  }

  Future<void> clearAllExpenses() async {
    await db.delete(db.expenseEntries).go();
  }

  Future<void> clearAllData() async {
    await db.delete(db.capitalEntries).go();
    await db.delete(db.salesEntries).go();
    await db.delete(db.expenseEntries).go();
  }
}
