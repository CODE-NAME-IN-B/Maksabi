import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';
import '../widgets/responsive_layout.dart';
import 'add_capital_screen.dart';
import 'add_expense_screen.dart';
import 'add_sales_screen.dart';
import 'dashboard_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _index = 0;

  static const _screens = [
    DashboardScreen(),
    HistoryScreen(),
    SettingsScreen(),
  ];

  int _sidebarToScreenIndex(int sidebarIndex) {
    switch (sidebarIndex) {
      case 0:
        return 0; // الرئيسية
      case 1:
      case 2:
      case 3:
        return -1; // رأس المال / المبيعات / المصروفات → navigate
      case 4:
        return 1; // السجل
      case 5:
        return 2; // الإعدادات
      default:
        return 0;
    }
  }

  void _onSidebarItemTap(int index) {
    if (index == 1) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const AddCapitalScreen()),
      );
      return;
    }
    if (index == 2) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const AddSalesScreen()),
      );
      return;
    }
    if (index == 3) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
      );
      return;
    }
    final screenIndex = _sidebarToScreenIndex(index);
    setState(() => _index = screenIndex);
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context);

    if (isDesktop) {
      return _DesktopShell(
        index: _index,
        onIndexChanged: _onSidebarItemTap,
        child: _screens[_index],
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.bgDark,
          border: Border(
            top: BorderSide(color: AppColors.borderDark, width: 1),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Row(
              children: [
                _navItem(0, Icons.dashboard_outlined, Icons.dashboard, 'الرئيسية'),
                _navItem(1, Icons.history_outlined, Icons.history, 'السجل'),
                _navItem(2, Icons.settings_outlined, Icons.settings, 'الإعدادات'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData outlined, IconData filled, String label) {
    final selected = _index == index;
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => _index = index),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  selected ? filled : outlined,
                  size: 22,
                  color: selected
                      ? AppColors.primary
                      : AppColors.textMuted,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: GoogleFonts.cairo(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: selected
                        ? AppColors.primary
                        : AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DesktopShell extends StatelessWidget {
  final int index;
  final Function(int) onIndexChanged;
  final Widget child;

  const _DesktopShell({
    required this.index,
    required this.onIndexChanged,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Row(
        children: [
          DesktopSidebar(
            selectedIndex: index,
            onItemSelected: onIndexChanged,
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}
