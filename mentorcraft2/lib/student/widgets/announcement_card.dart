import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mentorcraft2/teacher/models/teacher_announcement.dart';
import 'package:mentorcraft2/theme/color.dart';

class StudentAnnouncementCard extends StatelessWidget {
  final TeacherAnnouncement announcement;
  final VoidCallback onTap;

  const StudentAnnouncementCard({
    Key? key,
    required this.announcement,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background = isDark ? AppColors.cardDark : AppColors.white;
    final textPrimary = isDark ? AppColors.textLight : Colors.black87;
    final textSecondary = isDark ? AppColors.textFaded : Colors.grey[700];
    final borderColor = isDark ? Colors.grey[800]! : Colors.grey[200]!;
    final shadowColor = isDark ? Colors.transparent : Colors.grey.withOpacity(0.2);
    final metaBackground = isDark ? AppColors.darkBackground : Colors.grey[50];

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getTypeColor(announcement.type).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getTypeIcon(announcement.type),
                    color: _getTypeColor(announcement.type),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        announcement.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'By ${announcement.teacherName}',
                        style: TextStyle(fontSize: 12, color: textSecondary),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        announcement.courseName,
                        style: TextStyle(fontSize: 13, color: textSecondary),
                      ),
                    ],
                  ),
                ),
                if (announcement.isUrgent)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'URGENT',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 12),

            // Body
            Text(
              announcement.content,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                color: textSecondary,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 12),

            // Footer meta
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: metaBackground,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                children: [
                  Icon(Icons.visibility, size: 16, color: textSecondary),
                  const SizedBox(width: 4),
                  Text('${announcement.readCount} reads',
                      style: TextStyle(fontSize: 12, color: textSecondary)),
                  const SizedBox(width: 16),
                  Icon(Icons.schedule, size: 16, color: textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(
                      announcement.createdAt is Timestamp
                          ? (announcement.createdAt as Timestamp).toDate()
                          : announcement.createdAt,
                    ),
                    style: TextStyle(fontSize: 12, color: textSecondary),
                  ),

                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getTypeColor(announcement.type).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      announcement.type.toUpperCase(),
                      style: TextStyle(
                        color: _getTypeColor(announcement.type),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'assignment':
        return Icons.assignment;
      case 'reminder':
        return Icons.notifications;
      case 'announcement':
        return Icons.campaign;
      case 'general':
        return Icons.info;
      default:
        return Icons.article;
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'assignment':
        return Colors.orange;
      case 'reminder':
        return Colors.red;
      case 'announcement':
        return Colors.blue;
      case 'general':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }
}
