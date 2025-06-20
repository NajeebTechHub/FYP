class StudentProgress {
  final String id;
  final String studentId;
  final String studentName;
  final String studentEmail;
  final String studentAvatar;
  final String courseId;
  final String courseName;
  final double progressPercentage;
  final DateTime enrolledAt;
  final DateTime lastAccessedAt;
  final int totalLessons;
  final int completedLessons;
  final List<LessonProgress> lessonProgress;
  final List<QuizAttempt> quizAttempts;
  final double overallGrade;
  final String status; // enrolled, in_progress, completed, dropped
  final int timeSpent; // total time in minutes

  StudentProgress({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.studentEmail,
    required this.studentAvatar,
    required this.courseId,
    required this.courseName,
    required this.progressPercentage,
    required this.enrolledAt,
    required this.lastAccessedAt,
    required this.totalLessons,
    required this.completedLessons,
    required this.lessonProgress,
    required this.quizAttempts,
    required this.overallGrade,
    required this.status,
    required this.timeSpent,
  });

  factory StudentProgress.fromJson(Map<String, dynamic> json) {
    return StudentProgress(
      id: json['id'] ?? '',
      studentId: json['studentId'] ?? '',
      studentName: json['studentName'] ?? '',
      studentEmail: json['studentEmail'] ?? '',
      studentAvatar: json['studentAvatar'] ?? '',
      courseId: json['courseId'] ?? '',
      courseName: json['courseName'] ?? '',
      progressPercentage: (json['progressPercentage'] ?? 0.0).toDouble(),
      enrolledAt: DateTime.parse(json['enrolledAt'] ?? DateTime.now().toIso8601String()),
      lastAccessedAt: DateTime.parse(json['lastAccessedAt'] ?? DateTime.now().toIso8601String()),
      totalLessons: json['totalLessons'] ?? 0,
      completedLessons: json['completedLessons'] ?? 0,
      lessonProgress: (json['lessonProgress'] as List?)?.map((l) => LessonProgress.fromJson(l)).toList() ?? [],
      quizAttempts: (json['quizAttempts'] as List?)?.map((q) => QuizAttempt.fromJson(q)).toList() ?? [],
      overallGrade: (json['overallGrade'] ?? 0.0).toDouble(),
      status: json['status'] ?? 'enrolled',
      timeSpent: json['timeSpent'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentId': studentId,
      'studentName': studentName,
      'studentEmail': studentEmail,
      'studentAvatar': studentAvatar,
      'courseId': courseId,
      'courseName': courseName,
      'progressPercentage': progressPercentage,
      'enrolledAt': enrolledAt.toIso8601String(),
      'lastAccessedAt': lastAccessedAt.toIso8601String(),
      'totalLessons': totalLessons,
      'completedLessons': completedLessons,
      'lessonProgress': lessonProgress.map((l) => l.toJson()).toList(),
      'quizAttempts': quizAttempts.map((q) => q.toJson()).toList(),
      'overallGrade': overallGrade,
      'status': status,
      'timeSpent': timeSpent,
    };
  }
}

class LessonProgress {
  final String lessonId;
  final String lessonTitle;
  final bool isCompleted;
  final DateTime? completedAt;
  final int timeSpent; // in minutes
  final double watchPercentage; // for video lessons

  LessonProgress({
    required this.lessonId,
    required this.lessonTitle,
    required this.isCompleted,
    this.completedAt,
    required this.timeSpent,
    required this.watchPercentage,
  });

  factory LessonProgress.fromJson(Map<String, dynamic> json) {
    return LessonProgress(
      lessonId: json['lessonId'] ?? '',
      lessonTitle: json['lessonTitle'] ?? '',
      isCompleted: json['isCompleted'] ?? false,
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
      timeSpent: json['timeSpent'] ?? 0,
      watchPercentage: (json['watchPercentage'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lessonId': lessonId,
      'lessonTitle': lessonTitle,
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
      'timeSpent': timeSpent,
      'watchPercentage': watchPercentage,
    };
  }
}

class QuizAttempt {
  final String quizId;
  final String quizTitle;
  final double score;
  final double percentage;
  final bool passed;
  final DateTime attemptedAt;
  final int timeSpent;
  final int attemptNumber;

  QuizAttempt({
    required this.quizId,
    required this.quizTitle,
    required this.score,
    required this.percentage,
    required this.passed,
    required this.attemptedAt,
    required this.timeSpent,
    required this.attemptNumber,
  });

  factory QuizAttempt.fromJson(Map<String, dynamic> json) {
    return QuizAttempt(
      quizId: json['quizId'] ?? '',
      quizTitle: json['quizTitle'] ?? '',
      score: (json['score'] ?? 0.0).toDouble(),
      percentage: (json['percentage'] ?? 0.0).toDouble(),
      passed: json['passed'] ?? false,
      attemptedAt: DateTime.parse(json['attemptedAt'] ?? DateTime.now().toIso8601String()),
      timeSpent: json['timeSpent'] ?? 0,
      attemptNumber: json['attemptNumber'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'quizId': quizId,
      'quizTitle': quizTitle,
      'score': score,
      'percentage': percentage,
      'passed': passed,
      'attemptedAt': attemptedAt.toIso8601String(),
      'timeSpent': timeSpent,
      'attemptNumber': attemptNumber,
    };
  }
}