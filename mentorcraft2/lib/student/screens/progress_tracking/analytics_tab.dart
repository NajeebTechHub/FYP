import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
  Map<DateTime, int> _engagementData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEngagementData();
  }

  Future<void> _loadEngagementData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userId = user.uid;
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final dataMap = <DateTime, int>{};


    try {
      for (final course in widget.courseProgress) {
        final courseId = course.courseId;

        final doc = await FirebaseFirestore.instance
            .collection('courses')
            .doc(courseId)
            .collection('enrolledUsers')
            .doc(userId)
            .get();

        if (doc.exists && doc.data()?['lastAccessedDate'] != null) {
          final timestamp = doc['lastAccessedDate'];
          final date = (timestamp as Timestamp).toDate();

          if (date.isAfter(firstDayOfMonth)) {
            final normalized = DateTime(date.year, date.month, date.day);
            dataMap[normalized] = (dataMap[normalized] ?? 0) + 1;
          }
        }
      }
    } catch (e) {
    }

    dataMap.updateAll((_, count) => count.clamp(1, 4));

    setState(() {
      _engagementData = dataMap;
      _isLoading = false;
    });
  }

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
          _buildEngagementHeatmap(cardColor, primaryText, secondaryText),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildEngagementHeatmap(Color cardColor, Color primaryText, Color secondaryText) {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);

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
              'Days you accessed any course this month',
              style: TextStyle(fontSize: 14, color: secondaryText),
            ),
            const SizedBox(height: 16),
            Center(
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : HeatMapCalendar(
                size: 35,
                initDate: firstDayOfMonth,
                datasets: _engagementData,
                colorsets: const {
                  1: Color(0xFFCCE5FF),
                  2: Color(0xFF99CCFF),
                  3: Color(0xFF66B2FF),
                  4: Color(0xFF3399FF),
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
