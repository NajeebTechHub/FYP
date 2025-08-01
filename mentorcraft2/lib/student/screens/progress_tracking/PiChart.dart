import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/course_progress.dart';

class CategoryPieChartSection extends StatelessWidget {
  final List<CourseProgress> courseProgress;

  const CategoryPieChartSection({super.key, required this.courseProgress});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      color: colorScheme.surface,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Courses by Category',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
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
                    child: _buildPieChartLegend(context, courseProgress),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static final Map<String, Color> _categoryColorCache = {};

  Color _generateColorFromString(String input) {
    final hash = input.codeUnits.fold(0, (prev, elem) => prev + elem);
    final random = Random(hash);
    return Color.fromARGB(
      255,
      100 + random.nextInt(156),
      100 + random.nextInt(156),
      100 + random.nextInt(156),
    );
  }

  List<PieChartSectionData> _getCategorySections(List<CourseProgress> data) {
    final categoryCount = <String, int>{};

    for (final course in data) {
      final category = course.courseName.trim().isNotEmpty ? course.courseName.trim() : 'Uncategorized';
      categoryCount[category] = (categoryCount[category] ?? 0) + 1;
    }

    return categoryCount.entries.map((entry) {
      final category = entry.key;
      _categoryColorCache[category] ??= _generateColorFromString(category);

      return PieChartSectionData(
        color: _categoryColorCache[category],
        value: entry.value.toDouble(),
        title: '',
        radius: 50,
      );
    }).toList();
  }

  Widget _buildPieChartLegend(BuildContext context, List<CourseProgress> data) {
    final categoryCount = <String, int>{};
    final colorScheme = Theme.of(context).colorScheme;

    for (final course in data) {
      final category = course.courseName.trim().isNotEmpty ? course.courseName.trim() : 'Uncategorized';
      categoryCount[category] = (categoryCount[category] ?? 0) + 1;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: categoryCount.entries.map((entry) {
        final color = _categoryColorCache[entry.key] ?? _generateColorFromString(entry.key);

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
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              Text(
                entry.value.toString(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
