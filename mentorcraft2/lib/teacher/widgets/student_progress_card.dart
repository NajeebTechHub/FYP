import 'package:flutter/material.dart';
import '../../theme/color.dart';
import '../models/student_progress.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.cardDark : AppColors.white;
    final primaryText = isDark ? AppColors.textLight : Colors.black87;
    final secondaryText = isDark ? AppColors.textFaded : Colors.grey[600];
    final fadedText = isDark ? AppColors.textFaded : Colors.grey[500];

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundImage: _getAvatar(student.studentAvatar),
                  backgroundColor: Colors.grey[300],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student.studentName,
                        style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w600,
                          color: primaryText,
                        ),
                      ),
                      Text(
                        student.studentEmail,
                        style: TextStyle(
                          fontSize: 13,
                          color: secondaryText,
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
            Text(
              student.courseName,
              style: TextStyle(
                fontSize: 14,
                color: secondaryText,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
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
                        color: fadedText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${student.progressPercentage.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 12,
                        color: secondaryText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: (student.progressPercentage / 100).clamp(0.0, 1.0),
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getProgressColor(student.progressPercentage),
                  ),
                  minHeight: 6,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildStatItem(Icons.play_lesson,
                    '${student.completedLessons}/${student.totalLessons}', 'Lessons', secondaryText!, primaryText),
                const SizedBox(width: 50),
                _buildStatItem(Icons.access_time, _formatElapsedTime(student.enrolledAt), 'Since', secondaryText, primaryText),
                const Spacer(),
                Tooltip(
                  message: student.lastAccessedAt.toString(),
                  child: Text(
                    'Last: ${_formatTimeAgo(student.lastAccessedAt)}',
                    style: TextStyle(fontSize: 11, color: fadedText),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Tooltip(
                    message: student.enrolledAt.toString(),
                    child: Text(
                      'Enrolled: ${_formatDate(student.enrolledAt)}',
                      style: TextStyle(fontSize: 12, color: fadedText),
                    ),
                  ),
                ),
                Icon(Icons.arrow_forward_ios, size: 14, color: fadedText),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label, Color iconColor, Color valueColor) {
    return Row(
      children: [
        Icon(icon, size: 14, color: iconColor),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: valueColor)),
            Text(label, style: TextStyle(fontSize: 10, color: iconColor)),
          ],
        ),
      ],
    );
  }

  ImageProvider _getAvatar(String url) {
    if (url.isNotEmpty && (url.startsWith('http://') || url.startsWith('https://'))) {
      return NetworkImage(url);
    } else {
      return const AssetImage('assets/images/11.png');
    }
  }

  Color _getStatusColor(String status) {
    if (student.progressPercentage >= 100.0) return Colors.green;
    if (student.progressPercentage == 0.0) return Colors.orange;
    if (student.progressPercentage >= 0.0) return Colors.blue;

    switch (status) {
      case 'completed': return Colors.green;
      case 'in_progress': return Colors.blue;
      case 'enrolled': return Colors.orange;
      case 'dropped': return Colors.red;
      default: return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    if (student.progressPercentage >= 100.0) return 'Completed';
    if (student.progressPercentage == 0.0) return 'Enrolled';
    if (student.progressPercentage >= 0.0) return 'In Progress';

    switch (status) {
      case 'in_progress': return 'In Progress';
      case 'enrolled': return 'Enrolled';
      case 'completed': return 'Completed';
      case 'dropped': return 'Dropped';
      default: return status;
    }
  }

  Color _getProgressColor(double progress) {
    if (progress >= 80) return Colors.green;
    if (progress >= 50) return Colors.blue;
    if (progress >= 25) return Colors.orange;
    return Colors.red;
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  String _formatElapsedTime(DateTime start) {
    final now = DateTime.now();
    final diff = now.difference(start);
    if (diff.inDays >= 1) return '${diff.inDays} days';
    if (diff.inHours >= 1) return '${diff.inHours} hours';
    return '${diff.inMinutes} minutes';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
