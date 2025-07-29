// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../../teacher/models/student_progress.dart';
//
// Future<StudentProgress?> fetchStudentProgress({
//   required String courseId,
//   required String studentId,
// }) async {
//   print('▶ fetchStudentProgress called for studentId: $studentId, courseId: $courseId');
//
//   try {
//     // Reference to the enrolled user document
//     final enrolledDocRef = FirebaseFirestore.instance
//         .collection('courses')
//         .doc(courseId)
//         .collection('enrolledUsers')
//         .doc(studentId);
//
//     final enrolledDoc = await enrolledDocRef.get();
//
//     if (!enrolledDoc.exists) {
//       print('⚠ No enrolled document found for $studentId in course $courseId');
//       return null;
//     }
//
//     final enrolledData = enrolledDoc.data()!;
//     final studentEmail = enrolledData['studentEmail'] ?? '';
//     final studentAvatar = enrolledData['studentAvatar'] ?? '';
//
//     print('📧 Student email: $studentEmail');
//     print('🖼️ Student avatar URL: $studentAvatar');
//
//     // Fetch course data
//     final courseDocRef = FirebaseFirestore.instance.collection('courses').doc(courseId);
//     final courseDoc = await courseDocRef.get();
//
//     if (!courseDoc.exists) {
//       print('⚠ No course document found for courseId: $courseId');
//       return null;
//     }
//
//     // Fetch quiz submissions by the student for this course
//     final quizSnapshots = await FirebaseFirestore.instance
//         .collectionGroup('submissions')
//         .where('email', isEqualTo: studentEmail)
//         .where('courseId', isEqualTo: courseId)
//         .get();
//
//     print('✅ Found ${quizSnapshots.docs.length} quiz submissions for $studentEmail');
//
//     // Create StudentProgress model
//     final progress = StudentProgress.fromFirestoreData(
//       enrolledUserData: enrolledData,
//       courseData: courseDoc.data()!,
//       quizSubmissions: quizSnapshots.docs.map((doc) => doc.data()).toList(),
//       studentEmail: studentEmail,
//       studentAvatar: studentAvatar,
//     );
//
//     print('✅ StudentProgress object created successfully');
//     return progress;
//   } catch (e, stack) {
//     print('❌ Error fetching student progress: $e');
//     print(stack);
//     return null;
//   }
// }
