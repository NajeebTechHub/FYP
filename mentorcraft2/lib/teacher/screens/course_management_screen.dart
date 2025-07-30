import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mentorcraft2/teacher/provider/teacher_provider.dart';
import '../models/teacher_course.dart';
import '../../theme/color.dart';
import '../widgets/course_card.dart';
import 'create_course_screen.dart';
import 'edit_course_screen.dart';

class CourseManagementScreen extends StatefulWidget {
  const CourseManagementScreen({Key? key}) : super(key: key);

  @override
  State<CourseManagementScreen> createState() => _CourseManagementScreenState();
}

class _CourseManagementScreenState extends State<CourseManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    Future.microtask(() async {
      final provider = Provider.of<TeacherProvider>(context, listen: false);
      if (provider.teacherId.isEmpty || provider.teacherName.isEmpty) {
        await provider.initializeData();
      }
      if (provider.teacherId.isNotEmpty) {
        provider.subscribeToCourses(provider.teacherId);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? AppColors.darkBackground : Colors.grey[50];
    final cardColor = isDark ? AppColors.cardDark : Colors.white;
    final textColor = isDark ? AppColors.textLight : Colors.black87;
    final inputFillColor = isDark ? AppColors.cardDark : Colors.grey[100];

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        foregroundColor: textColor,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search courses...',
                    hintStyle: TextStyle(color: isDark ? AppColors.textFaded : Colors.grey),
                    prefixIcon: Icon(Icons.search, color: isDark ? AppColors.textFaded : Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: inputFillColor,
                  ),
                  style: TextStyle(color: textColor),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
              ),
              TabBar(
                controller: _tabController,
                labelColor: AppColors.primary,
                unselectedLabelColor: isDark ? AppColors.textFaded : Colors.grey,
                indicatorColor: AppColors.primary,
                tabs: const [
                  Tab(text: 'All Courses'),
                  Tab(text: 'Published'),
                  Tab(text: 'Drafts'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: Consumer<TeacherProvider>(
        builder: (context, provider, _) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildCourseList(provider.courses),
              _buildCourseList(provider.getCoursesByStatus('published')),
              _buildCourseList(provider.getCoursesByStatus('draft')),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateCourseScreen()),
          );
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Create Course', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildCourseList(List<TeacherCourse> courses) {
    final provider = Provider.of<TeacherProvider>(context, listen: false);

    if (!provider.areCoursesLoaded) {
      return const Center(child: CircularProgressIndicator());
    }

    final filteredCourses = courses.where((course) {
      return course.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          course.category.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    if (filteredCourses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.book_outlined, size: 64, color: Colors.grey[500]),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty ? 'No courses found' : 'No courses match your search',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isEmpty ? 'Create your first course to get started' : 'Try adjusting your search terms',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredCourses.length,
      itemBuilder: (_, index) {
        final course = filteredCourses[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: TeacherCourseCard(
            course: course,
            onEdit: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => EditCourseScreen(course: course)),
              );
            },
            onDelete: () => _showDeleteConfirmation(context, course),
            onTogglePublish: () {
              Provider.of<TeacherProvider>(context, listen: false)
                  .toggleCoursePublished(course.id, !course.isPublished);
            },
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, TeacherCourse course) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Delete Course'),
          content: Text('Are you sure you want to delete "${course.title}"? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Provider.of<TeacherProvider>(context, listen: false).deleteCourse(course.id);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Course "${course.title}" deleted successfully'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
