import 'package:flutter/material.dart';
import '../models/student_progress.dart';
import '../../theme/color.dart';

class StudentProgressCard extends StatelessWidget {
  final StudentProgress student;
  final VoidCallback onTap;

  const StudentProgressCard({
    Key? key,
    required this.student,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
              // Student Header
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: AssetImage('assets/images/11.png'),
                    backgroundColor: Colors.grey[300],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          student.studentName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          student.studentEmail,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(student.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStatusText(student.status),
                      style: TextStyle(
                        color: _getStatusColor(student.status),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Course Name
              Text(
                student.courseName,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 8),

              // Progress Bar
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progress',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${student.progressPercentage.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: student.progressPercentage / 100,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getProgressColor(student.progressPercentage),
                    ),
                    minHeight: 6,
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Stats Row
              Row(
                children: [
                  _buildStatItem(
                    Icons.play_lesson,
                    '${student.completedLessons}/${student.totalLessons}',
                    'Lessons',
                  ),
                  const SizedBox(width: 16),
                  _buildStatItem(
                    Icons.grade,
                    '${student.overallGrade.toStringAsFixed(1)}%',
                    'Grade',
                  ),
                  const SizedBox(width: 16),
                  _buildStatItem(
                    Icons.access_time,
                    '${student.timeSpent ~/ 60}h',
                    'Time',
                  ),
                  const Spacer(),
                  Text(
                    'Last active: ${_formatTimeAgo(student.lastAccessedAt)}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Action Row
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Enrolled ${_formatDate(student.enrolledAt)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: Colors.grey[400],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'in_progress':
        return Colors.blue;
      case 'enrolled':
        return Colors.orange;
      case 'dropped':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'in_progress':
        return 'In Progress';
      case 'enrolled':
        return 'Enrolled';
      case 'completed':
        return 'Completed';
      case 'dropped':
        return 'Dropped';
      default:
        return status;
    }
  }

  Color _getProgressColor(double progress) {
    if (progress >= 80) {
      return Colors.green;
    } else if (progress >= 50) {
      return Colors.blue;
    } else if (progress >= 25) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}