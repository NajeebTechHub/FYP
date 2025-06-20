import 'package:flutter/material.dart';
import '../models/teacher_announcement.dart';
import '../../theme/color.dart';

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
            // Header
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
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              announcement.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          if (announcement.isUrgent)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(8),
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
                      Text(
                        announcement.courseName,
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

            // Content
            Text(
              announcement.content,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 12),

            // Meta Information
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.visibility,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${announcement.readCount} reads',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(announcement.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
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

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Edit'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue,
                      side: BorderSide(color: Colors.blue),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onTogglePublish,
                    icon: Icon(
                      announcement.isPublished ? Icons.unpublished : Icons.publish,
                      size: 16,
                    ),
                    label: Text(announcement.isPublished ? 'Unpublish' : 'Publish'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: announcement.isPublished ? Colors.orange : Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 24,
                  child: IconButton(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete),
                    color: Colors.red,
                    tooltip: 'Delete Announcement',
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