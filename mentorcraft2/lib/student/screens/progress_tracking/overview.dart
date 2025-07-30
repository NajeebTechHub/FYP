import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../theme/color.dart';
import '../../models/course_progress.dart';
import 'course_progress_page.dart';

class OverviewTab extends StatefulWidget {
  final ProgressSummary progressSummary;
  final List<CourseProgress> courseProgressList;
  final bool isTablet;

  const OverviewTab({
    Key? key,
    required this.progressSummary,
    required this.courseProgressList,
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
    "Education is the most powerful weapon which you can use to change the world."
  ];

  @override
  void initState() {
    super.initState();
    _courseProgress = widget.courseProgressList;

    _progressSummary = widget.progressSummary.copyWith(
      totalCoursesEnrolled: _courseProgress.length,
      coursesCompleted: _courseProgress.where((c) => c.percentComplete == 1.0).length,
    );

    _loadLearningHours();
  }

  Future<void> _loadLearningHours() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    try {
      final learningHours = await calculateLearningHours(userId);
      setState(() {
        _progressSummary = _progressSummary.copyWith(totalLearningHours: learningHours);
      });
    } catch (e) {
      debugPrint("Error calculating learning hours: $e");
    }
  }

  Future<int> calculateLearningHours(String userId) async {
    int totalMinutes = 0;
    final coursesSnapshot = await FirebaseFirestore.instance.collection('courses').get();

    for (final courseDoc in coursesSnapshot.docs) {
      final enrolledUserDoc = await courseDoc.reference.collection('enrolledUsers').doc(userId).get();
      if (!enrolledUserDoc.exists) continue;

      final enrolledData = enrolledUserDoc.data();
      if (enrolledData == null || !enrolledData.containsKey('completedLessons')) continue;

      final completedLessonIds = List<String>.from(enrolledData['completedLessons']);
      final modulesSnapshot = await courseDoc.reference.collection('modules').get();

      for (final moduleDoc in modulesSnapshot.docs) {
        final lessonsSnapshot = await moduleDoc.reference.collection('lessons').get();
        for (final lessonDoc in lessonsSnapshot.docs) {
          final lessonId = lessonDoc.id;

          if (completedLessonIds.contains(lessonId)) {
            final data = lessonDoc.data();
            var durationRaw = data['duration'];
            int? duration;

            if (durationRaw is int) {
              duration = durationRaw;
            } else if (durationRaw is String) {
              duration = int.tryParse(durationRaw);
            } else if (durationRaw is double) {
              duration = durationRaw.floor();
            }

            if (duration != null) {
              totalMinutes += duration;
            }
          }
        }
      }
    }

    return (totalMinutes / 60).floor();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTimeFrameSelector(theme),
          _buildSummaryCards(widget.isTablet, theme),
          _buildMotivationalQuote(theme),
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
          ..._courseProgress.map((course) => CourseProgressPage(courseProgressList: [course])).toList(),
        ],
      ),
    );
  }

  Widget _buildTimeFrameSelector(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: DropdownButton<String>(
          value: _selectedTimeFrame,
          icon: Icon(Icons.keyboard_arrow_down, color: theme.colorScheme.primary),
          elevation: 1,
          underline: const SizedBox(),
          style: TextStyle(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() => _selectedTimeFrame = newValue);
            }
          },
          borderRadius: BorderRadius.circular(12),
          items: _timeFrames.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSummaryCards(bool isTablet, ThemeData theme) {
    Widget buildCard(String title, String value, IconData icon, Color color) {
      return Expanded(
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(height: 12),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: isTablet ? 28 : 22,
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    List<Widget> cards = [
      buildCard('Total Courses', _progressSummary.totalCoursesEnrolled.toString(), Icons.collections_bookmark, AppColors.primary),
      buildCard('Completed', _progressSummary.coursesCompleted.toString(), Icons.check_circle, Colors.green),
      buildCard('Certificates', _progressSummary.certificatesEarned.toString(), Icons.workspace_premium, Colors.amber),
      buildCard('Learning Hours', _progressSummary.totalLearningHours.toString(), Icons.timer, AppColors.accent),
    ];

    if (isTablet) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(children: cards.expand((card) => [card, const SizedBox(width: 12)]).toList()..removeLast()),
      );
    } else {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(children: cards.sublist(0, 2).expand((card) => [card, const SizedBox(width: 12)]).toList()..removeLast()),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(children: cards.sublist(2, 4).expand((card) => [card, const SizedBox(width: 12)]).toList()..removeLast()),
          ),
        ],
      );
    }
  }

  Widget _buildMotivationalQuote(ThemeData theme) {
    return GestureDetector(
      onTap: () {
        setState(() => _currentQuoteIndex = (_currentQuoteIndex + 1) % _motivationalQuotes.length);
      },
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary.withOpacity(0.7), AppColors.darkBlue],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.format_quote, color: Colors.white, size: 24),
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
                    style: TextStyle(color: Colors.white70, fontSize: 12),
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
