import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mentorcraft2/teacher/provider/teacher_provider.dart';
import '../models/teacher_course.dart';

class CreateCourseScreen extends StatefulWidget {
  const CreateCourseScreen({Key? key}) : super(key: key);

  @override
  State<CreateCourseScreen> createState() => _CreateCourseScreenState();
}

class _CreateCourseScreenState extends State<CreateCourseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _durationController = TextEditingController();

  String _selectedCategory = 'Mobile Development';
  String _selectedLevel = 'Beginner';
  List<String> _tags = [];
  final _tagController = TextEditingController();

  final List<String> _categories = [
    'Mobile Development',
    'Web Development',
    'Data Science',
    'Machine Learning',
    'UI/UX Design',
    'Backend Development',
    'DevOps',
    'Cybersecurity',
  ];

  final List<String> _levels = ['Beginner', 'Intermediate', 'Advanced'];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Course'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Course Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Course Title',
                  hintText: 'Enter course title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a course title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Course Description',
                  hintText: 'Describe what students will learn',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a course description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Category and Level Row
              // Row(
              //   children: [
              //     Expanded(
              //       child:
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                      items: _categories.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value!;
                        });
                      },
                    ),
                  // ),
                  const SizedBox(height: 16),
                  // Expanded(
                  //   child:
                    DropdownButtonFormField<String>(
                      value: _selectedLevel,
                      decoration: const InputDecoration(
                        labelText: 'Level',
                        border: OutlineInputBorder(),
                      ),
                      items: _levels.map((level) {
                        return DropdownMenuItem(
                          value: level,
                          child: Text(level),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedLevel = value!;
                        });
                      },
                    ),
                //   ),
                // ],
              // ),
              const SizedBox(height: 16),

              // Price and Duration Row
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Price (\$)',
                        hintText: '99.99',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a price';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid price';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _durationController,
                      decoration: const InputDecoration(
                        labelText: 'Duration',
                        hintText: '10 hours',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter duration';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Tags Section
              const Text(
                'Tags',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _tagController,
                      decoration: const InputDecoration(
                        hintText: 'Add a tag',
                        border: OutlineInputBorder(),
                      ),
                      onFieldSubmitted: _addTag,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _addTag(_tagController.text),
                    child: const Text('Add'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _tags.map((tag) {
                  return Chip(
                    label: Text(tag),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () {
                      setState(() {
                        _tags.remove(tag);
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _saveDraft,
                      child: const Text('Save as Draft'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _publishCourse,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                      child: const Text('Publish Course'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addTag(String tag) {
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagController.clear();
      });
    }
  }

  void _saveDraft() {
    if (_formKey.currentState?.validate() ?? false) {
      _createCourse(false);
    }
  }

  void _publishCourse() {
    if (_formKey.currentState?.validate() ?? false) {
      _createCourse(true);
    }
  }

  void _createCourse(bool isPublished) {
    final teacherProvider = Provider.of<TeacherProvider>(context, listen: false);

    final course = TeacherCourse(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text,
      description: _descriptionController.text,
      category: _selectedCategory,
      level: _selectedLevel,
      price: double.parse(_priceController.text),
      duration: _durationController.text,
      imageUrl: 'assets/course_placeholder.jpg',
      teacherId: teacherProvider.teacherId,
      teacherName: teacherProvider.teacherName,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isPublished: isPublished,
      enrolledStudents: 0,
      rating: 0.0,
      totalRatings: 0,
      tags: _tags,
      modules: [],
    );

    teacherProvider.addCourse(course);

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Course ${isPublished ? 'published' : 'saved as draft'} successfully'),
        backgroundColor: isPublished ? Colors.green : Colors.orange,
      ),
    );
  }
}