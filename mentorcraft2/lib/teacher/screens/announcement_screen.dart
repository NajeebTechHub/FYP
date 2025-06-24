import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mentorcraft2/teacher/provider/teacher_provider.dart';
import 'package:mentorcraft2/teacher/models/teacher_announcement.dart';
import '../../../theme/color.dart';
import 'package:mentorcraft2/teacher/widgets/announcement_card.dart';

import 'create_announcement_screen.dart';

class AnnouncementsScreen extends StatefulWidget {
  const AnnouncementsScreen({Key? key}) : super(key: key);

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  String _selectedCourse = 'all';
  String _selectedType = 'all';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        foregroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterDialog(context);
            },
          ),
        ],
      ),
      body: Consumer<TeacherProvider>(
        builder: (context, teacherProvider, child) {
          return Column(
            children: [
              // Filters
              if (_selectedCourse != 'all' || _selectedType != 'all')
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.white,
                  child: Row(
                    children: [
                      const Text('Filters: '),
                      if (_selectedCourse != 'all') ...[
                        Chip(
                          label: Text(_getCourseName(teacherProvider, _selectedCourse)),
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

              // Announcements List
              Expanded(
                child: _buildAnnouncementsList(teacherProvider),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateAnnouncementScreen(),
            ),
          );
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add,color: Colors.white,),
        label: const Text('New Announcement',style: TextStyle(color: Colors.white),),
      ),
    );
  }

  Widget _buildAnnouncementsList(TeacherProvider teacherProvider) {
    List<TeacherAnnouncement> filteredAnnouncements = teacherProvider.announcements;

    // Filter by course
    if (_selectedCourse != 'all') {
      filteredAnnouncements = filteredAnnouncements
          .where((a) => a.courseId == _selectedCourse)
          .toList();
    }

    // Filter by type
    if (_selectedType != 'all') {
      filteredAnnouncements = filteredAnnouncements
          .where((a) => a.type == _selectedType)
          .toList();
    }

    if (filteredAnnouncements.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.campaign_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No announcements found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first announcement to communicate with students',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredAnnouncements.length,
      itemBuilder: (context, index) {
        final announcement = filteredAnnouncements[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: AnnouncementCard(
            announcement: announcement,
            onEdit: () {
              // Navigate to edit announcement
            },
            onDelete: () {
              _showDeleteConfirmation(context, announcement, teacherProvider);
            },
            onTogglePublish: () {
              // Toggle announcement published status
            },
          ),
        );
      },
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Consumer<TeacherProvider>(
        builder: (context, teacherProvider, child) {
          return AlertDialog(
            title: const Text('Filter Announcements'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedCourse,
                  decoration: const InputDecoration(labelText: 'Course'),
                  items: [
                    const DropdownMenuItem(value: 'all', child: Text('All Courses')),
                    ...teacherProvider.courses.map((course) => DropdownMenuItem(
                      value: course.id,
                      child: SizedBox(
                        width: 150,
                        child: Text(
                            course.title,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
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
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {});
                },
                child: const Text('Apply'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showDeleteConfirmation(
      BuildContext context,
      TeacherAnnouncement announcement,
      TeacherProvider provider,
      ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Announcement'),
        content: Text(
          'Are you sure you want to delete "${announcement.title}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.deleteAnnouncement(announcement.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Announcement deleted')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _getCourseName(TeacherProvider provider, String courseId) {
    final course = provider.courses.firstWhere(
          (c) => c.id == courseId,
      orElse: () => provider.courses.first,
    );
    return course.title;
  }
}