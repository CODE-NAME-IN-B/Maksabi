import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';

enum ScreenSize { mobile, tablet, desktop, wide }

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;
  final Widget? wide;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
    this.wide,
  });

  static ScreenSize getScreenSize(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= 1440) return ScreenSize.wide;
    if (width >= 1024) return ScreenSize.desktop;
    if (width >= 600) return ScreenSize.tablet;
    return ScreenSize.mobile;
  }

  static bool isMobile(BuildContext context) =>
      getScreenSize(context) == ScreenSize.mobile;
  static bool isTablet(BuildContext context) =>
      getScreenSize(context) == ScreenSize.tablet;
  static bool isDesktop(BuildContext context) =>
      getScreenSize(context) == ScreenSize.desktop ||
      getScreenSize(context) == ScreenSize.wide;
  static bool isWide(BuildContext context) =>
      getScreenSize(context) == ScreenSize.wide;

  static double getMaxWidth(BuildContext context) {
    final size = getScreenSize(context);
    switch (size) {
      case ScreenSize.wide:
        return 1600;
      case ScreenSize.desktop:
        return 1400;
      case ScreenSize.tablet:
        return 900;
      case ScreenSize.mobile:
        return double.infinity;
    }
  }

  static double getSidebarWidth(BuildContext context) {
    final size = getScreenSize(context);
    switch (size) {
      case ScreenSize.wide:
        return 280;
      case ScreenSize.desktop:
        return 260;
      default:
        return 0;
    }
  }

  static int getGridCount(BuildContext context) {
    final size = getScreenSize(context);
    switch (size) {
      case ScreenSize.wide:
        return 4;
      case ScreenSize.desktop:
        return 3;
      case ScreenSize.tablet:
        return 2;
      case ScreenSize.mobile:
        return 1;
    }
  }

  static double getSpacing(BuildContext context) {
    final size = getScreenSize(context);
    switch (size) {
      case ScreenSize.wide:
        return 32;
      case ScreenSize.desktop:
        return 24;
      case ScreenSize.tablet:
        return 16;
      case ScreenSize.mobile:
        return 16;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1440) {
          return wide ?? desktop;
        } else if (constraints.maxWidth >= 1024) {
          return desktop;
        } else if (constraints.maxWidth >= 600) {
          return tablet ?? mobile;
        }
        return mobile;
      },
    );
  }
}

class MaxWidthContainer extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  final EdgeInsetsGeometry? padding;

  const MaxWidthContainer({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final maxW = maxWidth ?? ResponsiveLayout.getMaxWidth(context);

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxW),
        child: padding != null
            ? Padding(padding: padding!, child: child)
            : child,
      ),
    );
  }
}

class DesktopSidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;
  final String userName;
  final String userSubtitle;

  const DesktopSidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    this.userName = 'مكسبي',
    this.userSubtitle = 'نظام تتبع الأرباح',
  });

  @override
  Widget build(BuildContext context) {
    final sidebarWidth = ResponsiveLayout.getSidebarWidth(context);
    final isWide = ResponsiveLayout.isWide(context);

    return Container(
      width: sidebarWidth,
      decoration: const BoxDecoration(
        color: AppColors.bgDark,
        border: Border(
          left: BorderSide(color: AppColors.borderDark, width: 1),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(isWide ? 24 : 20),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset(
                    'assets/icon/logo.png',
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'مكسبي',
                        style: GoogleFonts.cairo(
                          color: AppColors.textPrimaryDark,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Profit Tracker',
                        style: GoogleFonts.cairo(
                          color: AppColors.textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: AppColors.borderDark, height: 1),
          const SizedBox(height: 8),
          _NavItem(
            icon: Icons.dashboard_rounded,
            label: 'الرئيسية',
            isSelected: selectedIndex == 0,
            onTap: () => onItemSelected(0),
          ),
          _NavItem(
            icon: Icons.savings_rounded,
            label: 'رأس المال',
            isSelected: false,
            onTap: () => onItemSelected(1),
          ),
          _NavItem(
            icon: Icons.trending_up_rounded,
            label: 'المبيعات',
            isSelected: false,
            onTap: () => onItemSelected(2),
          ),
          _NavItem(
            icon: Icons.receipt_long_rounded,
            label: 'المصاريف',
            isSelected: false,
            onTap: () => onItemSelected(3),
          ),
          _NavItem(
            icon: Icons.history_rounded,
            label: 'السجل',
            isSelected: selectedIndex == 1,
            onTap: () => onItemSelected(4),
          ),
          const Spacer(),
          _NavItem(
            icon: Icons.settings_rounded,
            label: 'الإعدادات',
            isSelected: selectedIndex == 2,
            onTap: () => onItemSelected(5),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.3)
                      : Colors.transparent,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    icon,
                    color: isSelected ? AppColors.primaryLight : AppColors.textMuted,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    label,
                    style: GoogleFonts.cairo(
                      color: isSelected ? AppColors.textPrimaryDark : AppColors.textSecondaryDark,
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
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

class ResponsiveGrid extends StatelessWidget {
  final int? mobileCount;
  final int? tabletCount;
  final int? desktopCount;
  final int? wideCount;
  final double spacing;
  final List<Widget> children;
  final double? childAspectRatio;

  const ResponsiveGrid({
    super.key,
    this.mobileCount,
    this.tabletCount,
    this.desktopCount,
    this.wideCount,
    this.spacing = 16,
    this.children = const [],
    this.childAspectRatio,
  });

  @override
  Widget build(BuildContext context) {
    final size = ResponsiveLayout.getScreenSize(context);
    int crossAxisCount;
    switch (size) {
      case ScreenSize.wide:
        crossAxisCount = wideCount ?? 4;
        break;
      case ScreenSize.desktop:
        crossAxisCount = desktopCount ?? 3;
        break;
      case ScreenSize.tablet:
        crossAxisCount = tabletCount ?? 2;
        break;
      case ScreenSize.mobile:
        crossAxisCount = mobileCount ?? 1;
        break;
    }

    return GridView.count(
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: spacing,
      crossAxisSpacing: spacing,
      childAspectRatio: childAspectRatio ?? 1.5,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: children,
    );
  }
}
