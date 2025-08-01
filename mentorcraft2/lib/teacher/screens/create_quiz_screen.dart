import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mentorcraft2/teacher/provider/teacher_provider.dart';
import '../models/teacher_quiz.dart';
import '../../theme/color.dart';

class CreateQuizScreen extends StatefulWidget {
  const CreateQuizScreen({Key? key}) : super(key: key);

  @override
  State<CreateQuizScreen> createState() => _CreateQuizScreenState();
}

class _CreateQuizScreenState extends State<CreateQuizScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _timeLimitController = TextEditingController(text: '30');
  final _attemptsController = TextEditingController(text: '3');
  final _passingPercentageController = TextEditingController(text: '70');

  String? _selectedCourse;
  List<QuizQuestion> _questions = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final teacherProvider = Provider.of<TeacherProvider>(context, listen: false);
      await teacherProvider.initializeData();
      await teacherProvider.fetchCourses();

      if (teacherProvider.courses.isNotEmpty) {
        setState(() {
          _selectedCourse = teacherProvider.courses.first.id;
        });
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _timeLimitController.dispose();
    _attemptsController.dispose();
    _passingPercentageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Quiz')),
      body: Consumer<TeacherProvider>(
        builder: (context, teacherProvider, child) {
          final courses = teacherProvider.courses;

          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (courses.isEmpty)
                    const Text('No courses available', style: TextStyle(color: Colors.red)),
                  if (courses.isNotEmpty)
                    DropdownButtonFormField<String>(
                      value: _selectedCourse,
                      decoration: const InputDecoration(
                        labelText: 'Select Course',
                        border: OutlineInputBorder(),
                      ),
                      items: courses.map((course) {
                        return DropdownMenuItem(
                          value: course.id,
                          child: Text(course.title),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCourse = value;
                        });
                      },
                      validator: (value) => value == null ? 'Please select a course' : null,
                    ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Quiz Title',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value == null || value.isEmpty ? 'Please enter a title' : null,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      _numberField(controller: _timeLimitController, label: 'Time Limit'),
                      const SizedBox(width: 8),
                      _numberField(controller: _attemptsController, label: 'Attempts'),
                      const SizedBox(width: 8),
                      _numberField(controller: _passingPercentageController, label: 'Passing %'),
                    ],
                  ),
                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Questions (${_questions.length})',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ElevatedButton.icon(
                        onPressed: _addQuestion,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Question'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  ..._questions.asMap().entries.map((entry) {
                    final index = entry.key;
                    final question = entry.value;
                    return _buildQuestionCard(question, index);
                  }),

                  const SizedBox(height: 32),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _questions.isEmpty ? null : () => _createQuizWithStatus(false),
                          child: const Text('Save as Draft'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _questions.isEmpty ? null : () => _createQuizWithStatus(true),
                          child: const Text('Create Quiz'),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _numberField({required TextEditingController controller, required String label}) {
    return Expanded(
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        validator: (value) => value == null || int.tryParse(value) == null ? 'Invalid' : null,
      ),
    );
  }

  Widget _buildQuestionCard(QuizQuestion question, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(question.question),
        subtitle: Text("Points: ${question.points}"),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(onPressed: () => _editQuestion(index), icon: const Icon(Icons.edit)),
            IconButton(
              onPressed: () => setState(() => _questions.removeAt(index)),
              icon: const Icon(Icons.delete, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }

  void _addQuestion() => _showQuestionDialog();

  void _editQuestion(int index) => _showQuestionDialog(question: _questions[index], index: index);

  void _showQuestionDialog({QuizQuestion? question, int? index}) {
    final questionController = TextEditingController(text: question?.question ?? '');
    final options = List<String>.from(question?.options ?? ['', '', '', '']);
    final explanationController = TextEditingController(text: question?.explanation ?? '');
    final pointsController = TextEditingController(text: question?.points.toString() ?? '1');
    int correctAnswer = question?.correctAnswer ?? 0;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(question == null ? 'Add Question' : 'Edit Question'),
          content: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.7,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: questionController,
                    decoration: const InputDecoration(labelText: 'Question'),
                  ),
                  const SizedBox(height: 8),
                  ...List.generate(4, (i) {
                    return Row(
                      children: [
                        Radio<int>(
                          value: i,
                          groupValue: correctAnswer,
                          onChanged: (value) => setDialogState(() => correctAnswer = value!),
                        ),
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(labelText: 'Option ${i + 1}'),
                            controller: TextEditingController(text: options[i]),
                            onChanged: (value) => options[i] = value,
                          ),
                        ),
                      ],
                    );
                  }),
                  const SizedBox(height: 8),
                  TextField(
                    controller: explanationController,
                    decoration: const InputDecoration(labelText: 'Explanation'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: pointsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Points'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (questionController.text.isNotEmpty && options.every((o) => o.isNotEmpty)) {
                  final newQuestion = QuizQuestion(
                    id: question?.id ?? DateTime.now().toIso8601String(),
                    question: questionController.text,
                    options: options,
                    correctAnswer: correctAnswer,
                    explanation: explanationController.text,
                    points: int.tryParse(pointsController.text) ?? 1,
                  );
                  setState(() {
                    if (index != null) {
                      _questions[index] = newQuestion;
                    } else {
                      _questions.add(newQuestion);
                    }
                  });
                  Navigator.pop(context);
                }
              },
              child: Text(question == null ? 'Add' : 'Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _createQuizWithStatus(bool isActive) {
    if (!_formKey.currentState!.validate()) return;

    final teacherProvider = Provider.of<TeacherProvider>(context, listen: false);
    final selectedCourse = teacherProvider.courses.firstWhere((c) => c.id == _selectedCourse);

    final quiz = TeacherQuiz(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      courseId: selectedCourse.id,
      courseName: selectedCourse.title,
      questions: _questions,
      timeLimit: int.parse(_timeLimitController.text),
      attempts: int.parse(_attemptsController.text),
      passingPercentage: double.parse(_passingPercentageController.text),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isActive: isActive,
      totalSubmissions: 0,
      teacherId: teacherProvider.teacherId,
    );

    teacherProvider.addQuiz(quiz);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Quiz ${isActive ? 'created' : 'saved as draft'} successfully'),
      backgroundColor: isActive ? Colors.green : Colors.orange,
    ));
  }
}
