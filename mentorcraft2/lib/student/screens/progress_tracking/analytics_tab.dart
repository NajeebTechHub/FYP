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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CategoryPieChartSection(courseProgress: widget.courseProgress),
          const SizedBox(height: 24),
          _buildLearningLineChart(),
          const SizedBox(height: 24),
          _buildEngagementHeatmap(),
        ],
      ),
    );
  }

  /// LINE CHART — Weekly learning in hours
  Widget _buildLearningLineChart() {
    List<FlSpot> spots = _generateLineChartSpots();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Learning Activity (Hours)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
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
                        getTitlesWidget: (value, _) {
                          const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                          return Text(
                            days[value.toInt() % 7],
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                          );
                        },
                        reservedSize: 30,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, _) => Text(
                          value.toInt().toString(),
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        ),
                        reservedSize: 30,
                      ),
                    ),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true, border: Border.all(color: Colors.grey.withOpacity(0.2))),
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
                      belowBarData: BarAreaData(show: true, color: AppColors.primary.withOpacity(0.2)),
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
    Map<int, double> weekdayHours = {};

    for (final course in widget.courseProgress) {
      for (final log in course.activityLogs) {
        print('Log Date: ${log.date}, Minutes: ${log.minutesSpent}'); // 👈 DEBUG
        int weekday = log.date.weekday - 1; // Monday = 0, Sunday = 6
        weekdayHours[weekday] = (weekdayHours[weekday] ?? 0) + log.minutesSpent / 60.0;
      }
    }

    print('Weekday Hours Map: $weekdayHours'); // 👈 DEBUG

    return List.generate(7, (i) => FlSpot(i.toDouble(), weekdayHours[i]?.toDouble() ?? 0));
  }



  /// 🔥 HEATMAP — Daily engagement (minutes studied)
  Widget _buildEngagementHeatmap() {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final Map<DateTime, int> heatmapData = {};

    for (final course in widget.courseProgress) {
      for (final log in course.activityLogs) {
        DateTime date = DateTime(log.date.year, log.date.month, log.date.day);
        heatmapData[date] = (heatmapData[date] ?? 0) + log.minutesSpent;
      }
    }

    // Normalize to 1–4 intensity scale
    heatmapData.updateAll((_, value) => (value / 20).clamp(1, 4).toInt());

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Learning Engagement',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            const Text(
              'Daily learning activity for this month',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            Center(
              child: HeatMapCalendar(
                size: 35,
                initDate: firstDayOfMonth,
                datasets: heatmapData,
                colorsets: const {
                  1: Color(0xFFCCE5FF),
                  2: Color(0xFF99CCFF),
                  3: Color(0xFF66B2FF),
                  4: Color(0xFF3399FF),
                },
                defaultColor: Colors.white,
                textColor: AppColors.textPrimary,
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
