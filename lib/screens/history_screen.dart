import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../db/database.dart';
import '../models/period_type.dart';
import '../providers/entries_provider.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/entry_list_tile.dart';
import 'add_capital_screen.dart';
import 'add_expense_screen.dart';
import 'add_sales_screen.dart';

enum _Filter { all, capital, sales, expenses }

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  _Filter _filter = _Filter.all;

  Future<void> _confirmDelete(
    String message,
    Future<void> Function() onConfirm,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: const BorderSide(color: AppColors.borderDark),
        ),
        title: Text(
          'تأكيد الحذف',
          style: GoogleFonts.cairo(
            color: AppColors.textPrimaryDark,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          message,
          style: GoogleFonts.cairo(color: AppColors.textPrimaryDark),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('إلغاء',
                style: GoogleFonts.cairo(color: AppColors.textSecondaryDark)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('حذف',
                style: GoogleFonts.cairo(color: AppColors.loss)),
          ),
        ],
      ),
    );
    if (confirmed == true) await onConfirm();
  }

  @override
  Widget build(BuildContext context) {
    final capitalAsync = ref.watch(capitalEntriesProvider);
    final salesAsync = ref.watch(salesEntriesProvider);
    final expenseAsync = ref.watch(expenseEntriesProvider);

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(title: const Text('سجل العمليات')),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.sm,
              ),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.bgSecondary,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  border: Border.all(color: AppColors.borderDark),
                ),
                child: Row(
                  children: [
                    Expanded(child: _buildFilterChip(_Filter.all, 'الكل')),
                    Expanded(child: _buildFilterChip(_Filter.capital, 'رأس المال')),
                    Expanded(child: _buildFilterChip(_Filter.sales, 'المبيعات')),
                    Expanded(child: _buildFilterChip(_Filter.expenses, 'المصاريف')),
                  ],
                ),
              ),
            ),
            Expanded(
              child: capitalAsync.when(
                loading: () => const LoadingState(message: 'جاري التحميل...'),
                error: (e, _) => Center(
                  child: Text('خطأ: $e',
                      style: GoogleFonts.cairo(color: AppColors.loss)),
                ),
                data: (capital) => salesAsync.when(
                  loading: () => const LoadingState(message: 'جاري التحميل...'),
                  error: (e, _) => Center(
                    child: Text('خطأ: $e',
                        style: GoogleFonts.cairo(color: AppColors.loss)),
                  ),
                  data: (sales) => expenseAsync.when(
                    loading: () => const LoadingState(message: 'جاري التحميل...'),
                    error: (e, _) => Center(
                      child: Text('خطأ: $e',
                          style: GoogleFonts.cairo(color: AppColors.loss)),
                    ),
                    data: (expenses) => _buildList(capital, sales, expenses),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(_Filter filter, String label) {
    final selected = _filter == filter;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => setState(() => _filter = filter),
        borderRadius: BorderRadius.circular(AppRadius.full),
        child: Ink(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : AppColors.textSecondaryDark,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildList(
    List<CapitalEntry> capital,
    List<SalesEntry> sales,
    List<ExpenseEntry> expenses,
  ) {
    final items = <_ListItem>[];

    if (_filter == _Filter.all || _filter == _Filter.capital) {
      for (final c in capital) {
        items.add(_ListItem.capital(c));
      }
    }
    if (_filter == _Filter.all || _filter == _Filter.sales) {
      for (final s in sales) {
        items.add(_ListItem.sales(s));
      }
    }
    if (_filter == _Filter.all || _filter == _Filter.expenses) {
      for (final e in expenses) {
        items.add(_ListItem.expense(e));
      }
    }

    items.sort((a, b) => b.date.compareTo(a.date));

    if (items.isEmpty) {
      return EmptyState(
        message: _filter == _Filter.all
            ? 'لا توجد عمليات بعد'
            : 'لا توجد عمليات في هذا التصنيف',
        icon: Icons.history,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        if (item.isCapital) {
          final c = item.capitalData!;
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: EntryListTile(
              title: c.note ?? 'دفعة رأس مال',
              subtitle: Formatters.dateShort(c.date),
              amount: c.amount,
              amountColor: AppColors.primary,
              leadingIcon: Icons.account_balance_wallet,
              onEdit: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => AddCapitalScreen(existing: c)),
              ),
              onDelete: () => _confirmDelete(
                'هل تريد حذف هذه الدفعة من رأس المال؟',
                () async {
                  final service = ref.read(entryServiceProvider);
                  await service.deleteCapital(c.id);
                },
              ),
            ),
          );
        } else if (item.isSales) {
          final s = item.salesData!;
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: EntryListTile(
              title: s.note ?? 'مبيعات ${s.period.arabicLabel}',
              subtitle:
                  '${Formatters.dateShort(s.date)} • ${s.period.shortLabel}',
              amount: s.amount,
              amountColor: AppColors.primaryLight,
              leadingIcon: Icons.trending_up,
              onEdit: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => AddSalesScreen(existing: s)),
              ),
              onDelete: () => _confirmDelete(
                'هل تريد حذف عملية المبيعات هذه؟',
                () async {
                  final service = ref.read(entryServiceProvider);
                  await service.deleteSales(s.id);
                },
              ),
            ),
          );
        } else {
          final e = item.expenseData!;
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: EntryListTile(
              title: e.note ?? 'مصروف تشغيلي',
              subtitle: Formatters.dateShort(e.date),
              amount: e.amount,
              amountColor: AppColors.accent,
              leadingIcon: Icons.receipt_long,
              onEdit: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => AddExpenseScreen(existing: e)),
              ),
              onDelete: () => _confirmDelete(
                'هل تريد حذف هذا المصروف؟',
                () async {
                  final service = ref.read(entryServiceProvider);
                  await service.deleteExpense(e.id);
                },
              ),
            ),
          );
        }
      },
    );
  }
}

class _ListItem {
  final CapitalEntry? capitalData;
  final SalesEntry? salesData;
  final ExpenseEntry? expenseData;

  const _ListItem.capital(CapitalEntry this.capitalData)
      : salesData = null,
        expenseData = null;
  const _ListItem.sales(SalesEntry this.salesData)
      : capitalData = null,
        expenseData = null;
  const _ListItem.expense(ExpenseEntry this.expenseData)
      : capitalData = null,
        salesData = null;

  bool get isCapital => capitalData != null;
  bool get isSales => salesData != null;
  bool get isExpense => expenseData != null;
  DateTime get date =>
      capitalData?.date ?? salesData?.date ?? expenseData!.date;
}
