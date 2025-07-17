import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:mentorcraft2/student/models/course.dart';

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
    print("Course Progress Length: ${widget.courseProgress.length}");
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CategoryPieChartSection(courseProgress: [
            CourseProgress(
              courseId: 'flutter-101',
              courseName: 'Flutter for Beginners',
              category: 'Mobile Development',
              totalMinutes: 100,
              minutesCompleted: 60,
              lastAccessed: DateTime.now().subtract(const Duration(days: 1)),
              courseStartDate: DateTime.now().subtract(const Duration(days: 10)),
              activityLogs: [
                ActivityLog(date: DateTime.now().subtract(const Duration(days: 3)),minutesSpent: 24),
                ActivityLog(date: DateTime.now().subtract(const Duration(days: 2)), minutesSpent: 24),
                ActivityLog(date: DateTime.now().subtract(const Duration(days: 1)), minutesSpent: 24),
              ], percentComplete: 30,
            ),
            CourseProgress(
              courseId: 'data-science',
              courseName: 'Intro to Data Science',
              category: 'Data Science',
              totalMinutes: 90,
              minutesCompleted: 45,
              lastAccessed: DateTime.now().subtract(const Duration(days: 2)),
              courseStartDate: DateTime.now().subtract(const Duration(days: 15)),
              activityLogs: [
                ActivityLog(date: DateTime.now().subtract(const Duration(days: 4)),minutesSpent: 15),
                ActivityLog(date: DateTime.now().subtract(const Duration(days: 2)), minutesSpent: 24,),
              ], percentComplete: 45,
            ),
          ],),
          const SizedBox(height: 24),
          _buildLearningLineChart(),
          const SizedBox(height: 24),
          _buildEngagementHeatmap(),
        ],
      ),
    );
  }

  Map<String, int> _getCategoryData() {
    final categoryCount = <String, int>{};
    for (final course in widget.courseProgress) {
      categoryCount[course.category] = (categoryCount[course.category] ?? 0) + 1;
    }

    // Optional: add missing categories as zero to keep consistent legend
    const allCategories = [
      'Mobile Development',
      'Data Science',
      'Design',
      'Web Development',
      'Business',
    ];

    for (final cat in allCategories) {
      categoryCount.putIfAbsent(cat, () => 0);
    }

    return categoryCount;
  }

  List<PieChartSectionData> _buildPieSections(Map<String, int> categoryData) {
    final total = categoryData.values.fold(0, (sum, count) => sum + count);
    if (total == 0) return [];

    final categoryColors = {
      'Mobile Development': Colors.blue,
      'Data Science': Colors.red,
      'Design': Colors.purple,
      'Web Development': Colors.orange,
      'Business': Colors.teal,
    };

    return categoryData.entries.map((entry) {
      final percent = (entry.value / total) * 100;
      return PieChartSectionData(
        color: categoryColors[entry.key] ?? Colors.grey,
        value: entry.value.toDouble(),
        title: entry.value == 0 ? '' : '${percent.toStringAsFixed(0)}%',
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Widget _buildPieChartLegend(Map<String, int> categoryData) {
    final categoryColors = {
      'Mobile Development': Colors.blue,
      'Data Science': Colors.red,
      'Design': Colors.purple,
      'Web Development': Colors.orange,
      'Business': Colors.teal,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: categoryData.entries.map((entry) {
        final color = categoryColors[entry.key] ?? Colors.grey;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  entry.key,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Text(
                entry.value.toString(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLearningLineChart() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Learning Activity (Hours)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 220,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 1,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.withOpacity(0.2),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          const style = TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          );
                          String text;
                          switch (value.toInt()) {
                            case 0:
                              text = 'Mon';
                              break;
                            case 2:
                              text = 'Wed';
                              break;
                            case 4:
                              text = 'Fri';
                              break;
                            case 6:
                              text = 'Sun';
                              break;
                            default:
                              return Container();
                          }
                          return Text(text, style: style);
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value % 1 != 0) return Container();
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          );
                        },
                        reservedSize: 30,
                      ),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.grey.withOpacity(0.2)),
                  ),
                  minX: 0,
                  maxX: 6,
                  minY: 0,
                  maxY: 4,
                  lineBarsData: [
                    LineChartBarData(
                      spots: const [
                        FlSpot(0, 1.5),
                        FlSpot(1, 2.5),
                        FlSpot(2, 2),
                        FlSpot(3, 3),
                        FlSpot(4, 2.5),
                        FlSpot(5, 1.8),
                        FlSpot(6, 3.2),
                      ],
                      isCurved: true,
                      color: AppColors.primary,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppColors.primary.withOpacity(0.2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEngagementHeatmap() {
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month, 1);
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;

    final heatmapDatasets = <DateTime, int>{};
    for (var i = 0; i < daysInMonth; i++) {
      final date = startDate.add(Duration(days: i));
      if (date.isAfter(now)) continue;
      final value = (date.day * 7) % 5;
      if (value > 0) {
        heatmapDatasets[date] = value;
      }
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Learning Engagement',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Daily learning activity for this month',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: HeatMapCalendar(
                size: 35,
                datasets: heatmapDatasets,
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
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildHeatmapColorKey('Less', const Color(0xFFCCE5FF)),
                const SizedBox(width: 6),
                _buildHeatmapColorKey('', const Color(0xFF99CCFF)),
                const SizedBox(width: 6),
                _buildHeatmapColorKey('', const Color(0xFF66B2FF)),
                const SizedBox(width: 6),
                _buildHeatmapColorKey('', const Color(0xFF3399FF)),
                const SizedBox(width: 6),
                _buildHeatmapColorKey('More', AppColors.primary),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeatmapColorKey(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        if (label.isNotEmpty) const SizedBox(width: 4),
        if (label.isNotEmpty)
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
      ],
    );
  }
}
