import 'package:flutter/material.dart';
import '../../theme/color.dart';
import '../models/teacher_course.dart';
import '../screens/course_detail_screen.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardColor = isDark ? AppColors.cardDark : Colors.white;
    final titleColor = isDark ? AppColors.textLight : AppColors.textPrimary;
    final textColor = isDark ? AppColors.textFaded : Colors.grey[700];
    final subTextColor = isDark ? AppColors.textFaded : Colors.grey[500];
    final borderColor = isDark ? Colors.white24 : Colors.blue;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => CourseModulesScreen(course: course)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isDark
              ? []
              : [
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
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: course.imageUrl.startsWith('http')
                      ? Image.network(
                    course.imageUrl,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 120,
                      color: Colors.blue.withOpacity(0.1),
                      child: const Icon(Icons.broken_image, size: 48, color: Colors.blue),
                    ),
                  )
                      : Container(
                    height: 120,
                    width: double.infinity,
                    color: Colors.blue.withOpacity(0.1),
                    child: const Icon(Icons.play_circle_outline, size: 48, color: Colors.blue),
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
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: titleColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    course.description,
                    style: TextStyle(fontSize: 14, color: textColor),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    children: [
                      _buildMetaItem(Icons.category, course.category, textColor!),
                      _buildMetaItem(Icons.signal_cellular_alt, course.level, textColor),
                      _buildMetaItem(Icons.access_time, course.duration, textColor),
                      _buildMetaItem(Icons.attach_money, '\$${course.price.toStringAsFixed(0)}', textColor),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildStatItem(Icons.people, course.enrolledStudents.toString(), subTextColor!),
                      const SizedBox(width: 16),
                      _buildStatItem(Icons.star, '${course.rating.toStringAsFixed(1)} (${course.totalRating})', subTextColor),
                      const Spacer(),
                      Text(
                        'Updated ${_formatDate(course.updatedAt)}',
                        style: TextStyle(fontSize: 12, color: subTextColor),
                      ),
                    ],
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
                            side: BorderSide(color: borderColor),
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
                          label: Text(
                            course.isPublished ? 'Unpublish' : 'Publish',
                            style: const TextStyle(
                              fontSize: 13,
                              overflow: TextOverflow.ellipsis,
                            ),
                            softWrap: false,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: course.isPublished ? Colors.orange : Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30), // makes it pill-like
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      SizedBox(
                        width: 33,
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
          ],
        ),
      ),
    );
  }

  Widget _buildMetaItem(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 12, color: color)),
      ],
    );
  }

  Widget _buildStatItem(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500)),
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
}
