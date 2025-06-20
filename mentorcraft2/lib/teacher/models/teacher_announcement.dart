class TeacherAnnouncement {
  final String id;
  final String title;
  final String content;
  final String courseId;
  final String courseName;
  final String teacherId;
  final String teacherName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isUrgent;
  final bool isPublished;
  final List<String> targetStudents; // empty means all students
  final int readCount;
  final String type; // general, assignment, reminder, announcement

  TeacherAnnouncement({
    required this.id,
    required this.title,
    required this.content,
    required this.courseId,
    required this.courseName,
    required this.teacherId,
    required this.teacherName,
    required this.createdAt,
    required this.updatedAt,
    required this.isUrgent,
    required this.isPublished,
    required this.targetStudents,
    required this.readCount,
    required this.type,
  });

  factory TeacherAnnouncement.fromJson(Map<String, dynamic> json) {
    return TeacherAnnouncement(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      courseId: json['courseId'] ?? '',
      courseName: json['courseName'] ?? '',
      teacherId: json['teacherId'] ?? '',
      teacherName: json['teacherName'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      isUrgent: json['isUrgent'] ?? false,
      isPublished: json['isPublished'] ?? true,
      targetStudents: List<String>.from(json['targetStudents'] ?? []),
      readCount: json['readCount'] ?? 0,
      type: json['type'] ?? 'general',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'courseId': courseId,
      'courseName': courseName,
      'teacherId': teacherId,
      'teacherName': teacherName,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isUrgent': isUrgent,
      'isPublished': isPublished,
      'targetStudents': targetStudents,
      'readCount': readCount,
      'type': type,
    };
  }
}

class DashboardStats {
  final int totalCourses;
  final int publishedCourses;
  final int draftCourses;
  final int totalStudents;
  final int activeStudents;
  final double totalRevenue;
  final double monthlyRevenue;
  final int totalQuizzes;
  final int pendingSubmissions;
  final double averageRating;
  final int totalReviews;
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
      monthlyEarnings: (json['monthlyEarnings'] as List?)?.map((e) => MonthlyEarning.fromJson(e)).toList() ?? [],
      topCourses: (json['topCourses'] as List?)?.map((c) => CourseStats.fromJson(c)).toList() ?? [],
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