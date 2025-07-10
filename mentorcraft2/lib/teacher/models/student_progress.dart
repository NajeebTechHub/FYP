import 'package:cloud_firestore/cloud_firestore.dart';

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

  factory StudentProgress.fromMap(Map<String, dynamic> map) {
    return StudentProgress(
      id: map['id'] ?? '',
      studentId: map['studentId'] ?? '',
      studentName: map['studentName'] ?? '',
      studentEmail: map['studentEmail'] ?? '',
      studentAvatar: map['studentAvatar'] ?? '',
      courseId: map['courseId'] ?? '',
      courseName: map['courseName'] ?? '',
      progressPercentage: (map['progressPercentage'] ?? 0.0).toDouble(),
      enrolledAt: (map['enrolledAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastAccessedAt: (map['lastAccessedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      totalLessons: map['totalLessons'] ?? 0,
      completedLessons: map['completedLessons'] ?? 0,
      lessonProgress: (map['lessonProgress'] as List<dynamic>?)
          ?.map((l) => LessonProgress.fromJson(l))
          .toList() ??
          [],
      quizAttempts: (map['quizAttempts'] as List<dynamic>?)
          ?.map((q) => QuizAttempt.fromJson(q))
          .toList() ??
          [],
      overallGrade: (map['overallGrade'] ?? 0.0).toDouble(),
      status: map['status'] ?? 'enrolled',
      timeSpent: map['timeSpent'] ?? 0,
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
      completedAt: json['completedAt'] != null ? DateTime.tryParse(json['completedAt']) : null,
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
      attemptedAt: json['attemptedAt'] != null ? DateTime.parse(json['attemptedAt']) : DateTime.now(),
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
