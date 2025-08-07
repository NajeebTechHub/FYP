import 'package:cloud_firestore/cloud_firestore.dart';
import '../teacher/models/teacher_course.dart';

class CourseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<TeacherCourse>> getCoursesByTeacher(String teacherId) async {
    try {
      final courseQuery = await _firestore
          .collection('courses')
          .where( 'teacherId',isEqualTo: teacherId)
          .get();

      List<TeacherCourse> courses = [];

      for (var courseDoc in courseQuery.docs) {
        final courseId = courseDoc.id;
        final courseData = courseDoc.data();

        final moduleQuery = await _firestore
            .collection('courses')
            .doc(courseId)
            .collection('modules')
            .get();

        List<CourseModule> modules = [];

        for (var moduleDoc in moduleQuery.docs) {
          final moduleId = moduleDoc.id;
          final moduleData = moduleDoc.data();

          final lessonQuery = await _firestore
              .collection('courses')
              .doc(courseId)
              .collection('modules')
              .doc(moduleId)
              .collection('lessons')
              .get();

          List<Lesson> lessons = lessonQuery.docs.map((lessonDoc) {
            return Lesson.fromJson({
              'id': lessonDoc.id,
              ...lessonDoc.data(),
            });
          }).toList();

          modules.add(CourseModule.fromJson({
            'id': moduleId,
            ...moduleData,
            'lessons': lessons.map((l) => l.toJson()).toList(),
          }));
        }

        courses.add(TeacherCourse.fromJson({
          'id': courseId,
          ...courseData,
          'modules': modules.map((m) => m.toJson()).toList(),
        }));
      }

      return courses;
    } catch (e) {
      return [];
    }
  }

  Stream<List<TeacherCourse>> listenToCoursesByTeacher(String teacherId) {
    return _firestore
        .collection('courses')
        .where('teacherId', isEqualTo: teacherId)
        .snapshots()
        .asyncMap((snapshot) async {
      List<TeacherCourse> courses = [];

      for (var doc in snapshot.docs) {
        final courseId = doc.id;
        final data = doc.data();

        final moduleQuery = await _firestore
            .collection('courses')
            .doc(courseId)
            .collection('modules')
            .get();

        List<CourseModule> modules = [];

        for (var moduleDoc in moduleQuery.docs) {
          final moduleId = moduleDoc.id;
          final moduleData = moduleDoc.data();

          final lessonQuery = await _firestore
              .collection('courses')
              .doc(courseId)
              .collection('modules')
              .doc(moduleId)
              .collection('lessons')
              .get();

          List<Lesson> lessons = lessonQuery.docs.map((lessonDoc) {
            return Lesson.fromJson({
              'id': lessonDoc.id,
              ...lessonDoc.data(),
            });
          }).toList();

          modules.add(CourseModule.fromJson({
            'id': moduleId,
            ...moduleData,
            'lessons': lessons.map((l) => l.toJson()).toList(),
          }));
        }

        courses.add(TeacherCourse.fromJson({
          'id': courseId,
          ...data,
          'modules': modules.map((m) => m.toJson()).toList(),
        }));
      }

      return courses;
    });
  }


  Future<void> addCourse(TeacherCourse course) async {
    try {
      final docRef = await _firestore.collection('courses').add(course.toJson());
      await docRef.update({'id': docRef.id});
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateCourse(TeacherCourse course) async {
    try {
      await _firestore.collection('courses').doc(course.id).update(course.toJson());
    } catch (e) {
    }
  }

  Future<void> deleteCourse(String courseId) async {
    try {
      await _firestore.collection('courses').doc(courseId).delete();
    } catch (e) {
    }
  }

  Future<void> toggleCoursePublished(String courseId, bool isPublished) async {
    try {
      await _firestore.collection('courses').doc(courseId).update({
        'isPublished': isPublished,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
    }
  }

  void markLessonAsComplete({
    required String courseId,
    required String userId,
    required String lessonId,
    required int totalLessons,
  }) async {
    final docRef = FirebaseFirestore.instance
        .collection('courses')
        .doc(courseId)
        .collection('enrolledUsers')
        .doc(userId);

    final doc = await docRef.get();

    List<dynamic> completed = [];

    if (doc.exists && doc.data()?['completedLessons'] != null) {
      completed = List.from(doc['completedLessons']);
    }

    if (!completed.contains(lessonId)) {
      completed.add(lessonId);
    }

    double progress = (completed.length / totalLessons) * 100;

    await docRef.set({
      'completedLessons': completed,
      'progress': progress,
      'lastAccessedDate': Timestamp.now(),
    }, SetOptions(merge: true));
  }

}
