import 'package:flutter/material.dart';
import '../models/teacher_course.dart';
import '../../theme/color.dart';

class TeacherCourseCard extends StatelessWidget {
  final TeacherCourse course;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onTogglePublish;

  const TeacherCourseCard({
    Key? key,
    required this.course,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Course Image and Status
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Container(
                  height: 120,
                  width: double.infinity,
                  color: Colors.blue.withOpacity(0.1),
                  child: Icon(
                    Icons.play_circle_outline,
                    size: 48,
                    color: Colors.blue,
                  ),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: course.isPublished ? Colors.green : Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    course.isPublished ? 'Published' : 'Draft',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Course Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  course.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),

                // Course Meta Information
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    _buildMetaItem(Icons.category, course.category),
                    _buildMetaItem(Icons.signal_cellular_alt, course.level),
                    _buildMetaItem(Icons.access_time, course.duration),
                    _buildMetaItem(Icons.attach_money, '\$${course.price.toStringAsFixed(0)}'),
                  ],
                ),
                const SizedBox(height: 12),

                // Stats Row
                Row(
                  children: [
                    _buildStatItem(Icons.people, course.enrolledStudents.toString()),
                    const SizedBox(width: 16),
                    _buildStatItem(Icons.star, '${course.rating.toStringAsFixed(1)} (${course.totalRatings})'),
                    const Spacer(),
                    Text(
                      'Updated ${_formatDate(course.updatedAt)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
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
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onTogglePublish,
                        icon: Icon(
                          course.isPublished ? Icons.unpublished : Icons.publish,
                          size: 16,
                        ),
                        label: Text(course.isPublished ? 'Unpublish' : 'Publish',style: TextStyle(fontSize: 13),),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: course.isPublished ? Colors.orange : Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Container(
                      width: 33,
                      child: IconButton(
                        onPressed: onDelete,
                        icon: const Icon(Icons.delete),
                        color: Colors.red,
                        tooltip: 'Delete Course',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
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