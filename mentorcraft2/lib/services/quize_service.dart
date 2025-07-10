import 'package:cloud_firestore/cloud_firestore.dart';
import '../teacher/models/student_progress.dart';
import '../teacher/models/teacher_quiz.dart';

class QuizService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _quizCollection = 'quizzes';
  final String _attemptsSubcollection = 'attempts';

  // ➕ Add new quiz
  Future<void> addQuiz(TeacherQuiz quiz) async {
    final quizData = quiz.toJson();
    await _firestore.collection(_quizCollection).doc(quiz.id).set(quizData);
  }

  // 🔁 Update quiz
  Future<void> updateQuiz(TeacherQuiz quiz) async {
    final quizData = quiz.toJson();
    await _firestore.collection(_quizCollection).doc(quiz.id).update(quizData);
  }

  // ❌ Delete quiz
  Future<void> deleteQuiz(String quizId) async {
    await _firestore.collection(_quizCollection).doc(quizId).delete();
  }

  // 📦 All quizzes by teacher
  Future<List<TeacherQuiz>> getQuizzesByTeacher(String teacherId) async {
    try {
      final snapshot = await _firestore
          .collection(_quizCollection)
          .where('teacherId', isEqualTo: teacherId)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return TeacherQuiz.fromJson(data);
      }).toList();
    } catch (e) {
      print("❌ Error fetching quizzes by teacher: $e");
      return [];
    }
  }

  // 🔴 Realtime quizzes by teacher
  Stream<List<TeacherQuiz>> listenToQuizzesByTeacher(String teacherId) {
    return _firestore
        .collection(_quizCollection)
        .where('teacherId', isEqualTo: teacherId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return TeacherQuiz.fromJson(data);
    }).toList());
  }

  // 📚 All quizzes for a course
  Future<List<TeacherQuiz>> getQuizzesByCourse(String courseId) async {
    try {
      final snapshot = await _firestore
          .collection(_quizCollection)
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

  // 📊 Student attempts for a specific quiz
  Future<List<QuizAttempt>> getStudentAttempts(String quizId) async {
    try {
      final snapshot = await _firestore
          .collection(_quizCollection)
          .doc(quizId)
          .collection(_attemptsSubcollection)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return QuizAttempt.fromJson(data);
      }).toList();
    } catch (e) {
      print("❌ Error fetching attempts for quiz $quizId: $e");
      return [];
    }
  }

  // 📊 Attempts of 1 student across all quizzes in a course
  Future<List<QuizAttempt>> getStudentAttemptsByCourse({
    required String courseId,
    required String studentId,
  }) async {
    try {
      final quizzes = await getQuizzesByCourse(courseId);
      List<QuizAttempt> allAttempts = [];

      for (var quiz in quizzes) {
        final snapshot = await _firestore
            .collection(_quizCollection)
            .doc(quiz.id)
            .collection(_attemptsSubcollection)
            .where('studentId', isEqualTo: studentId)
            .get();

        final attempts = snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return QuizAttempt.fromJson(data);
        }).toList();

        allAttempts.addAll(attempts);
      }

      return allAttempts;
    } catch (e) {
      print("❌ Error fetching student attempts by course: $e");
      return [];
    }
  }
}
