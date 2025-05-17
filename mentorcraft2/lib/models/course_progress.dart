class CourseProgress {
  final String courseId;
  final String courseName;
  final String category;
  final double percentComplete;
  final int totalMinutes;
  final int minutesCompleted;
  final DateTime lastAccessed;
  final DateTime courseStartDate;
  final List<ActivityLog> activityLogs;

  CourseProgress({
    required this.courseId,
    required this.courseName,
    required this.category,
    required this.percentComplete,
    required this.totalMinutes,
    required this.minutesCompleted,
    required this.lastAccessed,
    required this.courseStartDate,
    required this.activityLogs,
  });

  int get estimatedMinutesLeft => (totalMinutes - minutesCompleted).clamp(0, totalMinutes);

  // Simplified example data for demonstration
  static List<CourseProgress> getSampleProgressData() {
    return [
      CourseProgress(
        courseId: "c1",
        courseName: "Flutter App Development Masterclass",
        category: "Mobile Development",
        percentComplete: 0.75,
        totalMinutes: 1200,
        minutesCompleted: 900,
        lastAccessed: DateTime.now().subtract(const Duration(days: 1)),
        courseStartDate: DateTime.now().subtract(const Duration(days: 45)),
        activityLogs: _generateActivityLogs(60, 0.8),
      ),
      CourseProgress(
        courseId: "c2",
        courseName: "Advanced Machine Learning",
        category: "Data Science",
        percentComplete: 0.45,
        totalMinutes: 1800,
        minutesCompleted: 810,
        lastAccessed: DateTime.now().subtract(const Duration(days: 3)),
        courseStartDate: DateTime.now().subtract(const Duration(days: 30)),
        activityLogs: _generateActivityLogs(30, 0.6),
      ),
      CourseProgress(
        courseId: "c3",
        courseName: "UX/UI Design Principles",
        category: "Design",
        percentComplete: 0.92,
        totalMinutes: 900,
        minutesCompleted: 828,
        lastAccessed: DateTime.now(),
        courseStartDate: DateTime.now().subtract(const Duration(days: 20)),
        activityLogs: _generateActivityLogs(20, 0.9),
      ),
      CourseProgress(
        courseId: "c4",
        courseName: "Web Development with React",
        category: "Web Development",
        percentComplete: 0.35,
        totalMinutes: 1500,
        minutesCompleted: 525,
        lastAccessed: DateTime.now().subtract(const Duration(days: 5)),
        courseStartDate: DateTime.now().subtract(const Duration(days: 15)),
        activityLogs: _generateActivityLogs(15, 0.4),
      ),
      CourseProgress(
        courseId: "c5",
        courseName: "Project Management Fundamentals",
        category: "Business",
        percentComplete: 0.6,
        totalMinutes: 720,
        minutesCompleted: 432,
        lastAccessed: DateTime.now().subtract(const Duration(days: 2)),
        courseStartDate: DateTime.now().subtract(const Duration(days: 25)),
        activityLogs: _generateActivityLogs(25, 0.7),
      ),
    ];
  }

  // Helper to generate fake activity logs
  static List<ActivityLog> _generateActivityLogs(int days, double completionRate) {
    final logs = <ActivityLog>[];
    final now = DateTime.now();
    final random = DateTime.now().millisecondsSinceEpoch;

    for (int i = days - 1; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      // Create some variability in daily minutes
      final minutes = (((random + i) % 5) + 1) * 15; // 15-75 minutes per day

      // Create some gaps in the learning streak
      if ((random + i) % 7 != 0) {
        logs.add(ActivityLog(
          date: date,
          minutesSpent: minutes,
        ));
      }
    }
    return logs;
  }
}

class ActivityLog {
  final DateTime date;
  final int minutesSpent;

  ActivityLog({
    required this.date,
    required this.minutesSpent,
  });
}

class Certificate {
  final String id;
  final String courseId;
  final String courseName;
  final String imageUrl;
  final DateTime dateEarned;
  final String category;

  Certificate({
    required this.id,
    required this.courseId,
    required this.courseName,
    required this.imageUrl,
    required this.dateEarned,
    required this.category,
  });

  // Sample certificate data
  static List<Certificate> getSampleCertificates() {
    return [
      Certificate(
        id: "cert1",
        courseId: "c3",
        courseName: "UX/UI Design Principles",
        imageUrl: "attached_assets/certificate_template.png",
        dateEarned: DateTime.now().subtract(const Duration(days: 5)),
        category: "Design",
      ),
      Certificate(
        id: "cert2",
        courseId: "c5",
        courseName: "Project Management Fundamentals",
        imageUrl: "attached_assets/certificate_template.png",
        dateEarned: DateTime.now().subtract(const Duration(days: 10)),
        category: "Business",
      ),
    ];
  }
}

class ProgressSummary {
  final int totalCoursesEnrolled;
  final int coursesCompleted;
  final int certificatesEarned;
  final int totalLearningHours;
  final Map<String, int> categoryCompletion;
  final Map<DateTime, int> dailyLearningMinutes;
  final Map<DateTime, int> heatmapData;
  final List<Certificate> certificates;

  ProgressSummary({
    required this.totalCoursesEnrolled,
    required this.coursesCompleted,
    required this.certificatesEarned,
    required this.totalLearningHours,
    required this.categoryCompletion,
    required this.dailyLearningMinutes,
    required this.heatmapData,
    required this.certificates,
  });

  // Method to generate a progress summary from course progress data
  static ProgressSummary generateFromCourseProgress(List<CourseProgress> courses) {
    final categoryCompletion = <String, int>{};
    var totalLearningMinutes = 0;
    final dailyMinutes = <DateTime, int>{};
    final heatmap = <DateTime, int>{};

    // Count completed courses
    final completedCourses = courses.where((c) => c.percentComplete >= 0.95).length;

    // Process course data
    for (final course in courses) {
      // Update category completion
      final category = course.category;
      if (course.percentComplete >= 0.95) {
        categoryCompletion[category] = (categoryCompletion[category] ?? 0) + 1;
      }

      // Calculate total learning time
      totalLearningMinutes += course.minutesCompleted;

      // Aggregate daily learning minutes
      for (final log in course.activityLogs) {
        final date = DateTime(log.date.year, log.date.month, log.date.day);
        dailyMinutes[date] = (dailyMinutes[date] ?? 0) + log.minutesSpent;

        // Create heatmap data (0-4 scale for activity intensity)
        final intensity = log.minutesSpent ~/ 15; // 0-4 scale based on 15 min increments
        heatmap[date] = (heatmap[date] ?? 0) + intensity.clamp(0, 4);
      }
    }

    // Get certificates
    final certificates = Certificate.getSampleCertificates();

    return ProgressSummary(
      totalCoursesEnrolled: courses.length,
      coursesCompleted: completedCourses,
      certificatesEarned: certificates.length,
      totalLearningHours: totalLearningMinutes ~/ 60,
      categoryCompletion: categoryCompletion,
      dailyLearningMinutes: dailyMinutes,
      heatmapData: heatmap,
      certificates: certificates,
    );
  }
}