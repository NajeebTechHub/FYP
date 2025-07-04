import 'package:cloud_firestore/cloud_firestore.dart';
import '../teacher/models/teacher_quiz.dart';

class QuizService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionPath = 'quizzes';

  // Add new quiz
  Future<void> addQuiz(TeacherQuiz quiz) async {
    final quizData = quiz.toJson();
    await _firestore.collection(_collectionPath).doc(quiz.id).set(quizData);
  }

  // Update existing quiz
  Future<void> updateQuiz(TeacherQuiz quiz) async {
    final quizData = quiz.toJson();
    await _firestore.collection(_collectionPath).doc(quiz.id).update(quizData);
  }

  // Delete quiz by ID
  Future<void> deleteQuiz(String quizId) async {
    await _firestore.collection(_collectionPath).doc(quizId).delete();
  }

  // Get all quizzes by teacher ID (non-realtime)
  Future<List<TeacherQuiz>> getQuizzesByTeacher(String teacherId) async {
    try {
      final snapshot = await _firestore
          .collection(_collectionPath)
          .where('teacherId', isEqualTo: teacherId)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // Ensure ID is present
        return TeacherQuiz.fromJson(data);
      }).toList();
    } catch (e) {
      print("❌ Error fetching quizzes by teacher: $e");
      return [];
    }
  }

  // ✅ Real-time quizzes by teacher ID
  Stream<List<TeacherQuiz>> listenToQuizzesByTeacher(String teacherId) {
    return _firestore
        .collection(_collectionPath)
        .where('teacherId', isEqualTo: teacherId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return TeacherQuiz.fromJson(data);
    }).toList());
  }


  // Get all quizzes by course ID
  Future<List<TeacherQuiz>> getQuizzesByCourse(String courseId) async {
    try {
      final snapshot = await _firestore
          .collection(_collectionPath)
          .where('courseId', isEqualTo: courseId)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return TeacherQuiz.fromJson(data);
      }).toList();
    } catch (e) {
      print("❌ Error fetching quizzes by course: $e");
      return [];
    }
  }
}
