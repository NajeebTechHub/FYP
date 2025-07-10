import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mentorcraft2/teacher/provider/teacher_provider.dart';
import '../models/teacher_announcement.dart';
import '../../theme/color.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // 🔸 Firestore import

class CreateAnnouncementScreen extends StatefulWidget {
  const CreateAnnouncementScreen({Key? key}) : super(key: key);

  @override
  State<CreateAnnouncementScreen> createState() => _CreateAnnouncementScreenState();
}

class _CreateAnnouncementScreenState extends State<CreateAnnouncementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  String _selectedCourse = '';
  String _selectedType = 'general';
  bool _isUrgent = false;
  bool _publishImmediately = true;

  final List<String> _types = ['general', 'assignment', 'reminder', 'announcement'];

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Announcement'),
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Consumer<TeacherProvider>(
        builder: (context, teacherProvider, child) {
          if (_selectedCourse.isEmpty && teacherProvider.courses.isNotEmpty) {
            _selectedCourse = teacherProvider.courses.first.id;
          }

          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<String>(
                    value: _selectedCourse.isEmpty ? null : _selectedCourse,
                    decoration: const InputDecoration(
                      labelText: 'Select Course',
                      border: OutlineInputBorder(),
                    ),
                    items: teacherProvider.courses.map((course) {
                      return DropdownMenuItem(
                        value: course.id,
                        child: Text(course.title),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCourse = value!;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a course';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    value: _selectedType,
                    decoration: const InputDecoration(
                      labelText: 'Announcement Type',
                      border: OutlineInputBorder(),
                    ),
                    items: _types.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type.toUpperCase()),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedType = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Announcement Title',
                      hintText: 'Enter a clear title',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _contentController,
                    maxLines: 6,
                    decoration: const InputDecoration(
                      labelText: 'Announcement Content',
                      hintText: 'Write your announcement here...',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the announcement content';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Options',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 12),
                          SwitchListTile(
                            title: const Text('Mark as Urgent'),
                            subtitle: const Text('This will highlight the announcement'),
                            value: _isUrgent,
                            onChanged: (value) {
                              setState(() {
                                _isUrgent = value;
                              });
                            },
                          ),
                          SwitchListTile(
                            title: const Text('Publish Immediately'),
                            subtitle: const Text('Students will see this right away'),
                            value: _publishImmediately,
                            onChanged: (value) {
                              setState(() {
                                _publishImmediately = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  Row(
                    children: [
                      if (!_publishImmediately) ...[
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _saveDraft,
                            child: const Text('Save as Draft'),
                          ),
                        ),
                        const SizedBox(width: 16),
                      ],
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _createAnnouncement,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                          ),
                          child: Text(_publishImmediately ? 'Publish' : 'Create'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _saveDraft() {
    if (_formKey.currentState?.validate() ?? false) {
      _createAnnouncementWithStatus(false);
    }
  }

  void _createAnnouncement() {
    if (_formKey.currentState?.validate() ?? false) {
      _createAnnouncementWithStatus(_publishImmediately);
    }
  }

  Future<void> _createAnnouncementWithStatus(bool isPublished) async {
    final teacherProvider = Provider.of<TeacherProvider>(context, listen: false);
    final selectedCourse = teacherProvider.courses.firstWhere(
          (course) => course.id == _selectedCourse,
    );

    final announcement = TeacherAnnouncement(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text,
      content: _contentController.text,
      courseId: _selectedCourse,
      courseName: selectedCourse.title,
      teacherId: teacherProvider.teacherId,
      teacherName: teacherProvider.teacherName,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isUrgent: _isUrgent,
      isPublished: isPublished,
      targetStudents: [],
      readCount: 0,
      type: _selectedType,
    );

    // Save to provider
    teacherProvider.addAnnouncement(announcement);

    try {
      // 🔥 Save to Firestore
      await FirebaseFirestore.instance.collection('announcements').doc(announcement.id).set({
        'id': announcement.id,
        'title': announcement.title,
        'content': announcement.content,
        'courseId': announcement.courseId,
        'courseName': announcement.courseName,
        'teacherId': announcement.teacherId,
        'teacherName': announcement.teacherName,
        'createdAt': announcement.createdAt.toIso8601String(),
        'updatedAt': announcement.updatedAt.toIso8601String(),
        'isUrgent': announcement.isUrgent,
        'isPublished': announcement.isPublished,
        'targetStudents': announcement.targetStudents,
        'readCount': announcement.readCount,
        'type': announcement.type,
      });

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Announcement ${isPublished ? 'published' : 'saved as draft'} successfully'),
          backgroundColor: isPublished ? Colors.green : Colors.orange,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error saving announcement to Firestore'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
