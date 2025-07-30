import 'package:flutter/material.dart';
import '../../theme/color.dart';
import '../models/teacher_announcement.dart';

class AnnouncementCard extends StatelessWidget {
  final TeacherAnnouncement announcement;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onTogglePublish;

  const AnnouncementCard({
    Key? key,
    required this.announcement,
    required this.onEdit,
    required this.onDelete,
    required this.onTogglePublish,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background = isDark ? AppColors.cardDark : AppColors.white;
    final textPrimary = isDark ? AppColors.textLight : Colors.black87;
    final textSecondary = isDark ? AppColors.textFaded : Colors.grey[700];
    final borderColor = isDark ? Colors.grey[800] : Colors.grey[200];
    final shadowColor = isDark ? Colors.transparent : Colors.grey.withOpacity(0.2);
    final metaBackground = isDark ? AppColors.darkBackground : Colors.grey[50];

    return Container(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            spreadRadius: 3,
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
            Row(
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
                      const SizedBox(height: 4),
                      Text(
                        announcement.courseName,
                        style: TextStyle(fontSize: 14, color: textSecondary),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: announcement.isPublished ? Colors.green : Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    announcement.isPublished ? 'Published' : 'Draft',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              announcement.content,
              style: TextStyle(
                fontSize: 14,
                color: textSecondary,
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: metaBackground,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: borderColor!),
              ),
              child: Row(
                children: [
                  Icon(Icons.visibility, size: 16, color: textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    '${announcement.readCount} reads',
                    style: TextStyle(fontSize: 12, color: textSecondary),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.schedule, size: 16, color: textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(announcement.createdAt),
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
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Edit'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue,
                      side: const BorderSide(color: Colors.blue),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: ElevatedButton.icon(
                      onPressed: onTogglePublish,
                      icon: Icon(
                        announcement.isPublished ? Icons.unpublished : Icons.publish,
                        size: 18,
                      ),
                      label: Text(
                        announcement.isPublished ? 'Unpublish' : 'Publish',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: announcement.isPublished ? Colors.orange : Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30), // More circular look
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        elevation: 1,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 5),
                SizedBox(
                  width: 25,
                  child: IconButton(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete),
                    color: Colors.red,
                  ),
                ),
              ],
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
      default:
        return Icons.info;
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
