import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';
import '../providers/entries_provider.dart';
import '../services/profit_calculator.dart';
import '../utils/formatters.dart';
import '../widgets/summary_card.dart';
import '../widgets/profit_chart.dart';
import '../widgets/responsive_layout.dart';
import 'add_capital_screen.dart';
import 'add_expense_screen.dart';
import 'add_sales_screen.dart';
import 'history_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(profitSummaryProvider);
    final trend = ref.watch(trendProvider);
    final currency = ref.watch(currencyProvider);
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final isWide = ResponsiveLayout.isWide(context);
    final spacing = ResponsiveLayout.getSpacing(context);

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: isDesktop
          ? _DesktopLayout(
              summary: summary,
              trend: trend,
              currency: currency,
              isWide: isWide,
              spacing: spacing,
            )
          : _MobileLayout(
              summary: summary,
              trend: trend,
              currency: currency,
            ),
    );
  }
}

class _DesktopLayout extends StatelessWidget {
  final ProfitSummary summary;
  final List<TrendBucket> trend;
  final String currency;
  final bool isWide;
  final double spacing;

  const _DesktopLayout({
    required this.summary,
    required this.trend,
    required this.currency,
    required this.isWide,
    required this.spacing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bgDark,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(spacing),
        child: MaxWidthContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(isWide: isWide),
              SizedBox(height: spacing),
              _ProfitHeroCard(summary: summary, currency: currency),
              SizedBox(height: spacing),
              _SummarySection(summary: summary),
              SizedBox(height: spacing),
              _ChartSection(trend: trend),
              SizedBox(height: spacing),
              _QuickActionsSection(context: context),
              SizedBox(height: spacing),
            ],
          ),
        ),
      ),
    );
  }
}

class _MobileLayout extends StatelessWidget {
  final ProfitSummary summary;
  final List<TrendBucket> trend;
  final String currency;

  const _MobileLayout({
    required this.summary,
    required this.trend,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.md,
            ),
            child: _Header(isWide: false),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          sliver: SliverToBoxAdapter(
            child: _ProfitHeroCard(summary: summary, currency: currency),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.sm,
          ),
          sliver: SliverToBoxAdapter(
            child: _SummarySection(summary: summary),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          sliver: SliverToBoxAdapter(
            child: _ChartSection(trend: trend),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.sm,
          ),
          sliver: SliverToBoxAdapter(
            child: _QuickActionsSection(context: context),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  final bool isWide;

  const _Header({required this.isWide});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'مرحبًا بك',
              style: GoogleFonts.cairo(
                fontSize: isWide ? 16 : 14,
                color: AppColors.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'لوحة التحكم',
              style: GoogleFonts.cairo(
                fontSize: isWide ? 32 : 26,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimaryDark,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm + 2),
          decoration: BoxDecoration(
            color: AppColors.surfaceDark,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.borderDark),
          ),
          child: Icon(
            Icons.notifications_none_rounded,
            color: AppColors.textSecondaryDark,
            size: 22,
          ),
        ),
      ],
    );
  }
}

class _ProfitHeroCard extends StatelessWidget {
  final ProfitSummary summary;
  final String currency;

  const _ProfitHeroCard({required this.summary, required this.currency});

  @override
  Widget build(BuildContext context) {
    final isProfit = summary.netProfit >= 0;
    final accent = isProfit ? AppColors.profit : AppColors.loss;
    final isDesktop = ResponsiveLayout.isDesktop(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isDesktop ? AppSpacing.xl : AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            accent.withValues(alpha: 0.25),
            AppColors.surfaceDark,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: accent.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: isDesktop
          ? _DesktopHeroContent(
              summary: summary,
              accent: accent,
              isProfit: isProfit,
            )
          : _MobileHeroContent(
              summary: summary,
              accent: accent,
              isProfit: isProfit,
            ),
    );
  }
}

class _DesktopHeroContent extends StatelessWidget {
  final ProfitSummary summary;
  final Color accent;
  final bool isProfit;

  const _DesktopHeroContent({
    required this.summary,
    required this.accent,
    required this.isProfit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(
                isProfit ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                color: accent,
                size: 18,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              isProfit ? 'صافي ربح' : 'صافي خسارة',
              style: GoogleFonts.cairo(
                fontSize: 15,
                color: accent,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (summary.hasData) ...[
              const SizedBox(width: AppSpacing.md),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadius.xs),
                ),
                child: Text(
                  Formatters.percentage(summary.profitMargin),
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    color: accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          Formatters.currency(summary.netProfit.abs()),
          style: GoogleFonts.cairo(
            fontSize: 48,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimaryDark,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            _Metric(
              label: 'العائد على الاستثمار',
              value: Formatters.percentage(summary.roi),
            ),
            Container(
              width: 1,
              height: 40,
              color: AppColors.borderDark,
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            ),
            _Metric(
              label: 'هامش الربح',
              value: Formatters.percentage(summary.profitMargin),
            ),
          ],
        ),
      ],
    );
  }
}

class _MobileHeroContent extends StatelessWidget {
  final ProfitSummary summary;
  final Color accent;
  final bool isProfit;

  const _MobileHeroContent({
    required this.summary,
    required this.accent,
    required this.isProfit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: Icon(
                isProfit ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                color: accent,
                size: 16,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              isProfit ? 'صافي ربح' : 'صافي خسارة',
              style: GoogleFonts.cairo(
                fontSize: 14,
                color: accent,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            if (summary.hasData)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadius.xs),
                ),
                child: Text(
                  Formatters.percentage(summary.profitMargin),
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    color: accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerRight,
          child: Text(
            Formatters.currency(summary.netProfit.abs()),
            style: GoogleFonts.cairo(
              fontSize: 38,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimaryDark,
              letterSpacing: -0.5,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _Metric(
                label: 'العائد على الاستثمار',
                value: Formatters.percentage(summary.roi),
              ),
            ),
            Container(
              width: 1,
              height: 30,
              color: AppColors.borderDark,
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            ),
            Expanded(
              child: _Metric(
                label: 'هامش الربح',
                value: Formatters.percentage(summary.profitMargin),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;

  const _Metric({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 13,
            color: AppColors.textMuted,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.cairo(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimaryDark,
          ),
        ),
      ],
    );
  }
}

class _SummarySection extends StatelessWidget {
  final ProfitSummary summary;

  const _SummarySection({required this.summary});

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.only(left: 12),
          decoration: const BoxDecoration(
            border: Border(
              left: BorderSide(color: AppColors.primary, width: 3),
            ),
          ),
          child: Text(
            'ملخص الأرباح',
            style: GoogleFonts.cairo(
              fontSize: isDesktop ? 22 : 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimaryDark,
            ),
          ),
        ),
        SizedBox(height: isDesktop ? AppSpacing.md : AppSpacing.sm),
        ResponsiveGrid(
          mobileCount: 2,
          tabletCount: 2,
          desktopCount: isDesktop ? 3 : 2,
          wideCount: 3,
          spacing: isDesktop ? AppSpacing.md : AppSpacing.sm,
          childAspectRatio: isDesktop ? 1.9 : 1.4,
          children: [
            SummaryCard(
              title: 'رأس المال',
              value: summary.totalCapital,
              accentColor: AppColors.primary,
              icon: Icons.account_balance_wallet_rounded,
              subtitle: 'إجمالي رأس المال',
            ),
            SummaryCard(
              title: 'المبيعات',
              value: summary.totalSales,
              accentColor: AppColors.primaryLight,
              icon: Icons.trending_up_rounded,
              subtitle: 'إجمالي المبيعات',
            ),
            if (summary.totalExpenses > 0 || isDesktop)
              SummaryCard(
                title: 'المصاريف',
                value: summary.totalExpenses,
                accentColor: AppColors.accent,
                icon: Icons.receipt_long_rounded,
                subtitle: 'إجمالي المصاريف',
              ),
          ],
        ),
      ],
    );
  }
}

class _ChartSection extends StatelessWidget {
  final List<TrendBucket> trend;

  const _ChartSection({required this.trend});

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'اتجاه الأرباح',
              style: GoogleFonts.cairo(
                fontSize: isDesktop ? 22 : 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimaryDark,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm + 2,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(AppRadius.full),
                border: Border.all(color: AppColors.borderDark),
              ),
              child: Text(
                'آخر 12 أسبوعًا',
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: isDesktop ? AppSpacing.md : AppSpacing.sm),
        Container(
          padding: EdgeInsets.all(isDesktop ? AppSpacing.lg : AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surfaceDark,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.borderDark),
          ),
          child: Column(
            children: [
              ProfitChart(
                data: trend,
                height: ResponsiveLayout.isWide(context)
                    ? 360
                    : ResponsiveLayout.isDesktop(context)
                        ? 280
                        : 200,
              ),
              const SizedBox(height: AppSpacing.md),
              _ChartLegend(),
            ],
          ),
        ),
      ],
    );
  }
}

class _ChartLegend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _LegendDot(color: AppColors.profit, label: 'الربح'),
        const SizedBox(width: AppSpacing.lg),
        _LegendDot(color: AppColors.primaryLight, label: 'المبيعات'),
        const SizedBox(width: AppSpacing.lg),
        _LegendDot(color: AppColors.accent, label: 'رأس المال'),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 13,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}

class _QuickActionsSection extends StatelessWidget {
  final BuildContext context;

  const _QuickActionsSection({required this.context});

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.only(left: 12),
          decoration: const BoxDecoration(
            border: Border(
              left: BorderSide(color: AppColors.primary, width: 3),
            ),
          ),
          child: Text(
            'إجراءات سريعة',
            style: GoogleFonts.cairo(
              fontSize: isDesktop ? 22 : 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimaryDark,
            ),
          ),
        ),
        SizedBox(height: isDesktop ? AppSpacing.md : AppSpacing.sm),
        isDesktop
            ? _DesktopQuickActions(context: context)
            : _MobileQuickActions(context: context),
      ],
    );
  }
}

class _DesktopQuickActions extends StatelessWidget {
  final BuildContext context;

  const _DesktopQuickActions({required this.context});

  @override
  Widget build(BuildContext context) {
    return ResponsiveGrid(
      mobileCount: 1,
      tabletCount: 2,
      desktopCount: 2,
      wideCount: 4,
      spacing: AppSpacing.md,
      childAspectRatio: 2.2,
      children: [
        _QuickActionCard(
          icon: Icons.savings_rounded,
          title: 'إضافة رأس مال',
          subtitle: 'سجّل دفعة رأس مال جديدة',
          color: AppColors.primary,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddCapitalScreen()),
          ),
        ),
        _QuickActionCard(
          icon: Icons.trending_up_rounded,
          title: 'تسجيل مبيعات',
          subtitle: 'أضف مبيعات لفترة محددة',
          color: AppColors.primaryLight,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddSalesScreen()),
          ),
        ),
        _QuickActionCard(
          icon: Icons.receipt_long_rounded,
          title: 'تسجيل مصروف',
          subtitle: 'سجّل مبلغ مصروف تشغيلي',
          color: AppColors.accent,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
          ),
        ),
        _QuickActionCard(
          icon: Icons.history_rounded,
          title: 'سجل العمليات',
          subtitle: 'استعرض كل الإدخالات',
          color: AppColors.neutral,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const HistoryScreen()),
          ),
        ),
      ],
    );
  }
}

class _MobileQuickActions extends StatelessWidget {
  final BuildContext context;

  const _MobileQuickActions({required this.context});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _QuickActionCard(
          icon: Icons.savings_rounded,
          title: 'إضافة رأس مال',
          subtitle: 'سجّل دفعة رأس مال جديدة',
          color: AppColors.primary,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddCapitalScreen()),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        _QuickActionCard(
          icon: Icons.trending_up_rounded,
          title: 'تسجيل مبيعات',
          subtitle: 'أضف مبيعات لفترة محددة',
          color: AppColors.primaryLight,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddSalesScreen()),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        _QuickActionCard(
          icon: Icons.receipt_long_rounded,
          title: 'تسجيل مصروف',
          subtitle: 'سجّل مبلغ مصروف تشغيلي',
          color: AppColors.accent,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        _QuickActionCard(
          icon: Icons.history_rounded,
          title: 'سجل العمليات',
          subtitle: 'استعرض كل الإدخالات',
          color: AppColors.neutral,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const HistoryScreen()),
          ),
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.surfaceDark,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.borderDark),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm + 2),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimaryDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: AppColors.textMuted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
