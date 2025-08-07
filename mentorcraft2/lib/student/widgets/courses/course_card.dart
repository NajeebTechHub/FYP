import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../theme/color.dart';
import 'package:mentorcraft2/student/models/course.dart';

class CourseCard extends StatefulWidget {
  final Course course;

  const CourseCard({super.key, required this.course});

  @override
  State<CourseCard> createState() => _CourseCardState();
}

class _CourseCardState extends State<CourseCard> {
  bool isAlreadyEnrolled = false;

  @override
  void initState() {
    super.initState();
    checkEnrollmentStatus();
  }

  Future<void> checkEnrollmentStatus() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('courses')
        .doc(widget.course.id)
        .collection('enrolledUsers')
        .doc(uid)
        .get();

    if (!mounted) return;
    setState(() {
      isAlreadyEnrolled = doc.exists;
    });
  }

  @override
  Widget build(BuildContext context) {
    final course = widget.course;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: Text(course.title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          color: theme.cardColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: Image.network(
                      course.imageUrl,
                      height: 140,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 140,
                        width: double.infinity,
                        color: isDark ? Colors.grey[800] : Colors.grey[300],
                        alignment: Alignment.center,
                        child: Icon(Icons.image_not_supported, size: 40, color: theme.iconTheme.color),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.darkBlue.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '₹${course.price.toStringAsFixed(2)}',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.title,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text('Instructor: ${course.teacherName}', style: theme.textTheme.bodySmall),
                    const SizedBox(height: 8),
                    Text(
                      course.description,
                      style: theme.textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 16, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text('${course.rating}', style: theme.textTheme.bodyMedium),
                        const SizedBox(width: 8),
                        Icon(Icons.people_outline, size: 16, color: theme.iconTheme.color?.withOpacity(0.6)),
                        const SizedBox(width: 4),
                        Text('${course.enrolledStudents}', style: theme.textTheme.bodySmall),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildInfoChip(context, Icons.timer, course.duration),
                        const SizedBox(width: 8),
                        _buildInfoChip(context, Icons.bar_chart, course.level),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _onEnrollPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isAlreadyEnrolled ? Colors.grey : AppColors.darkBlue,
                        minimumSize: const Size(double.infinity, 36),
                      ),
                      child: Text(
                        isAlreadyEnrolled ? 'Already Enrolled' : 'Enroll Now',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, IconData icon, String label) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Chip(
      avatar: Icon(icon, size: 16, color: theme.iconTheme.color),
      label: Text(label, style: theme.textTheme.bodySmall),
      backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
      padding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  void _onEnrollPressed() {
    if (isAlreadyEnrolled) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You are already enrolled in this course.'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      _handleEnrollment();
    }
  }

  Future<void> _handleEnrollment() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not logged in');

      final uid = user.uid;
      final name = user.displayName ?? 'Unknown';
      final email = user.email ?? 'unknown@example.com';
      final imageUrl = user.photoURL ?? '';

      final enrolledUserRef = FirebaseFirestore.instance
          .collection('courses')
          .doc(widget.course.id)
          .collection('enrolledUsers')
          .doc(uid);

      await enrolledUserRef.set({
        'studentId': uid,
        'studentName': name,
        'studentEmail': email,
        'studentImage': imageUrl,
        'enrolledAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      setState(() {
        isAlreadyEnrolled = true;
      });

      showDialog(
        context: context,
        builder: (_) => const AlertDialog(
          title: Text('Enrollment Successful'),
          content: Text('You have been enrolled in this course.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Enrollment Failed'),
          content: Text('Something went wrong: $e'),
        ),
      );
    }
  }
}
