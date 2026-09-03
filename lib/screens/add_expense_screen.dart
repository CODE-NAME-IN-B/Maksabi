import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../db/database.dart';
import '../providers/entries_provider.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/responsive_layout.dart';

class AddExpenseScreen extends ConsumerStatefulWidget {
  final ExpenseEntry? existing;

  const AddExpenseScreen({super.key, this.existing});

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;
  late DateTime _selectedDate;
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.existing?.amount.toString() ?? '',
    );
    _noteController = TextEditingController(
      text: widget.existing?.note ?? '',
    );
    _selectedDate = widget.existing?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              surface: AppColors.surfaceDark,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final service = ref.read(entryServiceProvider);
      final amount = double.parse(_amountController.text);
      final note = _noteController.text.trim();

      if (widget.existing != null) {
        final updated = ExpenseEntry(
          id: widget.existing!.id,
          date: _selectedDate,
          amount: amount,
          note: note.isEmpty ? null : note,
        );
        await service.updateExpense(updated);
      } else {
        await service.addExpense(
          date: _selectedDate,
          amount: amount,
          note: note.isEmpty ? null : note,
        );
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ: $e'),
            backgroundColor: AppColors.loss,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: Text(widget.existing != null ? 'تعديل مصروف' : 'إضافة مصروف'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: ResponsiveLayout.isWide(context)
                  ? 800
                  : ResponsiveLayout.isDesktop(context)
                      ? 720
                      : double.infinity,
            ),
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(
                    color: AppColors.accent.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.receipt_long, color: AppColors.accent, size: 32),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'مصروف جديد',
                            style: GoogleFonts.cairo(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimaryDark,
                            ),
                          ),
                          Text(
                            'سجّل مبلغ مصروف تشغيلي',
                            style: GoogleFonts.cairo(
                              fontSize: 12,
                              color: AppColors.textSecondaryDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              if (ResponsiveLayout.isDesktop(context))
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'المبلغ',
                            style: GoogleFonts.cairo(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimaryDark,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          TextFormField(
                            controller: _amountController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            style: GoogleFonts.cairo(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimaryDark,
                            ),
                            decoration: const InputDecoration(
                              hintText: '0.00',
                              prefixIcon: Padding(
                                padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                                child: Icon(Icons.attach_money, color: AppColors.textSecondaryDark),
                              ),
                            ),
                            validator: Validators.amount,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'التاريخ',
                            style: GoogleFonts.cairo(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimaryDark,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _pickDate,
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              child: Ink(
                                decoration: BoxDecoration(
                                  color: AppColors.bgSecondary,
                                  borderRadius: BorderRadius.circular(AppRadius.md),
                                  border: Border.all(color: AppColors.borderDark),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(AppSpacing.md),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.calendar_today, color: AppColors.textSecondaryDark, size: 20),
                                      const SizedBox(width: AppSpacing.md),
                                      Text(
                                        Formatters.dateLong(_selectedDate),
                                        style: GoogleFonts.cairo(fontSize: 14, color: AppColors.textPrimaryDark),
                                      ),
                                      const Spacer(),
                                      const Icon(Icons.arrow_drop_down, color: AppColors.textSecondaryDark),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              else ...[
                Text(
                  'المبلغ',
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimaryDark,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: GoogleFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimaryDark,
                  ),
                  decoration: const InputDecoration(
                    hintText: '0.00',
                    prefixIcon: Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      child: Icon(Icons.attach_money, color: AppColors.textSecondaryDark),
                    ),
                  ),
                  validator: Validators.amount,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'التاريخ',
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimaryDark,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _pickDate,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    child: Ink(
                      decoration: BoxDecoration(
                        color: AppColors.bgSecondary,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(color: AppColors.borderDark),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, color: AppColors.textSecondaryDark, size: 20),
                            const SizedBox(width: AppSpacing.md),
                            Text(
                              Formatters.dateLong(_selectedDate),
                              style: GoogleFonts.cairo(fontSize: 14, color: AppColors.textPrimaryDark),
                            ),
                            const Spacer(),
                            const Icon(Icons.arrow_drop_down, color: AppColors.textSecondaryDark),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              Text(
                'ملاحظة (اختياري)',
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimaryDark,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _noteController,
                maxLines: 3,
                maxLength: 200,
                style: GoogleFonts.cairo(color: AppColors.textPrimaryDark),
                decoration: const InputDecoration(hintText: 'مثال: إيجار، رواتب، فواتير...'),
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                          width: 16, height: 16,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.check),
                  label: Text(widget.existing != null ? 'حفظ التعديلات' : 'إضافة مصروف'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
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
}
