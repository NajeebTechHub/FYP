import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/teacher_quiz.dart';
import '../../theme/color.dart';
import 'package:provider/provider.dart';
import '../provider/teacher_provider.dart';

class QuizCard extends StatelessWidget {
  final TeacherQuiz quiz;
  final VoidCallback onViewSubmissions;
  final VoidCallback onToggleActive;

  const QuizCard({
    Key? key,
    required this.quiz,
    required this.onViewSubmissions,
    required this.onToggleActive,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final teacherProvider = Provider.of<TeacherProvider>(context, listen: false);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with title & course
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.quiz, color: Colors.blue, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(quiz.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Text(quiz.courseName, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: quiz.isActive ? Colors.green : Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    quiz.isActive ? 'Active' : 'Inactive',
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (quiz.description.isNotEmpty)
              Text(quiz.description, style: TextStyle(fontSize: 14, color: Colors.grey[600]), maxLines: 2, overflow: TextOverflow.ellipsis),

            const SizedBox(height: 12),

            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _buildDetailItem(Icons.help_outline, '${quiz.questions.length} Questions'),
                _buildDetailItem(Icons.timer, '${quiz.timeLimit} minutes'),
                _buildDetailItem(Icons.repeat, '${quiz.attempts} attempts'),
                _buildDetailItem(Icons.grade, '${quiz.passingPercentage.toInt()}% to pass'),
              ],
            ),
            const SizedBox(height: 12),

            // Submissions + created
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.assignment_turned_in, size: 20, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text('${quiz.totalSubmissions} submissions', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  const Spacer(),
                  Text('Created ${_formatDate(quiz.createdAt)}', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Edit / Delete / Toggle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  // Edit
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showEditDialog(context, quiz, teacherProvider),
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Edit'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.blue,
                        side: const BorderSide(color: Colors.blue),
                      ),
                    ),
                  ),
                  // Toggle Active
                  Expanded(
                    child: IconButton(
                      onPressed: onToggleActive,
                      icon: Icon(quiz.isActive ? Icons.pause : Icons.play_arrow),
                      color: quiz.isActive ? Colors.orange : Colors.green,
                      tooltip: quiz.isActive ? 'Deactivate Quiz' : 'Activate Quiz',
                    ),
                  ),
                  // Delete
                  Expanded(
                    child: IconButton(
                      onPressed: () => _confirmDelete(context, quiz.id, teacherProvider),
                      icon: const Icon(Icons.delete),
                      color: Colors.red,
                      tooltip: 'Delete Quiz',
                    ),
                  ),
                ],
              ),
            ),

            // View Submissions
            Row(
              children: [
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onViewSubmissions,
                    icon: const Icon(Icons.visibility, size: 16),
                    label: const Text('Submissions'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    return 'Just now';
  }

  void _confirmDelete(BuildContext context, String quizId, TeacherProvider provider) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Quiz?'),
        content: const Text('Are you sure you want to delete this quiz?'),
        actions: [
          TextButton(child: const Text('Cancel'), onPressed: () => Navigator.pop(context)),
          TextButton(
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
            onPressed: () {
              provider.deleteQuiz(quizId);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, TeacherQuiz quiz, TeacherProvider provider) {
    final titleController = TextEditingController(text: quiz.title);
    final descController = TextEditingController(text: quiz.description);
    final timeLimitController = TextEditingController(text: quiz.timeLimit.toString());
    final attemptsController = TextEditingController(text: quiz.attempts.toString());
    final passingScoreController = TextEditingController(text: quiz.passingPercentage.toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, top: 24, left: 16, right: 16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Edit Quiz', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),

                TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Title')),
                const SizedBox(height: 12),

                TextField(controller: descController, decoration: const InputDecoration(labelText: 'Description')),
                const SizedBox(height: 12),

                TextField(
                  controller: timeLimitController,
                  decoration: const InputDecoration(labelText: 'Time Limit (minutes)'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: attemptsController,
                  decoration: const InputDecoration(labelText: 'Attempts'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: passingScoreController,
                  decoration: const InputDecoration(labelText: 'Passing Score (%)'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 20),

                ElevatedButton.icon(
                  onPressed: () {
                    final updatedQuiz = quiz.copyWith(
                      title: titleController.text.trim(),
                      description: descController.text.trim(),
                      timeLimit: int.tryParse(timeLimitController.text.trim()) ?? quiz.timeLimit,
                      attempts: int.tryParse(attemptsController.text.trim()) ?? quiz.attempts,
                      passingPercentage: double.tryParse(passingScoreController.text.trim()) ?? quiz.passingPercentage,
                      updatedAt: DateTime.now(),
                    );

                    provider.updateQuiz(updatedQuiz); // Now updates full data
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.save),
                  label: const Text('Save Changes'),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

}
