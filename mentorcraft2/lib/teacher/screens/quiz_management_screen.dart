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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final teacherProvider = Provider.of<TeacherProvider>(context, listen: false);
      await teacherProvider.initializeData();
      await teacherProvider.fetchQuizzes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Consumer<TeacherProvider>(
        builder: (context, teacherProvider, child) {
          final isLoading = teacherProvider.isQuizLoading;
          final allQuizzes = teacherProvider.quizzes;

          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (allQuizzes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.quiz_outlined, size: 64, color: theme.hintColor),
                  const SizedBox(height: 16),
                  Text('No quizzes found',
                      style: textTheme.headlineMedium?.copyWith(color: theme.hintColor)),
                  const SizedBox(height: 8),
                  Text('Create your first quiz to get started',
                      style: textTheme.bodyLarge?.copyWith(color: theme.hintColor)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: allQuizzes.length,
            itemBuilder: (context, index) {
              final quiz = allQuizzes[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: QuizCard(
                  quiz: quiz,
                  onViewSubmissions: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => QuizSubmissionsScreen(quiz: quiz),
                      ),
                    );
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
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateQuizScreen()),
          );
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.quiz, color: Colors.white),
        label: const Text('Create Quiz', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
