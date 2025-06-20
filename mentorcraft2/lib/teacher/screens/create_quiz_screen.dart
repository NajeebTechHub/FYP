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
  final _passingScoreController = TextEditingController(text: '70');

  String _selectedCourse = '';
  List<QuizQuestion> _questions = [];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _timeLimitController.dispose();
    _attemptsController.dispose();
    _passingScoreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Quiz'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Consumer<TeacherProvider>(
        builder: (context, teacherProvider, child) {
          if (_selectedCourse.isEmpty && teacherProvider.courses.isNotEmpty) {
            _selectedCourse = teacherProvider.courses.first.id;
          }

          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Course Selection
                  DropdownButtonFormField<String>(
                    value: _selectedCourse.isEmpty ? null : _selectedCourse,
                    decoration: const InputDecoration(
                      labelText: 'Select Course',
                      border: OutlineInputBorder(),
                    ),
                    items: teacherProvider.courses.map((course) {
                      return DropdownMenuItem(
                        value: course.id,
                        child: Text(course.title),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => _selectedCourse = value!),
                    validator: (value) => value?.isEmpty == true ? 'Please select a course' : null,
                  ),
                  const SizedBox(height: 16),

                  // Quiz Title
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Quiz Title',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value?.isEmpty == true ? 'Please enter a title' : null,
                  ),
                  const SizedBox(height: 16),

                  // Description
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Quiz Settings Row
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _timeLimitController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Time Limit (min)',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value?.isEmpty == true) return 'Required';
                            if (int.tryParse(value!) == null) return 'Invalid number';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: _attemptsController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Max Attempts',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value?.isEmpty == true) return 'Required';
                            if (int.tryParse(value!) == null) return 'Invalid number';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: _passingScoreController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Passing Score (%)',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value?.isEmpty == true) return 'Required';
                            final score = double.tryParse(value!);
                            if (score == null || score < 0 || score > 100) return 'Invalid score';
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Questions Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Questions (${_questions.length})',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      ElevatedButton.icon(
                        onPressed: _addQuestion,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Question'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Questions List
                  ..._questions.asMap().entries.map((entry) {
                    final index = entry.key;
                    final question = entry.value;
                    return _buildQuestionCard(question, index);
                  }).toList(),

                  const SizedBox(height: 32),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _questions.isEmpty ? null : _saveDraft,
                          child: const Text('Save as Draft'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _questions.isEmpty ? null : _createQuiz,
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                          child: const Text('Create Quiz'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuestionCard(QuizQuestion question, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Question ${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(
                  onPressed: () => _editQuestion(index),
                  icon: const Icon(Icons.edit),
                ),
                IconButton(
                  onPressed: () => _removeQuestion(index),
                  icon: const Icon(Icons.delete, color: Colors.red),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(question.question),
            const SizedBox(height: 8),
            ...question.options.asMap().entries.map((entry) {
              final optionIndex = entry.key;
              final option = entry.value;
              final isCorrect = optionIndex == question.correctAnswer;
              return Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 4),
                child: Row(
                  children: [
                    Icon(
                      isCorrect ? Icons.check_circle : Icons.radio_button_unchecked,
                      color: isCorrect ? Colors.green : Colors.grey,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(option)),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  void _addQuestion() {
    _showQuestionDialog();
  }

  void _editQuestion(int index) {
    _showQuestionDialog(question: _questions[index], index: index);
  }

  void _removeQuestion(int index) {
    setState(() => _questions.removeAt(index));
  }

  void _showQuestionDialog({QuizQuestion? question, int? index}) {
    final questionController = TextEditingController(text: question?.question ?? '');
    final explanationController = TextEditingController(text: question?.explanation ?? '');
    final pointsController = TextEditingController(text: (question?.points ?? 1).toString());
    final options = List<String>.from(question?.options ?? ['', '', '', '']);
    int correctAnswer = question?.correctAnswer ?? 0;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(question == null ? 'Add Question' : 'Edit Question'),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: questionController,
                    decoration: const InputDecoration(labelText: 'Question'),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  ...List.generate(4, (i) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Radio<int>(
                          value: i,
                          groupValue: correctAnswer,
                          onChanged: (value) => setDialogState(() => correctAnswer = value!),
                        ),
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(labelText: 'Option ${i + 1}'),
                            onChanged: (value) => options[i] = value,
                            controller: TextEditingController(text: options[i]),
                          ),
                        ),
                      ],
                    ),
                  )),
                  const SizedBox(height: 16),
                  TextField(
                    controller: explanationController,
                    decoration: const InputDecoration(labelText: 'Explanation (optional)'),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: pointsController,
                    decoration: const InputDecoration(labelText: 'Points'),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (questionController.text.isNotEmpty && options.every((o) => o.isNotEmpty)) {
                  final newQuestion = QuizQuestion(
                    id: question?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
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

  void _saveDraft() {
    if (_formKey.currentState?.validate() ?? false) {
      _createQuizWithStatus(false);
    }
  }

  void _createQuiz() {
    if (_formKey.currentState?.validate() ?? false) {
      _createQuizWithStatus(true);
    }
  }

  void _createQuizWithStatus(bool isActive) {
    final teacherProvider = Provider.of<TeacherProvider>(context, listen: false);
    final selectedCourse = teacherProvider.courses.firstWhere((c) => c.id == _selectedCourse);

    final quiz = TeacherQuiz(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text,
      description: _descriptionController.text,
      courseId: _selectedCourse,
      courseName: selectedCourse.title,
      questions: _questions,
      timeLimit: int.parse(_timeLimitController.text),
      attempts: int.parse(_attemptsController.text),
      passingScore: double.parse(_passingScoreController.text),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isActive: isActive,
      totalSubmissions: 0,
    );

    teacherProvider.addQuiz(quiz);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Quiz ${isActive ? 'created' : 'saved as draft'} successfully'),
        backgroundColor: isActive ? Colors.green : Colors.orange,
      ),
    );
  }
}