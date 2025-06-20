import 'package:flutter/material.dart';
import '../models/teacher_announcement.dart';

class RecentActivityCard extends StatelessWidget {
  final TeacherAnnouncement announcement;

  const RecentActivityCard({
    Key? key,
    required this.announcement,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    IconData getIconForType(String type) {
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

    Color getColorForType(String type) {
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

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: getColorForType(announcement.type).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              getIconForType(announcement.type),
              color: getColorForType(announcement.type),
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
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  announcement.courseName,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTimeAgo(announcement.createdAt),
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          if (announcement.isUrgent)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Urgent',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
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
}