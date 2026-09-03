import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/period_type.dart';
import '../providers/entries_provider.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/entry_list_tile.dart';
import '../widgets/responsive_layout.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const _currencies = [
    'ر.س',
    'د.إ',
    'د.ك',
    'د.ل',
    'ر.ق',
    'ر.ع',
    'ج.م',
    r'$',
    '€',
  ];

  Future<void> _exportCsv(BuildContext context, WidgetRef ref) async {
    final capital = ref.read(capitalEntriesProvider).value ?? [];
    final sales = ref.read(salesEntriesProvider).value ?? [];

    final rows = <List<String>>[
      ['النوع', 'التاريخ', 'الفترة', 'المبلغ', 'ملاحظة'],
      ...capital.map((c) => [
            'رأس مال',
            Formatters.dateShort(c.date),
            '-',
            c.amount.toString(),
            c.note ?? '',
          ]),
      ...sales.map((s) => [
            'مبيعات',
            Formatters.dateShort(s.date),
            PeriodType.values[s.period.index].arabicLabel,
            s.amount.toString(),
            s.note ?? '',
          ]),
    ];

    final csv = const ListToCsvConverter().convert(rows);
    final dir = await getTemporaryDirectory();
    final file = File(p.join(dir.path, 'maksabi_export.csv'));
    await file.writeAsString(csv, encoding: utf8);

    if (!context.mounted) return;
    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'تصدير بيانات مكسبي',
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);
    final currency = ref.watch(currencyProvider);
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(title: const Text('الإعدادات')),
      body: SafeArea(
        child: settingsAsync.when(
          loading: () => const LoadingState(message: 'جاري التحميل...'),
          error: (e, _) => Center(
            child: Text('خطأ: $e',
                style: GoogleFonts.cairo(color: AppColors.loss)),
          ),
          data: (settings) => Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: ResponsiveLayout.isWide(context)
                    ? 1000
                    : ResponsiveLayout.isDesktop(context)
                        ? 900
                        : double.infinity,
              ),
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: [
              _SectionTitle('عام'),
              _SettingCard(
                children: [
                  _SettingTile(
                    icon: Icons.attach_money,
                    title: 'العملة',
                    subtitle: currency,
                    trailing: const Icon(Icons.arrow_drop_down,
                        color: AppColors.textSecondaryDark),
                    onTap: () => _showCurrencyPicker(context, ref, currency),
                  ),
                  const Divider(color: AppColors.borderDark, height: 1),
                  _SettingTile(
                    icon: Icons.brightness_6,
                    title: 'المظهر',
                    subtitle: _themeLabel(themeMode),
                    trailing: const Icon(Icons.arrow_drop_down,
                        color: AppColors.textSecondaryDark),
                    onTap: () => _showThemePicker(context, ref, themeMode),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              _SectionTitle('الإدخال'),
              _SettingCard(
                children: [
                  _SettingTile(
                    icon: Icons.repeat,
                    title: 'الفترة الافتراضية للمبيعات',
                    subtitle: settings.defaultPeriod.arabicLabel,
                    trailing: const Icon(Icons.arrow_drop_down,
                        color: AppColors.textSecondaryDark),
                    onTap: () => _showPeriodPicker(
                        context, ref, settings.defaultPeriod),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              _SectionTitle('البيانات'),
              _SettingCard(
                children: [
                  _SettingTile(
                    icon: Icons.file_download,
                    title: 'تصدير CSV',
                    subtitle: 'مشاركة البيانات كملف CSV',
                    onTap: () => _exportCsv(context, ref),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              _SettingCard(
                children: [
                  _SettingTile(
                    icon: Icons.delete_sweep,
                    title: 'مسح رأس المال',
                    subtitle: 'حذف جميع سجلات رأس المال',
                    onTap: () => _confirmClear(
                      context,
                      ref,
                      'مسح رأس المال',
                      'هل أنت متأكد من حذف جميع سجلات رأس المال؟',
                      () => ref.read(entryServiceProvider).clearAllCapital(),
                    ),
                  ),
                  const Divider(color: AppColors.borderDark, height: 1),
                  _SettingTile(
                    icon: Icons.delete_sweep,
                    title: 'مسح المبيعات',
                    subtitle: 'حذف جميع سجلات المبيعات',
                    onTap: () => _confirmClear(
                      context,
                      ref,
                      'مسح المبيعات',
                      'هل أنت متأكد من حذف جميع سجلات المبيعات؟',
                      () => ref.read(entryServiceProvider).clearAllSales(),
                    ),
                  ),
                  const Divider(color: AppColors.borderDark, height: 1),
                  _SettingTile(
                    icon: Icons.delete_sweep,
                    title: 'مسح المصروفات',
                    subtitle: 'حذف جميع سجلات المصروفات',
                    onTap: () => _confirmClear(
                      context,
                      ref,
                      'مسح المصروفات',
                      'هل أنت متأكد من حذف جميع سجلات المصروفات؟',
                      () => ref.read(entryServiceProvider).clearAllExpenses(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              _SettingCard(
                children: [
                  _SettingTile(
                    icon: Icons.warning_amber_rounded,
                    title: 'مسح جميع البيانات',
                    subtitle: 'حذف كل البيانات نهائياً',
                    onTap: () => _confirmClearAll(context, ref),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              _SectionTitle('حول التطبيق'),
              _SettingCard(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                    child: Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        child: Image.asset(
                          'assets/icon/logo.png',
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const Divider(color: AppColors.borderDark, height: 1),
                  _SettingTile(
                    icon: Icons.info_outline,
                    title: 'الإصدار',
                    subtitle: '1.0.0',
                  ),
                  const Divider(color: AppColors.borderDark, height: 1),
                  _SettingTile(
                    icon: Icons.code,
                    title: 'مكسبي',
                    subtitle: 'نظام تتبع الأرباح',
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              Center(
                child: Text(
                  'صنع لتجار وممولي المشاريع الصغيرة',
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    color: AppColors.textSecondaryDark,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    ),
    );
  }

  String _themeLabel(int mode) {
    switch (mode) {
      case 0:
        return 'داكن';
      case 1:
        return 'فاتح';
      default:
        return 'حسب النظام';
    }
  }

  Future<void> _showCurrencyPicker(
    BuildContext context,
    WidgetRef ref,
    String current,
  ) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Text(
                'اختر العملة',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimaryDark,
                ),
              ),
            ),
            ..._currencies.map(
              (c) => ListTile(
                title: Text(
                  c,
                  style: GoogleFonts.cairo(
                    color: AppColors.textPrimaryDark,
                    fontWeight:
                        c == current ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
                trailing: c == current
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () => Navigator.of(context).pop(c),
              ),
            ),
          ],
        ),
      ),
    );
    if (selected != null) {
      await ref
          .read(settingsNotifierProvider.notifier)
          .updateSettings(currency: selected);
    }
  }

  Future<void> _showThemePicker(
    BuildContext context,
    WidgetRef ref,
    int current,
  ) async {
    final selected = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Text(
                'اختر المظهر',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimaryDark,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dark_mode,
                  color: AppColors.textPrimaryDark),
              title: Text('داكن',
                  style:
                      GoogleFonts.cairo(color: AppColors.textPrimaryDark)),
              trailing: current == 0
                  ? const Icon(Icons.check, color: AppColors.primary)
                  : null,
              onTap: () => Navigator.of(context).pop(0),
            ),
            ListTile(
              leading: const Icon(Icons.light_mode,
                  color: AppColors.textPrimaryDark),
              title: Text('فاتح',
                  style:
                      GoogleFonts.cairo(color: AppColors.textPrimaryDark)),
              trailing: current == 1
                  ? const Icon(Icons.check, color: AppColors.primary)
                  : null,
              onTap: () => Navigator.of(context).pop(1),
            ),
            ListTile(
              leading: const Icon(Icons.brightness_auto,
                  color: AppColors.textPrimaryDark),
              title: Text('حسب النظام',
                  style:
                      GoogleFonts.cairo(color: AppColors.textPrimaryDark)),
              trailing: current == 2
                  ? const Icon(Icons.check, color: AppColors.primary)
                  : null,
              onTap: () => Navigator.of(context).pop(2),
            ),
          ],
        ),
      ),
    );
    if (selected != null) {
      await ref
          .read(settingsNotifierProvider.notifier)
          .updateSettings(themeMode: selected);
    }
  }

  Future<void> _showPeriodPicker(
    BuildContext context,
    WidgetRef ref,
    PeriodType current,
  ) async {
    final selected = await showModalBottomSheet<PeriodType>(
      context: context,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Text(
                'الفترة الافتراضية',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimaryDark,
                ),
              ),
            ),
            ...PeriodType.values.map(
              (p) => ListTile(
                title: Text(
                  p.arabicLabel,
                  style: GoogleFonts.cairo(
                    color: AppColors.textPrimaryDark,
                    fontWeight: p == current
                        ? FontWeight.w700
                        : FontWeight.w400,
                  ),
                ),
                trailing: p == current
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () => Navigator.of(context).pop(p),
              ),
            ),
          ],
        ),
      ),
    );
    if (selected != null) {
      await ref
          .read(settingsNotifierProvider.notifier)
          .updateSettings(defaultPeriod: selected);
    }
  }

  Future<void> _confirmClear(
    BuildContext context,
    WidgetRef ref,
    String title,
    String message,
    Future<void> Function() onConfirm,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: Text(title, style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
        content: Text(message, style: GoogleFonts.cairo()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('إلغاء', style: GoogleFonts.cairo(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('مسح', style: GoogleFonts.cairo(color: AppColors.loss)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await onConfirm();
    }
  }

  Future<void> _confirmClearAll(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: Text('مسح جميع البيانات',
            style: GoogleFonts.cairo(
                fontWeight: FontWeight.w700, color: AppColors.loss)),
        content: Text(
          'سيتم حذف جميع سجلات رأس المال والمبيعات والمصروفات نهائياً. هذا الإجراء لا يمكن التراجع عنه.',
          style: GoogleFonts.cairo(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child:
                Text('إلغاء', style: GoogleFonts.cairo(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child:
                Text('مسح الكل', style: GoogleFonts.cairo(color: AppColors.loss)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(entryServiceProvider).clearAllData();
    }
  }
}

class _SectionTitle extends StatelessWidget {
  final String label;
  const _SectionTitle(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm, right: 4),
      child: Text(
        label,
        style: GoogleFonts.cairo(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondaryDark,
        ),
      ),
    );
  }
}

class _SettingCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Column(children: children),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;

  const _SettingTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(icon, color: AppColors.primary, size: 18),
          ),
          title: Text(
            title,
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimaryDark,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: GoogleFonts.cairo(
              fontSize: 12,
              color: AppColors.textSecondaryDark,
            ),
          ),
          trailing: trailing,
        ),
      ),
    );
  }
}
