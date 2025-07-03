import 'package:cloud_firestore/cloud_firestore.dart';
import '../teacher/models/teacher_course.dart';

class CourseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all courses by teacher (with modules and lessons)
  Future<List<TeacherCourse>> getCoursesByTeacher(String teacherId) async {
    try {
      final querySnapshot = await _firestore
          .collection('courses')
          .where('teacherId', isEqualTo: teacherId)
          .get();

      List<TeacherCourse> courses = [];

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final courseId = doc.id;

        // Fetch modules for this course
        final moduleSnapshot = await _firestore
            .collection('courses')
            .doc(courseId)
            .collection('modules')
            .get();

        List<CourseModule> modules = [];

        for (var moduleDoc in moduleSnapshot.docs) {
          final moduleData = moduleDoc.data();
          final moduleId = moduleDoc.id;

          // Fetch lessons for this module
          final lessonSnapshot = await _firestore
              .collection('courses')
              .doc(courseId)
              .collection('modules')
              .doc(moduleId)
              .collection('lessons')
              .get();

          List<Lesson> lessons = lessonSnapshot.docs.map((l) {
            final lData = l.data();
            return Lesson.fromJson({
              'id': l.id,
              ...lData,
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
    } catch (e) {
      print('🔥 Error loading courses: $e');
      return [];
    }
  }

  // Realtime listener
  Stream<List<TeacherCourse>> listenToCoursesByTeacher(String teacherId) {
    return _firestore
        .collection('courses')
        .where('teacherId', isEqualTo: teacherId)
        .snapshots()
        .asyncMap((snapshot) async {
      List<TeacherCourse> courses = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final courseId = doc.id;

        final moduleSnapshot = await _firestore
            .collection('courses')
            .doc(courseId)
            .collection('modules')
            .get();

        List<CourseModule> modules = [];

        for (var moduleDoc in moduleSnapshot.docs) {
          final moduleData = moduleDoc.data();
          final moduleId = moduleDoc.id;

          final lessonSnapshot = await _firestore
              .collection('courses')
              .doc(courseId)
              .collection('modules')
              .doc(moduleId)
              .collection('lessons')
              .get();

          List<Lesson> lessons = lessonSnapshot.docs.map((l) {
            final lData = l.data();
            return Lesson.fromJson({
              'id': l.id,
              ...lData,
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

  // Add a new course
  Future<void> addCourse(TeacherCourse course) async {
    try {
      final docRef = await _firestore.collection('courses').add(course.toJson());
      await docRef.update({'id': docRef.id});
    } catch (e) {
      print('🔥 Error adding course: $e');
      rethrow;
    }
  }

  // Update course
  Future<void> updateCourse(TeacherCourse course) async {
    try {
      await _firestore.collection('courses').doc(course.id).update(course.toJson());
    } catch (e) {
      print('🔥 Error updating course: $e');
    }
  }

  // Delete course
  Future<void> deleteCourse(String courseId) async {
    try {
      await _firestore.collection('courses').doc(courseId).delete();
    } catch (e) {
      print('🔥 Error deleting course: $e');
    }
  }

  // Toggle publish
  Future<void> toggleCoursePublished(String courseId, bool isPublished) async {
    try {
      await _firestore.collection('courses').doc(courseId).update({
        'isPublished': isPublished,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('🔥 Error toggling publish: $e');
    }
  }
}
