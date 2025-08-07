import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mentorcraft2/theme/color.dart';
import 'package:mentorcraft2/teacher/models/teacher_announcement.dart';
import 'package:mentorcraft2/teacher/provider/teacher_provider.dart';
import 'package:mentorcraft2/teacher/models/teacher_course.dart';
import 'package:mentorcraft2/student/widgets/announcement_card.dart';

class StudentAnnouncementsScreen extends StatefulWidget {
  const StudentAnnouncementsScreen({Key? key}) : super(key: key);

  @override
  State<StudentAnnouncementsScreen> createState() => _StudentAnnouncementsScreenState();
}

class _StudentAnnouncementsScreenState extends State<StudentAnnouncementsScreen> {
  String _selectedCourse = 'all';
  String _selectedType = 'all';

  @override
  void initState() {
    super.initState();
    print('StudentAnnouncementsScreen INIT');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('PostFrameCallback START');
      final provider = Provider.of<TeacherProvider>(context, listen: false);
      provider.fetchCourses();
      provider.fetchAllPublishedAnnouncements();
    });
  }


  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? AppColors.darkBackground : AppColors.white;
    final chipColor = isDark ? AppColors.cardDark : Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Announcements'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Consumer<TeacherProvider>(
        builder: (context, provider, child) {
          final isLoading = !provider.areAnnouncementsLoaded || !provider.areCoursesLoaded;

          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: () => _showFilterDialog(context, provider),
                ),
              ),
              if (_selectedCourse != 'all' || _selectedType != 'all')
                Container(
                  padding: const EdgeInsets.all(16),
                  color: chipColor,
                  child: Row(
                    children: [
                      const Text('Filters: '),
                      if (_selectedCourse != 'all') ...[
                        Chip(
                          label: Text(_getCourseName(provider, _selectedCourse)),
                          deleteIcon: const Icon(Icons.close, size: 16),
                          onDeleted: () => setState(() => _selectedCourse = 'all'),
                        ),
                        const SizedBox(width: 8),
                      ],
                      if (_selectedType != 'all') ...[
                        Chip(
                          label: Text(_selectedType.toUpperCase()),
                          deleteIcon: const Icon(Icons.close, size: 16),
                          onDeleted: () => setState(() => _selectedType = 'all'),
                        ),
                      ],
                    ],
                  ),
                ),
              Expanded(child: _buildAnnouncementsList(provider)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAnnouncementsList(TeacherProvider provider) {
    List<TeacherAnnouncement> filtered = provider.announcements;

    if (_selectedCourse != 'all') {
      filtered = filtered.where((a) => a.courseId == _selectedCourse).toList();
    }
    if (_selectedType != 'all') {
      filtered = filtered.where((a) => a.type == _selectedType).toList();
    }

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.campaign_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No announcements found',
              style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              'Published announcements will appear here',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final announcement = filtered[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: StudentAnnouncementCard(
            announcement: announcement,
            onTap: () async {
              final docRef = FirebaseFirestore.instance
                  .collection('announcements')
                  .doc(announcement.id);

              await docRef.update({
                'readCount': FieldValue.increment(1),
              });
              },
          ),

        );
      },
    );
  }

  void _showFilterDialog(BuildContext context, TeacherProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Announcements'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedCourse,
              decoration: const InputDecoration(labelText: 'Course'),
              items: [
                const DropdownMenuItem(value: 'all', child: Text('All Courses')),
                ...provider.courses.map((c) => DropdownMenuItem(
                  value: c.id,
                  child: SizedBox(width: 150, child: Text(c.title, overflow: TextOverflow.ellipsis)),
                )),
              ],
              onChanged: (value) => setState(() => _selectedCourse = value!),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: const InputDecoration(labelText: 'Type'),
              items: const [
                DropdownMenuItem(value: 'all', child: Text('All Types')),
                DropdownMenuItem(value: 'general', child: Text('General')),
                DropdownMenuItem(value: 'assignment', child: Text('Assignment')),
                DropdownMenuItem(value: 'reminder', child: Text('Reminder')),
                DropdownMenuItem(value: 'announcement', child: Text('Announcement')),
              ],
              onChanged: (value) => setState(() => _selectedType = value!),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Apply')),
        ],
      ),
    );
  }

  String _getCourseName(TeacherProvider provider, String courseId) {
    final course = provider.courses.firstWhere(
          (c) => c.id == courseId,
      orElse: () => TeacherCourse(
        id: 'unknown',
        title: 'Unknown',
        description: '',
        category: '',
        level: '',
        price: 0.0,
        duration: '',
        imageUrl: '',
        teacherId: '',
        isPublished: false,
        enrolledStudents: 0,
        rating: 0.0,
        totalRating: 0,
        modules: [],
        teacherName: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
    return course.title;
  }
}
