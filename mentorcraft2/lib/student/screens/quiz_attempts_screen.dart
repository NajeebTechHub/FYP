import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mentorcraft2/theme/color.dart';
import 'package:mentorcraft2/student/models/quiz_model.dart';

class QuizAttemptScreen extends StatefulWidget {
  final TeacherQuiz quiz;

  const QuizAttemptScreen({super.key, required this.quiz});

  @override
  State<QuizAttemptScreen> createState() => _QuizAttemptScreenState();
}

class _QuizAttemptScreenState extends State<QuizAttemptScreen> {
  late int remainingSeconds;
  late Timer timer;
  int currentQuestionIndex = 0;
  Map<String, String> selectedAnswers = {};

  @override
  void initState() {
    super.initState();
    remainingSeconds = widget.quiz.timeLimit * 60;
    startTimer();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds == 0) {
        timer.cancel();
        submitQuiz();
      } else {
        setState(() {
          remainingSeconds--;
        });
      }
    });
  }

  void submitQuiz() {
    timer.cancel();
    // Logic for scoring and navigating to result screen
    Navigator.pop(context); // You can show result screen here
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Quiz submitted!")),
    );
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.quiz.questions[currentQuestionIndex];

    List<dynamic> options = question['options'] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz in Progress'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Chip(
              label: Text(
                formatTime(remainingSeconds),
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: AppColors.primary,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Q${currentQuestionIndex + 1}: ${question['question']}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...List.generate(options.length, (index) {
              final optText = options[index];
              final optKey = index.toString();
              final selected = selectedAnswers[question['id']] == optKey;

              return ListTile(
                title: Text(optText),
                leading: Radio<String>(
                  value: optKey,
                  groupValue: selectedAnswers[question['id']],
                  onChanged: (val) {
                    setState(() {
                      selectedAnswers[question['id']] = val!;
                    });
                  },
                ),
              );
            }),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (currentQuestionIndex > 0)
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        currentQuestionIndex--;
                      });
                    },
                    child: const Text('Previous'),
                  ),
                if (currentQuestionIndex < widget.quiz.questions.length - 1)
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        currentQuestionIndex++;
                      });
                    },
                    child: const Text('Next'),
                  )
                else
                  ElevatedButton(
                    onPressed: submitQuiz,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text('Submit'),
                  ),
              ],
            )
          ],
        ),
      ),
    );
  }

  String formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}
