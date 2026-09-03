import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';

import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../services/profit_calculator.dart';
import '../widgets/responsive_layout.dart';

class ProfitChart extends StatelessWidget {
  final List<TrendBucket> data;
  final double height;

  const ProfitChart({
    super.key,
    required this.data,
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return SizedBox(
        height: height,
        child: Center(
          child: Text(
            'لا توجد بيانات للرسم البياني',
            style: GoogleFonts.cairo(
              color: AppColors.textSecondaryDark,
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: height,
      child: _ChartBody(data: data),
    );
  }
}

class _ChartBody extends StatelessWidget {
  final List<TrendBucket> data;
  const _ChartBody({required this.data});

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final fontSize = isDesktop ? 12.0 : 9.0;

    final profitSpots = <FlSpot>[];
    final salesSpots = <FlSpot>[];
    final capitalSpots = <FlSpot>[];

    for (var i = 0; i < data.length; i++) {
      final d = data[i];
      profitSpots.add(FlSpot(i.toDouble(), d.profit));
      salesSpots.add(FlSpot(i.toDouble(), d.sales));
      capitalSpots.add(FlSpot(i.toDouble(), d.capital));
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawHorizontalLine: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(
            color: AppColors.borderDark,
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            axisNameWidget: const SizedBox(),
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              interval: _titleInterval(),
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= data.length) return const SizedBox();
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    Formatters.dateShort(data[idx].date),
                    style: GoogleFonts.cairo(
                      fontSize: fontSize,
                      color: AppColors.textSecondaryDark,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            axisNameWidget: const SizedBox(),
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 36,
              interval: _verticalInterval(),
              getTitlesWidget: (value, meta) {
                return Text(
                  Formatters.compact(value),
                  style: GoogleFonts.cairo(
                    fontSize: fontSize,
                    color: AppColors.textSecondaryDark,
                  ),
                  overflow: TextOverflow.ellipsis,
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => AppColors.surfaceDark,
            tooltipRoundedRadius: 8,
            getTooltipItems: (spots) => spots.map((spot) {
              final label = spot.barIndex == 0
                  ? 'الربح'
                  : spot.barIndex == 1
                      ? 'المبيعات'
                      : 'رأس المال';
              return LineTooltipItem(
                '$label\n${Formatters.currency(spot.y)}',
                GoogleFonts.cairo(
                  color: AppColors.textPrimaryDark,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              );
            }).toList(),
          ),
          handleBuiltInTouches: true,
        ),
        lineBarsData: [
          LineChartBarData(
            spots: profitSpots,
            color: AppColors.profit,
            barWidth: 3,
            isCurved: true,
            curveSmoothness: 0.35,
            isStrokeCapRound: true,
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.profit.withValues(alpha: 0.15),
            ),
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, bar, index) =>
                FlDotCirclePainter(
                  radius: 4,
                  color: bar.color ?? AppColors.profit,
                  strokeWidth: 2,
                  strokeColor: AppColors.surfaceDark,
                ),
            ),
          ),
          LineChartBarData(
            spots: salesSpots,
            color: AppColors.primaryLight,
            barWidth: 2,
            isCurved: true,
            curveSmoothness: 0.35,
            isStrokeCapRound: true,
            belowBarData: BarAreaData(show: false),
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, bar, index) =>
                FlDotCirclePainter(
                  radius: 3,
                  color: bar.color ?? AppColors.primaryLight,
                  strokeWidth: 2,
                  strokeColor: AppColors.surfaceDark,
                ),
            ),
          ),
          LineChartBarData(
            spots: capitalSpots,
            color: AppColors.accent,
            barWidth: 2,
            isCurved: true,
            curveSmoothness: 0.35,
            isStrokeCapRound: true,
            belowBarData: BarAreaData(show: false),
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, bar, index) =>
                FlDotCirclePainter(
                  radius: 3,
                  color: bar.color ?? AppColors.accent,
                  strokeWidth: 2,
                  strokeColor: AppColors.surfaceDark,
                ),
            ),
          ),
        ],
        minY: _minY(),
        maxY: _maxY(),
      ),
    );
  }

  double _verticalInterval() {
    if (data.isEmpty) return 1000;
    final values = data.map((e) => e.profit).toList();
    final max = values.reduce((a, b) => a > b ? a : b);
    final min = values.reduce((a, b) => a < b ? a : b);
    final range = (max - min).abs();
    if (range <= 0) return 100;
    return (range / 4);
  }

  double _titleInterval() {
    final len = data.length;
    if (len <= 5) return 1;
    if (len <= 10) return 2;
    return (len / 5).ceilToDouble();
  }

  double _minY() {
    if (data.isEmpty) return 0;
    final values = data.map((e) => e.profit).toList();
    final min = values.reduce((a, b) => a < b ? a : b);
    return min - (min.abs() * 0.1);
  }

  double _maxY() {
    if (data.isEmpty) return 100;
    final values = data.map((e) => e.profit).toList();
    final max = values.reduce((a, b) => a > b ? a : b);
    return max + (max.abs() * 0.1);
  }
}
