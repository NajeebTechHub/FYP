import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mentorcraft2/theme/color.dart';
import 'package:mentorcraft2/student/models/quiz_model.dart';

class QuizTakingScreen extends StatefulWidget {
  final TeacherQuiz quiz;

  const QuizTakingScreen({Key? key, required this.quiz}) : super(key: key);

  @override
  State<QuizTakingScreen> createState() => _QuizTakingScreenState();
}

class _QuizTakingScreenState extends State<QuizTakingScreen> {
  late Timer _timer;
  int _secondsLeft = 0;
  int _score = 0;
  bool _submitted = false;
  Map<String, int> _selectedAnswers = {};

  @override
  void initState() {
    super.initState();
    _secondsLeft = widget.quiz.timeLimit * 60;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft == 0) {
        _submitQuiz();
        timer.cancel();
      } else {
        setState(() {
          _secondsLeft--;
        });
      }
    });
  }

  void _submitQuiz() async {
    if (_submitted) return;

    _timer.cancel();

    final user = FirebaseAuth.instance.currentUser;
    final studentName = user?.displayName ?? "Unknown";
    final studentEmail = user?.email ?? "unknown@example.com";

    int totalScore = 0;
    Map<String, dynamic> answerDetails = {};

    for (var q in widget.quiz.questions) {
      String questionId = q['id'];
      int correctIndex = q['correctAnswer'];
      int? selected = _selectedAnswers[questionId];

      bool isCorrect = selected != null && selected == correctIndex;
      if (isCorrect) {
        totalScore += (q['points'] as num?)?.toInt() ?? 0;
      }

      answerDetails[questionId] = {
        'selectedOption': selected,
        'isCorrect': isCorrect,
      };
    }

    final int totalPoints = widget.quiz.questions.fold<int>(
      0,
          (sum, q) => sum + ((q['points'] as num?)?.toInt() ?? 0),
    );

    final double percentage = totalPoints == 0 ? 0 : (totalScore / totalPoints) * 100;
    final bool passed = percentage >= widget.quiz.passingScore;
    final int timeSpent = (widget.quiz.timeLimit * 60) - _secondsLeft;

    setState(() {
      _score = totalScore;
      _submitted = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('quizzes')
          .doc(widget.quiz.id)
          .collection('submissions')
          .add({
        'studentName': studentName,
        'email': studentEmail,
        'score': _score,
        'percentage': percentage,
        'timeSpent': timeSpent,
        'submittedAt': FieldValue.serverTimestamp(),
        'selectedAnswers': answerDetails,
      });

      await FirebaseFirestore.instance
          .collection('quizzes')
          .doc(widget.quiz.id)
          .update({
        'totalSubmissions': FieldValue.increment(1),
      });

      _showResultDialog(passed, percentage);
    } catch (e) {
      debugPrint('Submission error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Submission failed. Try again.')),
      );
    }
  }

  void _showResultDialog(bool passed, double percentage) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(passed ? 'Quiz Passed!' : 'Quiz Failed'),
        content: Text('Your score is $_score (${percentage.toStringAsFixed(2)}%)'),
        actions: [
          TextButton(
            onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildTimer() {
    final minutes = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsLeft % 60).toString().padLeft(2, '0');
    return Text('Time Left: $minutes:$seconds',
        style: const TextStyle(fontSize: 16, color: Colors.red));
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.quiz.title,style: TextStyle(fontWeight: FontWeight.bold),),
        backgroundColor: AppColors.darkBlue,
        foregroundColor: AppColors.white,
        centerTitle: true,
        actions: [
          Padding(padding: const EdgeInsets.all(16.0), child: _buildTimer())
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: widget.quiz.questions.length,
        itemBuilder: (context, index) {
          final question = widget.quiz.questions[index];
          final options = (question['options'] as List<dynamic>).cast<String>();
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Q${index + 1}: ${question['question']}',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...List.generate(options.length, (optIndex) {
                    return RadioListTile<int>(
                      title: Text(options[optIndex]),
                      value: optIndex,
                      groupValue: _selectedAnswers[question['id']],
                      onChanged: _submitted
                          ? null
                          : (value) {
                        setState(() {
                          _selectedAnswers[question['id']] = value!;
                        });
                      },
                    );
                  }),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: !_submitted
          ? Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: _submitQuiz,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('Submit Quiz',
              style: TextStyle(color: Colors.white)),
        ),
      )
          : null,
    );
  }
}
