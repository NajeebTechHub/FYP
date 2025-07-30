import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import '../../../theme/color.dart';
import '../../models/course_progress.dart';
import 'PiChart.dart';

class AnalyticsTab extends StatefulWidget {
  final List<CourseProgress> courseProgress;
  final bool isTablet;

  const AnalyticsTab({
    Key? key,
    required this.courseProgress,
    required this.isTablet,
  }) : super(key: key);

  @override
  State<AnalyticsTab> createState() => _AnalyticsTabState();
}

class _AnalyticsTabState extends State<AnalyticsTab> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.cardDark : AppColors.white;
    final primaryText = isDark ? AppColors.textLight : AppColors.textPrimary;
    final secondaryText = isDark ? AppColors.textFaded : AppColors.textSecondary;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CategoryPieChartSection(courseProgress: widget.courseProgress),
          const SizedBox(height: 24),
          _buildLearningLineChart(cardColor, primaryText, secondaryText),
          const SizedBox(height: 24),
          _buildEngagementHeatmap(cardColor, primaryText, secondaryText),
        ],
      ),
    );
  }

  Widget _buildLearningLineChart(Color cardColor, Color primaryText, Color secondaryText) {
    final spots = _generateLineChartSpots();

    return Card(
      color: cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Learning Activity (Hours)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryText),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 220,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true, drawVerticalLine: false),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, _) {
                          const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                          return Text(
                            days[value.toInt() % 7],
                            style: TextStyle(color: secondaryText, fontSize: 12),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, _) => Text(
                          value.toInt().toString(),
                          style: TextStyle(color: secondaryText, fontSize: 12),
                        ),
                      ),
                    ),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: secondaryText.withOpacity(0.2)),
                  ),
                  minX: 0,
                  maxX: 6,
                  minY: 0,
                  maxY: 5,
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: AppColors.primary,
                      barWidth: 3,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppColors.primary.withOpacity(0.2),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<FlSpot> _generateLineChartSpots() {
    final weekdayHours = <int, double>{};

    for (final course in widget.courseProgress) {
      for (final log in course.activityLogs) {
        final weekday = log.date.weekday - 1;
        weekdayHours[weekday] = (weekdayHours[weekday] ?? 0) + log.minutesSpent / 60.0;
      }
    }

    return List.generate(7, (i) => FlSpot(i.toDouble(), weekdayHours[i]?.toDouble() ?? 0));
  }

  Widget _buildEngagementHeatmap(Color cardColor, Color primaryText, Color secondaryText) {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final heatmapData = <DateTime, int>{};

    for (final course in widget.courseProgress) {
      for (final log in course.activityLogs) {
        final date = DateTime(log.date.year, log.date.month, log.date.day);
        heatmapData[date] = (heatmapData[date] ?? 0) + log.minutesSpent;
      }
    }

    heatmapData.updateAll((_, value) => (value / 20).clamp(1, 4).toInt());

    return Card(
      color: cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Learning Engagement',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryText),
            ),
            const SizedBox(height: 8),
            Text(
              'Daily learning activity for this month',
              style: TextStyle(fontSize: 14, color: secondaryText),
            ),
            const SizedBox(height: 16),
            Center(
              child: HeatMapCalendar(
                size: 35,
                initDate: firstDayOfMonth,
                datasets: heatmapData,
                colorsets: const {
                  1: Color(0xFFCCE5FF), // Light blue
                  2: Color(0xFF99CCFF),
                  3: Color(0xFF66B2FF),
                  4: Color(0xFF3399FF), // Darker blue
                },
                defaultColor: AppColors.background,
                textColor: Colors.black,
                weekTextColor: primaryText,
                showColorTip: false,
                monthFontSize: 14,
                weekFontSize: 12,
                borderRadius: 8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
