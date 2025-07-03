import 'package:cloud_firestore/cloud_firestore.dart';

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
  List<CourseModule> modules;

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

    DateTime _parseDate(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
      return DateTime.now(); // fallback
    }


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
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
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

  TeacherCourse copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? level,
    double? price,
    String? duration,
    String? imageUrl,
    String? teacherId,
    String? teacherName,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPublished,
    int? enrolledStudents,
    double? rating,
    int? totalRatings,
    List<CourseModule>? modules,
  }) {
    return TeacherCourse(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      level: level ?? this.level,
      price: price ?? this.price,
      duration: duration ?? this.duration,
      imageUrl: imageUrl ?? this.imageUrl,
      teacherId: teacherId ?? this.teacherId,
      teacherName: teacherName ?? this.teacherName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPublished: isPublished ?? this.isPublished,
      enrolledStudents: enrolledStudents ?? this.enrolledStudents,
      rating: rating ?? this.rating,
      totalRatings: totalRatings ?? this.totalRatings,
      modules: modules ?? this.modules,
    );
  }
}

class CourseModule {
  final String id;
  final String title;
  final String description;
  final int order;
  List<Lesson> lessons;

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

  CourseModule copyWith({
    String? id,
    String? title,
    String? description,
    int? order,
    List<Lesson>? lessons,
  }) {
    return CourseModule(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      order: order ?? this.order,
      lessons: lessons ?? this.lessons,
    );
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

  Lesson copyWith({
    String? id,
    String? title,
    String? content,
    String? type,
    String? videoUrl,
    int? duration,
    int? order,
  }) {
    return Lesson(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      type: type ?? this.type,
      videoUrl: videoUrl ?? this.videoUrl,
      duration: duration ?? this.duration,
      order: order ?? this.order,
    );
  }
}
