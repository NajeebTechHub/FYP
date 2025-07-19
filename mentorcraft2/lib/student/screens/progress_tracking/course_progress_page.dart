import 'package:flutter/material.dart';
import '../../models/course_progress.dart';
import '../../../theme/color.dart';

class CourseProgressPage extends StatelessWidget {
  final List<CourseProgress> courseProgressList;

  const CourseProgressPage({
    Key? key,
    required this.courseProgressList,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Inject mock data if list is empty (for testing)
    final List<CourseProgress> data = courseProgressList.isNotEmpty
        ? courseProgressList
        : _getMockCourseProgress();

    final course = data.first;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Course Icon or Placeholder
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                    Icons.play_circle_fill, size: 36, color: AppColors.primary),
              ),
              const SizedBox(width: 16),
              // Course Title & Progress
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.courseName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      course.category,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Progress bar
                    LinearProgressIndicator(
                      value: course.percentComplete,
                      color: AppColors.primary,
                      backgroundColor: AppColors.primary.withOpacity(0.2),
                      minHeight: 6,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Percentage
              Text(
                '${(course.percentComplete * 100).toInt()}%',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<CourseProgress> _getMockCourseProgress() {
    return [
      CourseProgress(
          courseId: 'C101',
          courseName: 'Flutter Basics',
          category: 'Mobile Development',
          percentComplete: 0.6,
          totalMinutes: 300,
          minutesCompleted: 180,
          lastAccessed: DateTime.now().subtract(const Duration(days: 2)),
          courseStartDate: DateTime.now().subtract(const Duration(days: 15)),
          activityLogs: [
            ActivityLog(date: DateTime.now().subtract(const Duration(days: 3)),
                minutesSpent: 45),
            ActivityLog(date: DateTime.now().subtract(const Duration(days: 2)),
                minutesSpent: 42),
            ActivityLog(date: DateTime.now().subtract(const Duration(days: 1)),
                minutesSpent: 23),
          ],

      ),
      CourseProgress(
        courseId: 'C102',
        courseName: 'Python for Data Science',
        category: 'Data Science',
        percentComplete: 0.8,
        totalMinutes: 400,
        minutesCompleted: 320,
        lastAccessed: DateTime.now().subtract(const Duration(days: 1)),
        courseStartDate: DateTime.now().subtract(const Duration(days: 20)),
        activityLogs: [
          ActivityLog(date: DateTime.now().subtract(const Duration(days: 3)),
              minutesSpent: 45),
          ActivityLog(date: DateTime.now().subtract(const Duration(days: 2)),
              minutesSpent: 42),
          ActivityLog(date: DateTime.now().subtract(const Duration(days: 1)),
              minutesSpent: 23),
        ],
      ),
      CourseProgress(
        courseId: 'C103',
        courseName: 'UI/UX Design',
        category: 'Design',
        percentComplete: 0.4,
        totalMinutes: 250,
        minutesCompleted: 100,
        lastAccessed: DateTime.now().subtract(const Duration(days: 5)),
        courseStartDate: DateTime.now().subtract(const Duration(days: 30)),
        activityLogs: [
          ActivityLog(date: DateTime.now().subtract(const Duration(days: 3)),
              minutesSpent: 45),
          ActivityLog(date: DateTime.now().subtract(const Duration(days: 2)),
              minutesSpent: 42),
          ActivityLog(date: DateTime.now().subtract(const Duration(days: 1)),
              minutesSpent: 23),
        ],
      ),
      CourseProgress(
        courseId: 'C104',
        courseName: 'React Web App',
        category: 'Web Development',
        percentComplete: 0.75,
        totalMinutes: 350,
        minutesCompleted: 262,
        lastAccessed: DateTime.now().subtract(const Duration(days: 3)),
        courseStartDate: DateTime.now().subtract(const Duration(days: 25)),
        activityLogs: [
          ActivityLog(date: DateTime.now().subtract(const Duration(days: 3)),
              minutesSpent: 45),
          ActivityLog(date: DateTime.now().subtract(const Duration(days: 2)),
              minutesSpent: 42),
          ActivityLog(date: DateTime.now().subtract(const Duration(days: 1)),
              minutesSpent: 23),
        ],
      ),
      CourseProgress(
        courseId: 'C105',
        courseName: 'Startup Fundamentals',
        category: 'Business',
        percentComplete: 0.5,
        totalMinutes: 200,
        minutesCompleted: 100,
        lastAccessed: DateTime.now().subtract(const Duration(days: 6)),
        courseStartDate: DateTime.now().subtract(const Duration(days: 18)),
        activityLogs: [
          ActivityLog(date: DateTime.now().subtract(const Duration(days: 3)),
              minutesSpent: 45),
          ActivityLog(date: DateTime.now().subtract(const Duration(days: 2)),
              minutesSpent: 42),
          ActivityLog(date: DateTime.now().subtract(const Duration(days: 1)),
              minutesSpent: 23),
        ],
      ),
    ];
  }
}
