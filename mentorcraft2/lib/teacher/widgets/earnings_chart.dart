import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/teacher_announcement.dart';

class EarningsChart extends StatelessWidget {
  final List<MonthlyEarning> monthlyEarnings;

  const EarningsChart({
    Key? key,
    required this.monthlyEarnings,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: 2000,
          verticalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey[300]!,
              strokeWidth: 1,
            );
          },
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: Colors.grey[300]!,
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (double value, TitleMeta meta) {
                if (value.toInt() < monthlyEarnings.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      monthlyEarnings[value.toInt()].month,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  );
                } else {
                  return const SizedBox.shrink(); // empty widget
                }
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 2000,
              getTitlesWidget: (double value, TitleMeta meta) {
                return Text(
                  '\$${(value / 1000).toStringAsFixed(0)}k',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              },
              reservedSize: 42,
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey[300]!, width: 1),
        ),
        minX: 0,
        maxX: (monthlyEarnings.length - 1).toDouble(),
        minY: 0,
        maxY: monthlyEarnings.map((e) => e.amount).reduce((a, b) => a > b ? a : b) * 1.2,
        lineBarsData: [
          LineChartBarData(
            spots: monthlyEarnings.asMap().entries.map((entry) {
              return FlSpot(entry.key.toDouble(), entry.value.amount);
            }).toList(),
            isCurved: true,
            gradient: LinearGradient(
              colors: [
                Colors.blue.shade400,
                Colors.blue.shade600,
              ],
            ),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: Colors.blue.shade600,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  Colors.blue.shade400.withOpacity(0.3),
                  Colors.blue.shade400.withOpacity(0.1),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            tooltipMargin: 8,
            tooltipRoundedRadius: 8,
            tooltipPadding: const EdgeInsets.all(8),
            getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
              return touchedBarSpots.map((barSpot) {
                return LineTooltipItem(
                  '\$${barSpot.y.toStringAsFixed(0)}',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }
}