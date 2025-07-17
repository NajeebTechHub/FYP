import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../theme/color.dart';
import '../../models/course_progress.dart';

class CategoryPieChartSection extends StatelessWidget {
  final List<CourseProgress> courseProgress;

  const CategoryPieChartSection({super.key, required this.courseProgress});

  @override
  Widget build(BuildContext context) {
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
              'Courses by Category',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 240,
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                        sections: _getCategorySections(courseProgress),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: _buildPieChartLegend(courseProgress),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _getCategorySections(List<CourseProgress> data) {
    final categoryColors = {
      'Mobile Development': Colors.blue,
      'Data Science': Colors.red,
      'Design': Colors.purple,
      'Web Development': Colors.orange,
      'Business': Colors.teal,
    };

    final categoryCount = <String, int>{};
    for (final course in data) {
      categoryCount[course.category] =
          (categoryCount[course.category] ?? 0) + 1;
    }

    return categoryCount.entries.map((entry) {
      final color = categoryColors[entry.key] ?? Colors.grey;
      return PieChartSectionData(
        color: color,
        value: entry.value.toDouble(),
        title: '',
        radius: 50,
      );
    }).toList();
  }

  Widget _buildPieChartLegend(List<CourseProgress> data) {
    final categoryColors = {
      'Mobile Development': Colors.blue,
      'Data Science': Colors.red,
      'Design': Colors.purple,
      'Web Development': Colors.orange,
      'Business': Colors.teal,
    };

    final categoryCount = <String, int>{};
    for (final course in data) {
      categoryCount[course.category] =
          (categoryCount[course.category] ?? 0) + 1;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: categoryCount.entries.map((entry) {
        final color = categoryColors[entry.key] ?? Colors.grey;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
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
}
