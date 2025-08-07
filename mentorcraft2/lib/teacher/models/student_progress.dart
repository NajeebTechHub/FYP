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
  final List<Map<String, dynamic>> lessonProgress;
  final List<Map<String, dynamic>> quizAttempts;
  final double overallGrade;
  final String status;
  final int timeSpent;

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

  static List<Map<String, dynamic>> _safeListOfMaps(dynamic value, String fieldName) {
    if (value is List) {
      return value.whereType<Map<String, dynamic>>().toList();
    } else {
      return [];
    }
  }

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
      enrolledAt: (map['enrolledAt'] as Timestamp).toDate(),
      lastAccessedAt: (map['lastAccessedAt'] as Timestamp).toDate(),
      totalLessons: map['totalLessons'] ?? 0,
      completedLessons: map['completedLessons'] ?? 0,
      lessonProgress: _safeListOfMaps(map['lessonProgress'], 'lessonProgress'),
      quizAttempts: _safeListOfMaps(map['quizAttempts'], 'quizAttempts'),
      overallGrade: (map['overallGrade'] ?? 0.0).toDouble(),
      status: map['status'] ?? 'in_progress',
      timeSpent: (map['timeSpent'] is int) ? map['timeSpent'] : 0,
    );
  }

  factory StudentProgress.fromFirestoreData({
    required Map<String, dynamic> enrolledUserData,
    required Map<String, dynamic> courseData,
    required List<Map<String, dynamic>> quizSubmissions,
  }) {
    final int completedLessons = (enrolledUserData['completedLessons'] ?? []).length;
    final int totalLessons = courseData['lessonsCount'] ?? 0;

    final double progress = totalLessons > 0
        ? (completedLessons / totalLessons) * 100
        : 0;

    double totalScore = 0;
    for (var quiz in quizSubmissions) {
      totalScore += (quiz['score'] ?? 0).toDouble();
    }
    final double averageGrade = quizSubmissions.isNotEmpty
        ? (totalScore / quizSubmissions.length)
        : 0;

    return StudentProgress(
      id: enrolledUserData['id'] ?? '',
      studentId: enrolledUserData['studentId'] ?? '',
      studentName: enrolledUserData['studentName'] ?? '',
      studentEmail: enrolledUserData['studentEmail'] ?? '',
      studentAvatar: enrolledUserData['studentAvatar'] ?? '',
      courseId: courseData['id'] ?? '',
      courseName: courseData['title'] ?? '',
      progressPercentage: progress,
      enrolledAt: (enrolledUserData['enrolledAt'] as Timestamp).toDate(),
      lastAccessedAt: (enrolledUserData['lastAccessedAt'] as Timestamp).toDate(),
      totalLessons: totalLessons,
      completedLessons: completedLessons,
      lessonProgress: _safeListOfMaps(enrolledUserData['lessonProgress'], 'lessonProgress'),
      quizAttempts: quizSubmissions,
      overallGrade: averageGrade,
      status: enrolledUserData['status'] ?? 'in_progress',
      timeSpent: (enrolledUserData['timeSpent'] is int)
          ? enrolledUserData['timeSpent']
          : 0,
    );
  }
}
