import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../utils/constants.dart';

class CustomLineChart extends StatelessWidget {
  final List<FlSpot> spots;
  final String title;
  final String xAxisTitle;
  final String yAxisTitle;
  final Color? lineColor;
  final Color? gradientColor;
  final double minY;
  final double maxY;
  final bool showDots;
  final bool showGrid;
  final bool showLabels;

  const CustomLineChart({
    Key? key,
    required this.spots,
    required this.title,
    required this.xAxisTitle,
    required this.yAxisTitle,
    this.lineColor,
    this.gradientColor,
    this.minY = 0,
    this.maxY = 100,
    this.showDots = true,
    this.showGrid = true,
    this.showLabels = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 300,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: showGrid),
              titlesData: FlTitlesData(
                show: showLabels,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                  ),
                  axisNameWidget: Text(
                    xAxisTitle,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                  ),
                  axisNameWidget: Text(
                    yAxisTitle,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(show: true),
              minX: 0,
              maxX: spots.length.toDouble() - 1,
              minY: minY,
              maxY: maxY,
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: lineColor ?? AppColors.primary,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(show: showDots),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [
                        (gradientColor ?? AppColors.primary).withOpacity(0.3),
                        (gradientColor ?? AppColors.primary).withOpacity(0.0),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class CustomBarChart extends StatelessWidget {
  final List<BarChartGroupData> barGroups;
  final String title;
  final String xAxisTitle;
  final String yAxisTitle;
  final double maxY;
  final List<String>? xLabels;
  final bool showGrid;
  final bool showLabels;

  const CustomBarChart({
    Key? key,
    required this.barGroups,
    required this.title,
    required this.xAxisTitle,
    required this.yAxisTitle,
    required this.maxY,
    this.xLabels,
    this.showGrid = true,
    this.showLabels = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 300,
          child: BarChart(
            BarChartData(
              gridData: FlGridData(show: showGrid),
              titlesData: FlTitlesData(
                show: showLabels,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      if (xLabels != null && value.toInt() < xLabels!.length) {
                        return Text(
                          xLabels![value.toInt()],
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        );
                      }
                      return const Text('');
                    },
                    reservedSize: 30,
                  ),
                  axisNameWidget: Text(
                    xAxisTitle,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                  ),
                  axisNameWidget: Text(
                    yAxisTitle,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(show: true),
              barGroups: barGroups,
              maxY: maxY,
            ),
          ),
        ),
      ],
    );
  }
}

class CustomPieChart extends StatelessWidget {
  final List<PieChartSectionData> sections;
  final String title;
  final bool showLabels;
  final double radius;

  const CustomPieChart({
    Key? key,
    required this.sections,
    required this.title,
    this.showLabels = true,
    this.radius = 100,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: radius * 2,
          child: PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: 0,
              sectionsSpace: 2,
            ),
          ),
        ),
      ],
    );
  }
}

class ChartLegend extends StatelessWidget {
  final List<ChartLegendItem> items;

  const ChartLegend({
    Key? key,
    required this.items,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: items.map((item) => _buildLegendItem(item)).toList(),
    );
  }

  Widget _buildLegendItem(ChartLegendItem item) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: item.color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          item.label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class ChartLegendItem {
  final String label;
  final Color color;

  const ChartLegendItem({
    required this.label,
    required this.color,
  });
}

// Helper function to create bar groups
BarChartGroupData createBarGroup({
  required int x,
  required List<double> values,
  List<Color>? colors,
  double width = 16,
}) {
  return BarChartGroupData(
    x: x,
    barRods: List.generate(
      values.length,
      (index) => BarChartRodData(
        toY: values[index],
        color: colors?[index] ?? AppColors.primary,
        width: width,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
      ),
    ),
  );
}

// Helper function to create pie sections
PieChartSectionData createPieSection({
  required double value,
  required Color color,
  required String title,
  double radius = 100,
  bool showTitle = true,
}) {
  return PieChartSectionData(
    value: value,
    color: color,
    title: showTitle ? title : '',
    radius: radius,
    titleStyle: const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
  );
}