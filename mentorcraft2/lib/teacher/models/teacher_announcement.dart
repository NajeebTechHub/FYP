import 'package:cloud_firestore/cloud_firestore.dart';

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
  final List<String> targetStudents;
  final int readCount;
  final String type;

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

  TeacherAnnouncement copyWith({
    String? id,
    String? title,
    String? content,
    String? courseId,
    String? courseName,
    String? teacherId,
    String? teacherName,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isUrgent,
    bool? isPublished,
    List<String>? targetStudents,
    int? readCount,
    String? type,
  }) {
    return TeacherAnnouncement(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      courseId: courseId ?? this.courseId,
      courseName: courseName ?? this.courseName,
      teacherId: teacherId ?? this.teacherId,
      teacherName: teacherName ?? this.teacherName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isUrgent: isUrgent ?? this.isUrgent,
      isPublished: isPublished ?? this.isPublished,
      targetStudents: targetStudents ?? List<String>.from(this.targetStudents),
      readCount: readCount ?? this.readCount,
      type: type ?? this.type,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'courseId': courseId,
      'courseName': courseName,
      'teacherId': teacherId,
      'teacherName': teacherName,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isUrgent': isUrgent,
      'isPublished': isPublished,
      'targetStudents': targetStudents,
      'readCount': readCount,
      'type': type,
    };
  }

  factory TeacherAnnouncement.fromMap(Map<String, dynamic> map, String id) {
    return TeacherAnnouncement(
      id: id,
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      courseId: map['courseId'] ?? '',
      courseName: map['courseName'] ?? '',
      teacherId: map['teacherId'] ?? '',
      teacherName: map['teacherName'] ?? '',
      createdAt: (map['createdAt'] is Timestamp)
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.tryParse(map['createdAt']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: (map['updatedAt'] is Timestamp)
          ? (map['updatedAt'] as Timestamp).toDate()
          : DateTime.tryParse(map['updatedAt']?.toString() ?? '') ?? DateTime.now(),
      isUrgent: map['isUrgent'] ?? false,
      isPublished: map['isPublished'] ?? true,
      targetStudents: (map['targetStudents'] is List)
          ? List<String>.from(map['targetStudents'])
          : [],
      readCount: map['readCount'] ?? 0,
      type: map['type'] ?? 'general',
    );
  }

  factory TeacherAnnouncement.fromJson(Map<String, dynamic> json) {
    return TeacherAnnouncement(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      courseId: json['courseId'] ?? '',
      courseName: json['courseName'] ?? '',
      teacherId: json['teacherId'] ?? '',
      teacherName: json['teacherName'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
      isUrgent: json['isUrgent'] ?? false,
      isPublished: json['isPublished'] ?? true,
      targetStudents: (json['targetStudents'] is List)
          ? List<String>.from(json['targetStudents'])
          : [],
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

TeacherAnnouncement fromFirestoreDoc(DocumentSnapshot doc) {
  final data = doc.data() as Map<String, dynamic>;
  return TeacherAnnouncement.fromMap(data, doc.id);
}
