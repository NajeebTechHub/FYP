import 'course.dart';

class EnrolledCourse {
  final Course course;
  final double progress;
  final DateTime enrollmentDate;
  final DateTime? lastAccessedDate;

  EnrolledCourse({
    required this.course,
    required this.progress,
    required this.enrollmentDate,
    this.lastAccessedDate,
  });
}