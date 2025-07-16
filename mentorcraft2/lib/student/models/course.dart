import 'package:cloud_firestore/cloud_firestore.dart';

import '../../teacher/models/teacher_course.dart';

class Course {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final double price;
  final String duration;
  final String level;
  final double rating;
  final int enrolledStudents;
  final String teacherId;
  final String teacherName;
  final double totalRating;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<CourseModule> modules;

  Course({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.duration,
    required this.level,
    required this.rating,
    required this.enrolledStudents,
    required this.teacherId,
    required this.teacherName,
    required this.totalRating,
    required this.createdAt,
    required this.updatedAt,
    required this.modules,
  });

  factory Course.fromFirestore(Map<String, dynamic> data, String docId) {
    return Course(
      id: docId,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageurl'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      duration: data['duration'] ?? '',
      level: data['level'] ?? '',
      rating: (data['rating'] ?? 0).toDouble(),
      enrolledStudents: (data['enrolledstudents'] ?? 0),
      teacherId: data['teacherId'] ?? '',
      teacherName: data['teachername'] ?? '',
      totalRating: (data['totalrating'] ?? 0).toDouble(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updateAt'] as Timestamp).toDate(),
      modules: (data['modules'] as List?)?.map((m) => CourseModule.fromJson(m)).toList() ?? [],
    );
  }

  int get totalLessonsCount {
    return modules.fold(0, (sum, module) => sum + module.lessons.length);
  }


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageurl': imageUrl,
      'price': price,
      'duration': duration,
      'level': level,
      'rating': rating,
      'enrolledstudents': enrolledStudents,
      'teacherId': teacherId,
      'teachername': teacherName,
      'totalrating': totalRating,
      'createdAt': Timestamp.fromDate(createdAt),
      'updateAt': Timestamp.fromDate(updatedAt),
      'modules': modules.map((m) => m.toJson()).toList(),
    };
  }
}
