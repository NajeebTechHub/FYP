import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mentorcraft2/student/screens/quiz_attempts_screen.dart';
import 'package:mentorcraft2/theme/color.dart';
import 'package:mentorcraft2/student/models/quiz_model.dart';

class QuizScreen extends StatelessWidget {
  const QuizScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quizzes & Assessments')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('quizzes')
            .where('isActive', isEqualTo: true) // ✅ Only active quizzes
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No active quizzes available.'));
          }

          final quizzes = snapshot.data!.docs.map((doc) {
            return TeacherQuiz.fromMap(doc.data() as Map<String, dynamic>, doc.id);
          }).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Available Quizzes',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkBlue,
                  ),
                ),
                const SizedBox(height: 16),
                ...quizzes.map((quiz) => _buildQuizCard(context, quiz, 0.0)).toList(),
              ],
            ),
          );
        },
      ),
    );
  }

  String _getLevelFromPassingScore(double score) {
    if (score <= 40) return 'Beginner';
    if (score <= 70) return 'Intermediate';
    return 'Advanced';
  }

  Widget _buildQuizCard(BuildContext context, TeacherQuiz quiz, double progress) {
    final String level = _getLevelFromPassingScore(quiz.passingScore);

    Color levelColor;
    switch (level.toLowerCase()) {
      case 'beginner':
        levelColor = Colors.green;
        break;
      case 'intermediate':
        levelColor = Colors.orange;
        break;
      case 'advanced':
        levelColor = Colors.red;
        break;
      default:
        levelColor = Colors.blue;
    }

    String statusText;
    Color statusColor;
    if (progress == 0.0) {
      statusText = 'Not Started';
      statusColor = Colors.grey;
    } else if (progress == 1.0) {
      statusText = 'Completed';
      statusColor = Colors.green;
    } else {
      statusText = 'In Progress';
      statusColor = Colors.orange;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.quiz, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    quiz.title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: levelColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: levelColor, width: 1),
                  ),
                  child: Text(
                    level,
                    style: TextStyle(
                      color: levelColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(quiz.description, style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.help_outline, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text('${quiz.questions.length} Questions', style: const TextStyle(color: AppColors.textSecondary)),
                const SizedBox(width: 16),
                const Icon(Icons.timer_outlined, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text('${quiz.timeLimit} Minutes', style: const TextStyle(color: AppColors.textSecondary)), // ✅ Using Firestore value
                const Spacer(),
                Text(statusText, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                progress == 1.0 ? Colors.green : AppColors.primary,
              ),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => QuizTakingScreen(quiz: quiz,),
                      ),
                    );

                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkBlue,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(
                  progress == 0.0
                      ? 'Start Quiz'
                      : progress == 1.0
                      ? 'Review Quiz'
                      : 'Continue Quiz',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
