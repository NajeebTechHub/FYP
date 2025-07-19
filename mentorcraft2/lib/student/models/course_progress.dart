class ActivityLog {
  final DateTime date;
  final int minutesSpent;

  ActivityLog({
    required this.date,
    required this.minutesSpent,
  });

  factory ActivityLog.fromMap(Map<String, dynamic> map) {
    return ActivityLog(
      date: DateTime.parse(map['date']),
      minutesSpent: map['minutesSpent'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'minutesSpent': minutesSpent,
    };
  }
}

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

  int get estimatedMinutesLeft =>
      (totalMinutes - minutesCompleted).clamp(0, totalMinutes);

  factory CourseProgress.fromFirestore(String id, Map<String, dynamic> data) {
    final rawLogs = data['activityLogs'];
    return CourseProgress(
      courseId: data['courseId'] ?? id,
      courseName: data['courseName'] ?? '',
      category: data['category'] ?? '',
      percentComplete: (data['percentComplete'] as num?)?.toDouble() ?? 0.0,
      totalMinutes: data['totalMinutes'] ?? 0,
      minutesCompleted: data['minutesCompleted'] ?? 0,
      lastAccessed: data['lastAccessed'] != null
          ? DateTime.tryParse(data['lastAccessed']) ?? DateTime.now()
          : DateTime.now(),
      courseStartDate: data['courseStartDate'] != null
          ? DateTime.tryParse(data['courseStartDate']) ?? DateTime.now()
          : DateTime.now(),
      activityLogs: rawLogs != null
          ? (rawLogs as List)
          .map((e) => ActivityLog.fromMap(Map<String, dynamic>.from(e)))
          .toList()
          : [],
    );
  }


  Map<String, dynamic> toFirestore() {
    return {
      'courseId': courseId,
      'courseName': courseName,
      'category': category,
      'percentComplete': percentComplete,
      'totalMinutes': totalMinutes,
      'minutesCompleted': minutesCompleted,
      'lastAccessed': lastAccessed.toIso8601String(),
      'courseStartDate': courseStartDate.toIso8601String(),
      'activityLogs': activityLogs.map((e) => e.toMap()).toList(),
    };
  }


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
    ];
  }

  static List<ActivityLog> _generateActivityLogs(int days, double completionRate) {
    final logs = <ActivityLog>[];
    final now = DateTime.now();
    final seed = DateTime.now().millisecondsSinceEpoch;

    for (int i = days - 1; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final minutes = (((seed + i) % 5) + 1) * 15;

      if ((seed + i) % 7 != 0) {
        logs.add(ActivityLog(
          date: date,
          minutesSpent: minutes,
        ));
      }
    }
    return logs;
  }
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

  factory Certificate.fromFirestore(String id, Map<String, dynamic> data) {
    return Certificate(
      id: data['id'] ?? id,
      courseId: data['courseId'] ?? '',
      courseName: data['courseName'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      dateEarned: data['dateEarned'] != null
          ? DateTime.tryParse(data['dateEarned']) ?? DateTime.now()
          : DateTime.now(),
      category: data['category'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'courseId': courseId,
      'courseName': courseName,
      'imageUrl': imageUrl,
      'dateEarned': dateEarned.toIso8601String(),
      'category': category,
    };
  }

  static List<Certificate> getSampleCertificates() {
    return [
      Certificate(
        id: "cert1",
        courseId: "c1",
        courseName: "Flutter App Development Masterclass",
        imageUrl: "attached_assets/certificate_template.png",
        dateEarned: DateTime.now().subtract(const Duration(days: 5)),
        category: "Mobile Development",
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

  static ProgressSummary generateFromCourseProgress(
      List<CourseProgress> courses,
      List<Certificate> certificates,
      ) {
    final categoryCompletion = <String, int>{};
    var totalLearningMinutes = 0;
    final dailyMinutes = <DateTime, int>{};
    final heatmap = <DateTime, int>{};

    final completedCourses =
        courses.where((c) => c.percentComplete >= 0.95).length;

    for (final course in courses) {
      final category = course.category;
      if (course.percentComplete >= 0.95) {
        categoryCompletion[category] = (categoryCompletion[category] ?? 0) + 1;
      }

      totalLearningMinutes += course.minutesCompleted;

      for (final log in course.activityLogs) {
        final date = DateTime(log.date.year, log.date.month, log.date.day);
        dailyMinutes[date] = (dailyMinutes[date] ?? 0) + log.minutesSpent;

        final intensity = log.minutesSpent ~/ 15;
        heatmap[date] = (heatmap[date] ?? 0) + intensity.clamp(0, 4);
      }
    }

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

  ProgressSummary copyWith({
    int? totalCoursesEnrolled,
    int? coursesCompleted,
    int? certificatesEarned,
    int? totalLearningHours,
    Map<String, int>? categoryCompletion,
    Map<DateTime, int>? dailyLearningMinutes,
    Map<DateTime, int>? heatmapData,
    List<Certificate>? certificates,
  }) {
    return ProgressSummary(
      totalCoursesEnrolled:
      totalCoursesEnrolled ?? this.totalCoursesEnrolled,
      coursesCompleted: coursesCompleted ?? this.coursesCompleted,
      certificatesEarned: certificatesEarned ?? this.certificatesEarned,
      totalLearningHours: totalLearningHours ?? this.totalLearningHours,
      categoryCompletion: categoryCompletion ?? this.categoryCompletion,
      dailyLearningMinutes: dailyLearningMinutes ?? this.dailyLearningMinutes,
      heatmapData: heatmapData ?? this.heatmapData,
      certificates: certificates ?? this.certificates,
    );
  }

  List<CourseProgress> get recentCourses {
    final allCourses = CourseProgress.getSampleProgressData();
    allCourses.sort((a, b) => b.lastAccessed.compareTo(a.lastAccessed));
    return allCourses.take(5).toList();
  }
}
