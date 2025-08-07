import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mentorcraft2/student/screens/quiz_attempts_screen.dart';
import 'package:mentorcraft2/theme/color.dart';
import 'package:mentorcraft2/student/models/quiz_model.dart';

class QuizScreen extends StatelessWidget {
  const QuizScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textLight : AppColors.textPrimary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quizzes & Assessments',style: TextStyle(fontWeight: FontWeight.bold),),
        backgroundColor: AppColors.darkBlue,
        foregroundColor: AppColors.white,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('quizzes')
            .where('isActive', isEqualTo: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No active quizzes available.',
                style: TextStyle(color: textColor),
              ),
            );
          }

          final quizzes = snapshot.data!.docs.map((doc) {
            return TeacherQuiz.fromMap(doc.data() as Map<String, dynamic>, doc.id);
          }).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Available Quizzes',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: textColor,
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

  Widget _buildQuizCard(BuildContext context, TeacherQuiz quiz, double progress) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.cardDark : AppColors.white;
    final textColor = isDark ? AppColors.textLight : AppColors.textPrimary;
    final subTextColor = isDark ? AppColors.textLight.withOpacity(0.7) : AppColors.textSecondary;

    final level = _getLevelFromPassingScore(quiz.passingScore);
    final levelColor = _getLevelColor(level);

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
      color: cardColor,
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
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: levelColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: levelColor),
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
            Text(
              quiz.description,
              style: TextStyle(color: subTextColor),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.help_outline, size: 16, color: subTextColor),
                const SizedBox(width: 4),
                Text('${quiz.questions.length} Questions', style: TextStyle(color: subTextColor)),
                const SizedBox(width: 16),
                Icon(Icons.timer_outlined, size: 16, color: subTextColor),
                const SizedBox(width: 4),
                Text('${quiz.timeLimit} Minutes', style: TextStyle(color: subTextColor)),
                const Spacer(),
                Text(
                  statusText,
                  style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: isDark ? Colors.grey[700] : Colors.grey[200],
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
                      builder: (_) => QuizTakingScreen(quiz: quiz),
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

  String _getLevelFromPassingScore(double score) {
    if (score <= 40) return 'Beginner';
    if (score <= 70) return 'Intermediate';
    return 'Advanced';
  }

  Color _getLevelColor(String level) {
    switch (level.toLowerCase()) {
      case 'beginner':
        return Colors.green;
      case 'intermediate':
        return Colors.orange;
      case 'advanced':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }
}
