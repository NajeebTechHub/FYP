// class Course {
//   final String id;
//   final String name;
//   final String title;
//   final String description;
//   final String imageUrl;
//   final double price;
//   final String duration;
//   final String level;
//   final double rating;
//   final int studentsCount;
//   final String instructor;
//   final List<String> tags;
//
//   Course( {
//     required this.id,
//     required this.name,
//     required this.title,
//     required this.description,
//     required this.imageUrl,
//     required this.price,
//     required this.duration,
//     required this.level,
//     required this.rating,
//     required this.studentsCount,
//     required this.instructor,
//     required this.tags,
//   });
// }

import 'package:cloud_firestore/cloud_firestore.dart';

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

    );
  }
}
