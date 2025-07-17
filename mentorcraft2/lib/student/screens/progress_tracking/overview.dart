import 'package:flutter/material.dart';

import '../../../theme/color.dart';
import '../../models/course_progress.dart';
import 'course_progress_page.dart';

class OverviewTab extends StatefulWidget {
  final ProgressSummary progressSummary;
  final bool isTablet;

  const OverviewTab({
    Key? key,
    required this.progressSummary,
    required this.isTablet,
  }) : super(key: key);

  @override
  State<OverviewTab> createState() => _OverviewTabState();
}

class _OverviewTabState extends State<OverviewTab> {
  late List<CourseProgress> _courseProgress;
  late ProgressSummary _progressSummary;
  String _selectedTimeFrame = 'All Time';
  final List<String> _timeFrames = ['This Week', 'This Month', 'All Time'];
  int _currentQuoteIndex = 0;

  final List<String> _motivationalQuotes = [
    "The expert in anything was once a beginner.",
    "Success is not final, failure is not fatal: it is the courage to continue that counts.",
    "Believe you can and you're halfway there.",
    "The beautiful thing about learning is nobody can take it away from you.",
    "Education is the most powerful weapon which you can use to change the world.",
  ];

  @override
  void initState() {
    super.initState();
    _progressSummary = widget.progressSummary;
    _courseProgress = [
      CourseProgress(
        courseId: '001',
        courseName: 'Flutter Basics',
        percentComplete: 0.7,
        totalMinutes: 300,
        minutesCompleted: 210,
        courseStartDate: DateTime.now(),
        activityLogs: [],
        lastAccessed: DateTime.now().subtract(const Duration(days: 2)),
        category: 'Mobile Development',
      ),
      CourseProgress(
        courseId: '002',
        courseName: 'Data Science 101',
        percentComplete: 0.45,
        totalMinutes: 200,
        minutesCompleted: 90,
        courseStartDate: DateTime.now(),
        activityLogs: [],
        lastAccessed: DateTime.now().subtract(const Duration(days: 1)),
        category: 'Data Science',
      ),
    ];

  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTimeFrameSelector(),
          _buildSummaryCards(widget.isTablet),
          _buildMotivationalQuote(),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text(
              'COURSE PROGRESS',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
                letterSpacing: 1.2,
              ),
            ),
          ),
          ..._courseProgress.map((course) => CourseProgressPage(courseProgressList: [course],)).toList(),
        ],
      ),
    );
  }

  Widget _buildTimeFrameSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.darkBlue.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: DropdownButton<String>(
          value: _selectedTimeFrame,
          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.darkBlue),
          elevation: 1,
          underline: const SizedBox(),
          style: const TextStyle(
            color: AppColors.darkBlue,
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedTimeFrame = newValue;
              });
            }
          },
          borderRadius: BorderRadius.circular(12),
          items: _timeFrames.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSummaryCards(bool isTablet) {
    Widget buildSummaryCard(String title, String value, IconData icon, Color color) {
      return Expanded(
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
                const SizedBox(height: 12),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: isTablet ? 28 : 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (isTablet) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            buildSummaryCard('Total Courses', _progressSummary.totalCoursesEnrolled.toString(), Icons.collections_bookmark, AppColors.primary),
            const SizedBox(width: 12),
            buildSummaryCard('Completed', _progressSummary.coursesCompleted.toString(), Icons.check_circle, Colors.green),
            const SizedBox(width: 12),
            buildSummaryCard('Certificates', _progressSummary.certificatesEarned.toString(), Icons.workspace_premium, Colors.amber),
            const SizedBox(width: 12),
            buildSummaryCard('Learning Hours', _progressSummary.totalLearningHours.toString(), Icons.timer, AppColors.accent),
          ],
        ),
      );
    } else {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                buildSummaryCard('Total Courses', _progressSummary.totalCoursesEnrolled.toString(), Icons.collections_bookmark, AppColors.primary),
                const SizedBox(width: 12),
                buildSummaryCard('Completed', _progressSummary.coursesCompleted.toString(), Icons.check_circle, Colors.green),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                buildSummaryCard('Certificates', _progressSummary.certificatesEarned.toString(), Icons.workspace_premium, Colors.amber),
                const SizedBox(width: 12),
                buildSummaryCard('Learning Hours', _progressSummary.totalLearningHours.toString(), Icons.timer, AppColors.accent),
              ],
            ),
          ),
        ],
      );
    }
  }

  Widget _buildMotivationalQuote() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentQuoteIndex = ((_currentQuoteIndex + 1) % _motivationalQuotes.length);
        });
      },
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary.withOpacity(0.7),
              AppColors.darkBlue,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(
              Icons.format_quote,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _motivationalQuotes[_currentQuoteIndex],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tap to see another quote',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
