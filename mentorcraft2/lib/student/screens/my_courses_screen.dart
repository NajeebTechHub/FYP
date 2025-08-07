import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/course.dart';
import '../models/enroll_courses.dart';
import 'package:mentorcraft2/theme/color.dart';
import '../widgets/mycourses_widgets/enrolled_courses_card.dart';
import 'course_details_screen.dart';

class MyCoursesScreen extends StatefulWidget {
  const MyCoursesScreen({Key? key}) : super(key: key);

  @override
  State<MyCoursesScreen> createState() => _MyCoursesScreenState();
}

class _MyCoursesScreenState extends State<MyCoursesScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  List<EnrolledCourse> _enrolledCourses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _loadEnrolledCourses();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadEnrolledCourses() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final List<EnrolledCourse> loadedCourses = [];

    final courseSnapshots = await FirebaseFirestore.instance.collection('courses').get();

    for (var courseDoc in courseSnapshots.docs) {
      final enrolledUserDoc = await FirebaseFirestore.instance
          .collection('courses')
          .doc(courseDoc.id)
          .collection('enrolledUsers')
          .doc(uid)
          .get();

      if (!enrolledUserDoc.exists) continue;

      final enrolledData = enrolledUserDoc.data();
      if (enrolledData == null) continue;

      final courseData = courseDoc.data();

      final course = Course(
        id: courseDoc.id,
        title: courseData['title'] ?? '',
        description: courseData['description'] ?? '',
        imageUrl: courseData['imageUrl'] ?? '',
        price: courseData['price'] ?? 0,
        level: courseData['level'] ?? '',
        rating: (courseData['rating'] ?? 0).toDouble(),
        teacherId: courseData['teacherId'] ?? '',
        teacherName: courseData['teacherName'] ?? '',
        totalRating: (courseData['totalRating'] ?? 0).toDouble(),
        createdAt: _parseDate(courseData['createdAt']),
        updatedAt: _parseDate(courseData['updatedAt']),
        duration: courseData['duration'] ?? '',
        enrolledStudents: courseData['enrolledStudents'] ?? 0,
        modules: [],
      );

      final progress = (enrolledData['progress'] ?? 0.0).toDouble();
      final enrollmentDate = _parseDate(enrolledData['enrollmentDate']);
      final lastAccessedDate = _parseDate(enrolledData['lastAccessedDate']);

      loadedCourses.add(
        EnrolledCourse(
          course: course,
          progress: progress,
          enrollmentDate: enrollmentDate,
          lastAccessedDate: lastAccessedDate,
          completedLessonIds: [],
        ),
      );
    }

    if (!mounted) return; // <- ✅ Prevent error after dispose

    setState(() {
      _enrolledCourses = loadedCourses;
      _isLoading = false;
    });

    _animationController.forward();
  }

  DateTime _parseDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  void _continueLearning(EnrolledCourse enrolledCourse) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CourseDetailsScreen(
          course: enrolledCourse.course,
          isFromMyCourses: true,
        ),
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Continuing ${enrolledCourse.course.title}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _enrolledCourses.isEmpty
          ? _buildEmptyState()
          : _buildCoursesList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school_outlined, size: 100, color: Colors.grey[400]),
            const SizedBox(height: 24),
            Text(
              'No Enrolled Courses Yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'You haven\'t enrolled in any courses yet. Browse our catalog to find courses that match your interests and career goals.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[600], height: 1.5),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Navigate to course catalog
              },
              icon: const Icon(Icons.search),
              label: const Text('Browse Courses'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoursesList() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _enrolledCourses.length,
          itemBuilder: (context, index) {
            final itemAnimation = Tween<Offset>(
              begin: const Offset(0, 0.5),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: _animationController,
                curve: Interval(index * 0.1, 0.6 + index * 0.1, curve: Curves.easeOutQuart),
              ),
            );

            final opacityAnimation = Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(
              CurvedAnimation(
                parent: _animationController,
                curve: Interval(index * 0.1, 0.6 + index * 0.1, curve: Curves.easeOut),
              ),
            );

            return FadeTransition(
              opacity: opacityAnimation,
              child: SlideTransition(
                position: itemAnimation,
                child: EnrolledCourseCard(
                  enrolledCourse: _enrolledCourses[index],
                  onContinue: () => _continueLearning(_enrolledCourses[index]),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
