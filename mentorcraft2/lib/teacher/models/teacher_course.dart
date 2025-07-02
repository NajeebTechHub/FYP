class TeacherCourse {
  final String id;
  final String title;
  final String description;
  final String category;
  final String level;
  final double price;
  final String duration;
  final String imageUrl;
  final String teacherId;
  final String teacherName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isPublished;
  final int enrolledStudents;
  final double rating;
  final int totalRatings;
  final List<CourseModule> modules;

  TeacherCourse({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.level,
    required this.price,
    required this.duration,
    required this.imageUrl,
    required this.teacherId,
    required this.teacherName,
    required this.createdAt,
    required this.updatedAt,
    required this.isPublished,
    required this.enrolledStudents,
    required this.rating,
    required this.totalRatings,
    required this.modules,
  });

  factory TeacherCourse.fromJson(Map<String, dynamic> json) {
    return TeacherCourse(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      level: json['level'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      duration: json['duration'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      teacherId: json['teacherId'] ?? '',
      teacherName: json['teacherName'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      isPublished: json['isPublished'] ?? false,
      enrolledStudents: json['enrolledStudents'] ?? 0,
      rating: (json['rating'] ?? 0.0).toDouble(),
      totalRatings: json['totalRatings'] ?? 0,
      modules: (json['modules'] as List?)?.map((m) => CourseModule.fromJson(m)).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'level': level,
      'price': price,
      'duration': duration,
      'imageUrl': imageUrl,
      'teacherId': teacherId,
      'teacherName': teacherName,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isPublished': isPublished,
      'enrolledStudents': enrolledStudents,
      'rating': rating,
      'totalRatings': totalRatings,
      'modules': modules.map((m) => m.toJson()).toList(),
    };
  }
}

class CourseModule {
  final String id;
  final String title;
  final String description;
  final int order;
  final List<Lesson> lessons;

  CourseModule({
    required this.id,
    required this.title,
    required this.description,
    required this.order,
    required this.lessons,
  });

  factory CourseModule.fromJson(Map<String, dynamic> json) {
    return CourseModule(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      order: json['order'] ?? 0,
      lessons: (json['lessons'] as List?)?.map((l) => Lesson.fromJson(l)).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'order': order,
      'lessons': lessons.map((l) => l.toJson()).toList(),
    };
  }
}

class Lesson {
  final String id;
  final String title;
  final String content;
  final String type; // video, text, quiz
  final String videoUrl;
  final int duration; // in minutes
  final int order;

  Lesson({
    required this.id,
    required this.title,
    required this.content,
    required this.type,
    required this.videoUrl,
    required this.duration,
    required this.order,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      type: json['type'] ?? 'text',
      videoUrl: json['videoUrl'] ?? '',
      duration: json['duration'] ?? 0,
      order: json['order'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'type': type,
      'videoUrl': videoUrl,
      'duration': duration,
      'order': order,
    };
  }
}


// // 1️⃣ Updated: teacher_course.dart
//
//
//
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// // ----------------------------
// // Lesson Model
// // ----------------------------
// class Lesson {
//   final String id;
//   late final String title;
//   late final String description;
//   late final String videoUrl;
//
//   Lesson({
//     required this.id,
//     required this.title,
//     required this.description,
//     required this.videoUrl,
//   });
//
//   factory Lesson.fromJson(Map<String, dynamic> json) {
//     return Lesson(
//       id: json['id'] ?? '',
//       title: json['title'] ?? '',
//       description: json['description'] ?? '',
//       videoUrl: json['videoUrl'] ?? '',
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'title': title,
//       'description': description,
//       'videoUrl': videoUrl,
//     };
//   }
// }
//
// // ----------------------------
// // Module Model
// // ----------------------------
// class Module {
//   final String id;
//   final String title;
//   final List<Lesson> lessons;
//
//   Module({
//     required this.id,
//     required this.title,
//     this.lessons = const [],
//   });
//
//   factory Module.fromJson(Map<String, dynamic> json) {
//     return Module(
//       id: json['id'] ?? '',
//       title: json['title'] ?? '',
//       lessons: (json['lessons'] as List<dynamic>? ?? [])
//           .map((l) => Lesson.fromJson(l as Map<String, dynamic>))
//           .toList(),
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'title': title,
//       'lessons': lessons.map((l) => l.toJson()).toList(),
//     };
//   }
// }
//
// // ----------------------------
// // TeacherCourse Model
// // ----------------------------
// class TeacherCourse {
//   final String id;
//   final String title;
//   final String description;
//   final String category;
//   final String level;
//   final double price;
//   final String duration;
//   final String imageUrl;
//   final String teacherId;
//   final String teacherName;
//   final DateTime createdAt;
//   final DateTime updatedAt;
//   final bool isPublished;
//   final int enrolledStudents;
//   final double rating;
//   final int totalRatings;
//   final List<Module> modules;
//
//   TeacherCourse({
//     required this.id,
//     required this.title,
//     required this.description,
//     required this.category,
//     required this.level,
//     required this.price,
//     required this.duration,
//     required this.imageUrl,
//     required this.teacherId,
//     required this.teacherName,
//     required this.createdAt,
//     required this.updatedAt,
//     required this.isPublished,
//     required this.enrolledStudents,
//     required this.rating,
//     required this.totalRatings,
//     required this.modules,
//   });
//
//   factory TeacherCourse.fromJson(Map<String, dynamic> json) {
//     return TeacherCourse(
//       id: json['id'] ?? '',
//       title: json['title'] ?? '',
//       description: json['description'] ?? '',
//       category: json['category'] ?? '',
//       level: json['level'] ?? '',
//       price: (json['price'] ?? 0).toDouble(),
//       duration: json['duration'] ?? '',
//       imageUrl: json['imageUrl'] ?? '',
//       teacherId: json['teacherId'] ?? '',
//       teacherName: json['teacherName'] ?? '',
//       createdAt: _parseTimestamp(json['createdAt']),
//       updatedAt: _parseTimestamp(json['updatedAt']),
//       isPublished: json['isPublished'] ?? false,
//       enrolledStudents: json['enrolledStudents'] ?? 0,
//       rating: (json['rating'] ?? 0).toDouble(),
//       totalRatings: json['totalRatings'] ?? 0,
//       modules: (json['modules'] as List<dynamic>? ?? [])
//           .map((m) => Module.fromJson(m as Map<String, dynamic>))
//           .toList(),
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'title': title,
//       'description': description,
//       'category': category,
//       'level': level,
//       'price': price,
//       'duration': duration,
//       'imageUrl': imageUrl,
//       'teacherId': teacherId,
//       'teacherName': teacherName,
//       'createdAt': createdAt.toIso8601String(),
//       'updatedAt': updatedAt.toIso8601String(),
//       'isPublished': isPublished,
//       'enrolledStudents': enrolledStudents,
//       'rating': rating,
//       'totalRatings': totalRatings,
//       'modules': modules.map((m) => m.toJson()).toList(),
//     };
//   }
//
//   static DateTime _parseTimestamp(dynamic value) {
//     if (value is Timestamp) {
//       return value.toDate();
//     } else if (value is String) {
//       return DateTime.tryParse(value) ?? DateTime.now();
//     } else {
//       return DateTime.now();
//     }
//   }
// }
//
//
