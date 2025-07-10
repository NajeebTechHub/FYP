import 'package:cloud_firestore/cloud_firestore.dart';
import '../teacher/models/teacher_course.dart';

class CourseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get all courses by a specific teacher, including modules and lessons.
  Future<List<TeacherCourse>> getCoursesByTeacher(String teacherId) async {
    try {
      final courseQuery = await _firestore
          .collection('courses')
          .where('teacherId', isEqualTo: teacherId)
          .get();

      List<TeacherCourse> courses = [];

      for (var courseDoc in courseQuery.docs) {
        final courseId = courseDoc.id;
        final courseData = courseDoc.data();

        // Fetch modules
        final moduleQuery = await _firestore
            .collection('courses')
            .doc(courseId)
            .collection('modules')
            .get();

        List<CourseModule> modules = [];

        for (var moduleDoc in moduleQuery.docs) {
          final moduleId = moduleDoc.id;
          final moduleData = moduleDoc.data();

          // Fetch lessons
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
      print('🔥 Error loading courses: $e');
      return [];
    }
  }

  /// Listen to real-time updates for courses by teacher.
  Stream<List<TeacherCourse>> listenToCoursesByTeacher(String teacherId) {
    return _firestore
        .collection('courses')
        .where('teacherId', isEqualTo: teacherId)
        .snapshots()
        .asyncMap((snapshot) async {
      List<TeacherCourse> courses = [];

      for (var courseDoc in snapshot.docs) {
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
    });
  }

  /// Add a new course to Firestore
  Future<void> addCourse(TeacherCourse course) async {
    try {
      final docRef = await _firestore.collection('courses').add(course.toJson());
      await docRef.update({'id': docRef.id});
    } catch (e) {
      print('🔥 Error adding course: $e');
      rethrow;
    }
  }

  /// Update an existing course
  Future<void> updateCourse(TeacherCourse course) async {
    try {
      await _firestore.collection('courses').doc(course.id).update(course.toJson());
    } catch (e) {
      print('🔥 Error updating course: $e');
    }
  }

  /// Delete a course by ID
  Future<void> deleteCourse(String courseId) async {
    try {
      await _firestore.collection('courses').doc(courseId).delete();
    } catch (e) {
      print('🔥 Error deleting course: $e');
    }
  }

  /// Toggle the published status of a course
  Future<void> toggleCoursePublished(String courseId, bool isPublished) async {
    try {
      await _firestore.collection('courses').doc(courseId).update({
        'isPublished': isPublished,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('🔥 Error toggling course publish: $e');
    }
  }
}
