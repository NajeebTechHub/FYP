import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mentorcraft2/teacher/provider/teacher_provider.dart';
import '../models/teacher_quiz.dart';
import '../../theme/color.dart';
import '../widgets/quiz_card.dart';
import 'create_quiz_screen.dart';
import 'package:mentorcraft2/teacher/screens/quiz_submission.dart';

class QuizManagementScreen extends StatefulWidget {
  const QuizManagementScreen({Key? key}) : super(key: key);

  @override
  State<QuizManagementScreen> createState() => _QuizManagementScreenState();
}

class _QuizManagementScreenState extends State<QuizManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TeacherProvider>(context, listen: false).fetchQuizzes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Consumer<TeacherProvider>(
        builder: (context, teacherProvider, child) {
          if (teacherProvider.isQuizLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final allQuizzes = teacherProvider.quizzes;

          return allQuizzes.isEmpty
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.quiz_outlined, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text('No quizzes found', style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                Text('Create your first quiz to get started', style: TextStyle(fontSize: 14, color: Colors.grey[500])),
              ],
            ),
          )
              : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: allQuizzes.length,
            itemBuilder: (context, index) {
              final quiz = allQuizzes[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: QuizCard(
                  quiz: quiz,
                  // onEdit: () {},
                  // onDelete: () => teacherProvider.deleteQuiz(quiz.id),
                  onViewSubmissions: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => QuizSubmissionsScreen(quiz: quiz)));
                  },
                  onToggleActive: () {
                    final updatedQuiz = TeacherQuiz(
                      id: quiz.id,
                      title: quiz.title,
                      description: quiz.description,
                      courseId: quiz.courseId,
                      courseName: quiz.courseName,
                      questions: quiz.questions,
                      timeLimit: quiz.timeLimit,
                      attempts: quiz.attempts,
                      createdAt: quiz.createdAt,
                      updatedAt: DateTime.now(),
                      isActive: !quiz.isActive,
                      totalSubmissions: quiz.totalSubmissions,
                      teacherId: quiz.teacherId,
                      passingPercentage: quiz.passingPercentage,
                    );
                    teacherProvider.updateQuiz(updatedQuiz);
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateQuizScreen()));
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.quiz, color: Colors.white),
        label: const Text('Create Quiz', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}