import 'package:cloud_firestore/cloud_firestore.dart';
import '../teacher/models/teacher_course.dart';

class CourseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all courses by teacher
  Future<List<TeacherCourse>> getCoursesByTeacher(String teacherId) async {
    try {
      final querySnapshot = await _firestore
          .collection('courses')
          .where('teacherId', isEqualTo: teacherId)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // Firestore ID
        return TeacherCourse.fromJson(data);
      }).toList();
    } catch (e) {
      print('Error getting courses: $e');
      return [];
    }
  }

  // Realtime listener for courses
  Stream<List<TeacherCourse>> listenToCoursesByTeacher(String teacherId) {
    return _firestore
        .collection('courses')
        .where('teacherId', isEqualTo: teacherId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return TeacherCourse.fromJson(data);
    }).toList());
  }

  // Add a new course
  Future<void> addCourse(TeacherCourse course) async {
    try {
      final docRef = await _firestore.collection('courses').add(course.toJson());
      await docRef.update({'id': docRef.id});
    } catch (e) {
      print('Error adding course: $e');
      throw e;
    }
  }

  // Update existing course
  Future<void> updateCourse(TeacherCourse course) async {
    try {
      await _firestore.collection('courses').doc(course.id).update(course.toJson());
    } catch (e) {
      print('Error updating course: $e');
    }
  }

  // Delete course
  Future<void> deleteCourse(String courseId) async {
    try {
      await _firestore.collection('courses').doc(courseId).delete();
    } catch (e) {
      print('Error deleting course: $e');
    }
  }

  // Toggle publish/unpublish
  Future<void> toggleCoursePublished(String courseId, bool isPublished) async {
    try {
      await _firestore.collection('courses').doc(courseId).update({
        'isPublished': isPublished,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error toggling publish: $e');
    }
  }
}
