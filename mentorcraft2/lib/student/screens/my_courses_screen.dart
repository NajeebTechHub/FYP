import 'package:flutter/material.dart';
import '../models/course.dart';
import '../models/enroll_courses.dart';
import 'package:mentorcraft2/theme/color.dart';
import '../widgets/mycourses_widgets/enrolled_courses.dart';

class MyCoursesScreen extends StatefulWidget {
  const MyCoursesScreen({Key? key}) : super(key: key);

  @override
  State<MyCoursesScreen> createState() => _MyCoursesScreenState();
}

class _MyCoursesScreenState extends State<MyCoursesScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late List<EnrolledCourse> _enrolledCourses;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // Simulate loading data
    _loadEnrolledCourses();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Simulate fetching enrolled courses
  Future<void> _loadEnrolledCourses() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Sample enrolled courses data
    _enrolledCourses = [
      EnrolledCourse(
        course: Course(
          id: '3',
          // name: 'Advanced Backend Development with Node.js',
          description: 'Build scalable APIs and backend systems with Node.js',
          imageUrl: 'https://images.unsplash.com/photo-1534972195531-d756b9bfa9f2?q=80&w=2070',
          price:    99,
          level: 'Advanced',
          rating: 4.6, title: '',
          teacherId: '', teacherName: '',
          totalRating: 0.0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          duration: '',
          enrolledStudents: 0,
          // studentsCount: 1890,
          // instructor: 'Dr. Rebecca Williams',
          // tags: ['Backend', 'Node.js', 'API'], title: '',
        ),
        progress: 0.45,
        enrollmentDate: DateTime.now().subtract(const Duration(days: 30)),
        lastAccessedDate: DateTime.now().subtract(const Duration(days: 2)),
      ),
      EnrolledCourse(
        course: Course(
          id: '3',
          // name: 'Advanced Backend Development with Node.js',
          description: 'Build scalable APIs and backend systems with Node.js',
          imageUrl: 'https://images.unsplash.com/photo-1534972195531-d756b9bfa9f2?q=80&w=2070',
          price:    99,
          level: 'Advanced',
          rating: 4.6, title: '',
          teacherId: '', teacherName: '',
          totalRating: 0.0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          duration: '',
          enrolledStudents: 0,
          // studentsCount: 1890,
          // instructor: 'Dr. Rebecca Williams',
          // tags: ['Backend', 'Node.js', 'API'], title: '',
        ),
        progress: 0.75,
        enrollmentDate: DateTime.now().subtract(const Duration(days: 45)),
        lastAccessedDate: DateTime.now().subtract(const Duration(days: 1)),
      ),
      EnrolledCourse(
        course: Course(
          id: '3',
          // name: 'Advanced Backend Development with Node.js',
          description: 'Build scalable APIs and backend systems with Node.js',
          imageUrl: 'https://images.unsplash.com/photo-1534972195531-d756b9bfa9f2?q=80&w=2070',
          price:    99,
          level: 'Advanced',
          rating: 4.6, title: '',
          teacherId: '', teacherName: '',
          totalRating: 0.0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          duration: '',
          enrolledStudents: 0,
          // studentsCount: 1890,
          // instructor: 'Dr. Rebecca Williams',
          // tags: ['Backend', 'Node.js', 'API'], title: '',
        ),
        progress: 0.20,
        enrollmentDate: DateTime.now().subtract(const Duration(days: 15)),
        lastAccessedDate: DateTime.now().subtract(const Duration(days: 4)),
      ),
    ];

    setState(() {
      _isLoading = false;
    });

    _animationController.forward();
  }

  void _continueLearning(EnrolledCourse course) {
    // Handle continue learning action
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Continuing ${course.course.id}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text(
      //     'My Courses',
      //     style: TextStyle(
      //       fontWeight: FontWeight.bold,
      //       color: Colors.white
      //     ),
      //   ),
      //   backgroundColor: AppColors.darkBlue,
      //   elevation: 0,
      //   actions: [
      //     IconButton(
      //       icon: const Icon(Icons.search),
      //       onPressed: () {
      //         // Implement search functionality
      //       },
      //     ),
      //     IconButton(
      //       icon: const Icon(Icons.filter_list),
      //       onPressed: () {
      //         // Implement filter functionality
      //       },
      //     ),
      //   ],
      // ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
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
            Icon(
              Icons.school_outlined,
              size: 100,
              color: Colors.grey[400],
            ),
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
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to courses catalog
              },
              icon: const Icon(Icons.search),
              label: const Text('Browse Courses'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
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
                curve: Interval(
                  index * 0.1,
                  0.6 + index * 0.1,
                  curve: Curves.easeOutQuart,
                ),
              ),
            );

            final opacityAnimation = Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(
              CurvedAnimation(
                parent: _animationController,
                curve: Interval(
                  index * 0.1,
                  0.6 + index * 0.1,
                  curve: Curves.easeOut,
                ),
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