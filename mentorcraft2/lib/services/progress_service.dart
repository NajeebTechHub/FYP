import 'package:cloud_firestore/cloud_firestore.dart';
import '../teacher/models/student_progress.dart';

class ProgressService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<StudentProgress>> getStudentProgressByTeacher(String teacherId) async {
    try {
      final snapshot = await _firestore
          .collection('studentProgress')
          .where('teacherId', isEqualTo: teacherId)
          .get();

      return snapshot.docs
          .map((doc) => StudentProgress.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Error fetching student progress: $e');
      return [];
    }
  }
}
