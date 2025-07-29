class DashboardStats {
  late final int totalCourses;
  late final int publishedCourses;
  late final int draftCourses;
  late final int totalStudents;
  late final int activeStudents;
  late final double totalRevenue;
  late final double monthlyRevenue;
  late final int totalQuizzes;
  late final int pendingSubmissions;
  late final double averageRating;
  late final int totalReviews;
  final List<MonthlyEarning> monthlyEarnings;
  final List<CourseStats> topCourses;

  DashboardStats({
    required this.totalCourses,
    required this.publishedCourses,
    required this.draftCourses,
    required this.totalStudents,
    required this.activeStudents,
    required this.totalRevenue,
    required this.monthlyRevenue,
    required this.totalQuizzes,
    required this.pendingSubmissions,
    required this.averageRating,
    required this.totalReviews,
    required this.monthlyEarnings,
    required this.topCourses,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalCourses: json['totalCourses'] ?? 0,
      publishedCourses: json['publishedCourses'] ?? 0,
      draftCourses: json['draftCourses'] ?? 0,
      totalStudents: json['totalStudents'] ?? 0,
      activeStudents: json['activeStudents'] ?? 0,
      totalRevenue: (json['totalRevenue'] ?? 0.0).toDouble(),
      monthlyRevenue: (json['monthlyRevenue'] ?? 0.0).toDouble(),
      totalQuizzes: json['totalQuizzes'] ?? 0,
      pendingSubmissions: json['pendingSubmissions'] ?? 0,
      averageRating: (json['averageRating'] ?? 0.0).toDouble(),
      totalReviews: json['totalReviews'] ?? 0,
      monthlyEarnings: (json['monthlyEarnings'] as List? ?? [])
          .map((e) => MonthlyEarning.fromJson(e as Map<String, dynamic>))
          .toList(),
      topCourses: (json['topCourses'] as List? ?? [])
          .map((c) => CourseStats.fromJson(c as Map<String, dynamic>))
          .toList(),
    );
  }
}

class MonthlyEarning {
  final String month;
  final double amount;
  final int enrollments;

  MonthlyEarning({
    required this.month,
    required this.amount,
    required this.enrollments,
  });

  factory MonthlyEarning.fromJson(Map<String, dynamic> json) {
    return MonthlyEarning(
      month: json['month'] ?? '',
      amount: (json['amount'] ?? 0.0).toDouble(),
      enrollments: json['enrollments'] ?? 0,
    );
  }
}

class CourseStats {
  final String courseId;
  final String courseName;
  final int enrollments;
  final double revenue;
  final double rating;

  CourseStats({
    required this.courseId,
    required this.courseName,
    required this.enrollments,
    required this.revenue,
    required this.rating,
  });

  factory CourseStats.fromJson(Map<String, dynamic> json) {
    return CourseStats(
      courseId: json['courseId'] ?? '',
      courseName: json['courseName'] ?? '',
      enrollments: json['enrollments'] ?? 0,
      revenue: (json['revenue'] ?? 0.0).toDouble(),
      rating: (json['rating'] ?? 0.0).toDouble(),
    );
  }
}
