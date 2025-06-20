import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mentorcraft2/teacher/provider/teacher_provider.dart';
import '../models/teacher_quiz.dart';
import '../../theme/color.dart';

class QuizSubmissionsScreen extends StatefulWidget {
  final TeacherQuiz quiz;

  const QuizSubmissionsScreen({Key? key, required this.quiz}) : super(key: key);

  @override
  State<QuizSubmissionsScreen> createState() => _QuizSubmissionsScreenState();
}

class _QuizSubmissionsScreenState extends State<QuizSubmissionsScreen> {
  String _filterStatus = 'all';
  String _sortBy = 'date';

  // Sample submissions data
  final List<QuizSubmission> _submissions = [
    QuizSubmission(
      id: 'sub1',
      quizId: 'quiz1',
      studentId: 'student_001',
      studentName: 'John Doe',
      studentEmail: 'john.doe@email.com',
      answers: [],
      score: 85.0,
      percentage: 85.0,
      submittedAt: DateTime.now().subtract(const Duration(hours: 2)),
      timeSpent: 25,
      passed: true,
    ),
    QuizSubmission(
      id: 'sub2',
      quizId: 'quiz1',
      studentId: 'student_002',
      studentName: 'Jane Smith',
      studentEmail: 'jane.smith@email.com',
      answers: [],
      score: 65.0,
      percentage: 65.0,
      submittedAt: DateTime.now().subtract(const Duration(hours: 5)),
      timeSpent: 30,
      passed: false,
    ),
    QuizSubmission(
      id: 'sub3',
      quizId: 'quiz1',
      studentId: 'student_003',
      studentName: 'Mike Johnson',
      studentEmail: 'mike.johnson@email.com',
      answers: [],
      score: 92.0,
      percentage: 92.0,
      submittedAt: DateTime.now().subtract(const Duration(days: 1)),
      timeSpent: 20,
      passed: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('${widget.quiz.title} - Submissions'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportSubmissions,
          ),
          PopupMenuButton<String>(
            onSelected: (value) => setState(() => _sortBy = value),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'date', child: Text('Sort by Date')),
              const PopupMenuItem(value: 'score', child: Text('Sort by Score')),
              const PopupMenuItem(value: 'name', child: Text('Sort by Name')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats and Filters
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Stats Row
                Row(
                  children: [
                    _buildStatCard('Total', _submissions.length.toString(), Colors.blue),
                    _buildStatCard('Passed', _getPassedCount().toString(), Colors.green),
                    _buildStatCard('Failed', _getFailedCount().toString(), Colors.red),
                    _buildStatCard('Average', '${_getAverageScore().toStringAsFixed(1)}%', Colors.orange),
                  ],
                ),
                const SizedBox(height: 16),

                // Filter Chips
                Row(
                  children: [
                    const Text('Filter: ', style: TextStyle(fontWeight: FontWeight.w500)),
                    FilterChip(
                      label: const Text('All'),
                      selected: _filterStatus == 'all',
                      onSelected: (_) => setState(() => _filterStatus = 'all'),
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('Passed'),
                      selected: _filterStatus == 'passed',
                      onSelected: (_) => setState(() => _filterStatus = 'passed'),
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('Failed'),
                      selected: _filterStatus == 'failed',
                      onSelected: (_) => setState(() => _filterStatus = 'failed'),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Submissions List
          Expanded(
            child: _buildSubmissionsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmissionsList() {
    List<QuizSubmission> filteredSubmissions = _getFilteredSubmissions();

    if (filteredSubmissions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No submissions found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredSubmissions.length,
      itemBuilder: (context, index) {
        final submission = filteredSubmissions[index];
        return _buildSubmissionCard(submission);
      },
    );
  }

  Widget _buildSubmissionCard(QuizSubmission submission) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
            // Student Info
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.blue.withOpacity(0.1),
                  child: Text(
                    submission.studentName.substring(0, 1).toUpperCase(),
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        submission.studentName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        submission.studentEmail,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: submission.passed ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    submission.passed ? 'PASSED' : 'FAILED',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Score Section
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Score',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          '${submission.percentage.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: submission.passed ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Time Spent',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          '${submission.timeSpent} min',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Submitted',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          _formatDate(submission.submittedAt),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _viewDetailedResults(submission),
                    icon: const Icon(Icons.visibility, size: 16),
                    label: const Text('View Details'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _provideFeedback(submission),
                    icon: const Icon(Icons.comment, size: 16),
                    label: const Text('Feedback'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<QuizSubmission> _getFilteredSubmissions() {
    List<QuizSubmission> filtered = List.from(_submissions);

    // Apply status filter
    if (_filterStatus == 'passed') {
      filtered = filtered.where((s) => s.passed).toList();
    } else if (_filterStatus == 'failed') {
      filtered = filtered.where((s) => !s.passed).toList();
    }

    // Apply sorting
    switch (_sortBy) {
      case 'score':
        filtered.sort((a, b) => b.percentage.compareTo(a.percentage));
        break;
      case 'name':
        filtered.sort((a, b) => a.studentName.compareTo(b.studentName));
        break;
      default:
        filtered.sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
    }

    return filtered;
  }

  int _getPassedCount() => _submissions.where((s) => s.passed).length;
  int _getFailedCount() => _submissions.where((s) => !s.passed).length;
  double _getAverageScore() {
    if (_submissions.isEmpty) return 0.0;
    return _submissions.map((s) => s.percentage).reduce((a, b) => a + b) / _submissions.length;
  }

  void _viewDetailedResults(QuizSubmission submission) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${submission.studentName} - Detailed Results'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Score: ${submission.percentage.toStringAsFixed(1)}%'),
              Text('Time Spent: ${submission.timeSpent} minutes'),
              Text('Status: ${submission.passed ? 'Passed' : 'Failed'}'),
              const SizedBox(height: 16),
              const Text('Question-by-question breakdown would appear here in a real implementation.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _provideFeedback(QuizSubmission submission) {
    final feedbackController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Feedback for ${submission.studentName}'),
        content: TextField(
          controller: feedbackController,
          decoration: const InputDecoration(
            hintText: 'Enter your feedback here...',
            border: OutlineInputBorder(),
          ),
          maxLines: 4,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // In a real app, save feedback to backend
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Feedback sent successfully')),
              );
            },
            child: const Text('Send Feedback'),
          ),
        ],
      ),
    );
  }

  void _exportSubmissions() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Export functionality would be implemented here')),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else {
      return 'Just now';
    }
  }
}