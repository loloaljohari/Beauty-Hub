import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';
import '../core/utils/responsive.dart';
import '../data/models/report_models.dart';

/// Weekly/monthly bar chart for the "Booking Report" /
/// "Revenue Report" sections, built with fl_chart.
class SimpleBarChart extends StatelessWidget {
  const SimpleBarChart({super.key, required this.points, this.height = 180});

  final List<ChartPointModel> points;
  final double height;

  @override
  Widget build(BuildContext context) {
    final maxValue = points.isEmpty
        ? 10.0
        : points.map((p) => p.value).reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: height.h(context),
      child: BarChart(
        BarChartData(
          maxY: maxValue * 1.2,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= points.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: EdgeInsets.only(top: 6.h(context)),
                    child: Text(
                      points[index].label,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 10.sp(context),
                        color: AppColors.textSecondaryGrey,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups: [
            for (var i = 0; i < points.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: points[i].value,
                    color: AppColors.chartBarPrimary,
                    width: 18.w(context),
                    borderRadius: BorderRadius.circular(6),
                    backDrawRodData: BackgroundBarChartRodData(
                      show: true,
                      toY: maxValue * 1.2,
                      color: AppColors.chartBarSecondary,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

/// Donut chart for "Materials Usage" percentage breakdown.
class MaterialsUsageChart extends StatelessWidget {
  const MaterialsUsageChart({super.key, required this.items});

  final List<MaterialUsageModel> items;

  static const List<Color> _palette = [
    AppColors.primary,
    AppColors.primaryAccent,
    AppColors.decorativeGold,
    AppColors.decorativeRose,
    AppColors.statusWarning,
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 120.w(context),
          height: 120.h(context),
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 32,
              sections: [
                for (var i = 0; i < items.length; i++)
                  PieChartSectionData(
                    value: items[i].percent,
                    color: _palette[i % _palette.length],
                    title: '',
                    radius: 28,
                  ),
              ],
            ),
          ),
        ),
        SizedBox(width: 16.w(context)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < items.length; i++)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 2.h(context)),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: _palette[i % _palette.length],
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 6.w(context)),
                      Expanded(
                        child: Text(
                          items[i].label,
                          style: AppTextStyles.bodySmall.copyWith(
                            fontSize: 12.sp(context),
                          ),
                        ),
                      ),
                      Text(
                        '${items[i].percent.toStringAsFixed(0)}%',
                        style: AppTextStyles.label.copyWith(
                          fontSize: 12.sp(context),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
