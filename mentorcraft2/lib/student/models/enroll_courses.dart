import 'package:cloud_firestore/cloud_firestore.dart';
import 'course.dart';

class EnrolledCourse {
  final Course course;
  final double progress;
  final DateTime enrollmentDate;
  final DateTime? lastAccessedDate;
  final List<String> completedLessonIds;

  EnrolledCourse({
    required this.course,
    required this.progress,
    required this.enrollmentDate,
    this.lastAccessedDate,
    required this.completedLessonIds,
  });

  // NEW: Dynamic progress calculator
  // double get calculatedProgress {
  //   final totalLessons = course.totalLessonsCount;
  //   if (totalLessons == 0) return 0.0;
  //   return completedLessonIds.length / totalLessons;
  // }

  factory EnrolledCourse.fromJson(Map<String, dynamic> json) {
    return EnrolledCourse(
      course: Course.fromFirestore(json['course'], json['course']['id']), // may need mapping
      progress: (json['progress'] ?? 0).toDouble(),
      enrollmentDate: (json['enrollmentDate'] as Timestamp).toDate(),
      lastAccessedDate: json['lastAccessedDate'] != null
          ? (json['lastAccessedDate'] as Timestamp).toDate()
          : null,
      completedLessonIds: List<String>.from(json['completedLessonIds'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'course': course.toJson(),
      'progress': progress,
      'enrollmentDate': enrollmentDate,
      'lastAccessedDate': lastAccessedDate,
      'completedLessonIds': completedLessonIds,
    };
  }
}
