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
  String _selectedCourse = 'all';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Consumer<TeacherProvider>(
        builder: (context, teacherProvider, child) {
          return Column(
            children: [
              // Filters and Search
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Search Bar
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Search quizzes...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                    const SizedBox(height: 12),

                    // Course Filter
                    // Row(
                    //   children: [
                    //     const Text(
                    //       'Filter by course:',
                    //       style: TextStyle(
                    //         fontWeight: FontWeight.w500,
                    //         color: Colors.black87,
                    //       ),
                    //     ),
                    //     const SizedBox(width: 12),
                    //     Expanded(
                    //       child: DropdownButtonFormField<String>(
                    //         value: _selectedCourse,
                    //         decoration: InputDecoration(
                    //           border: OutlineInputBorder(
                    //             borderRadius: BorderRadius.circular(8),
                    //             borderSide: BorderSide.none,
                    //           ),
                    //           filled: true,
                    //           fillColor: Colors.grey[100],
                    //           contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    //         ),
                    //         items: [
                    //           const DropdownMenuItem(
                    //             value: 'all',
                    //             child: Text('All Courses'),
                    //           ),
                    //           ...teacherProvider.courses.map((course) => DropdownMenuItem(
                    //             value: course.id,
                    //             child: Text(course.title),
                    //           )).toList(),
                    //         ],
                    //         onChanged: (value) {
                    //           setState(() {
                    //             _selectedCourse = value!;
                    //           });
                    //         },
                    //       ),
                    //     ),
                    //   ],
                    // ),
                  ],
                ),
              ),

              // Quiz List
              Expanded(
                child: _buildQuizList(teacherProvider),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateQuizScreen(),
            ),
          );
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.quiz,color: Colors.white,),
        label: const Text('Create Quiz',style: TextStyle(color: Colors.white),),
      ),
    );
  }

  Widget _buildQuizList(TeacherProvider teacherProvider) {
    List<TeacherQuiz> filteredQuizzes = teacherProvider.quizzes;

    // Filter by course
    if (_selectedCourse != 'all') {
      filteredQuizzes = filteredQuizzes.where((quiz) => quiz.courseId == _selectedCourse).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filteredQuizzes = filteredQuizzes.where((quiz) =>
      quiz.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          quiz.courseName.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }

    if (filteredQuizzes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.quiz_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty ? 'No quizzes found' : 'No quizzes match your search',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isEmpty
                  ? 'Create your first quiz to get started'
                  : 'Try adjusting your search terms',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredQuizzes.length,
      itemBuilder: (context, index) {
        final quiz = filteredQuizzes[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: QuizCard(
            quiz: quiz,
            onEdit: () {
              // Navigate to edit quiz
            },
            onDelete: () {
              _showDeleteConfirmation(context, quiz, teacherProvider);
            },
            onViewSubmissions: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => QuizSubmissionsScreen(quiz: quiz),
                ),
              );
            },
            onToggleActive: () {
              // Toggle quiz active status
            },
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, TeacherQuiz quiz, TeacherProvider provider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Quiz'),
          content: Text(
            'Are you sure you want to delete "${quiz.title}"? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                provider.deleteQuiz(quiz.id);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Quiz "${quiz.title}" deleted successfully'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}