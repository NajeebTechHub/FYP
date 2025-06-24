import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mentorcraft2/teacher/provider/teacher_provider.dart';
import '../models/teacher_course.dart';
import '../../theme/color.dart';

class EditCourseScreen extends StatefulWidget {
  final TeacherCourse course;

  const EditCourseScreen({Key? key, required this.course}) : super(key: key);

  @override
  State<EditCourseScreen> createState() => _EditCourseScreenState();
}

class _EditCourseScreenState extends State<EditCourseScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _durationController;

  late String _selectedCategory;
  late String _selectedLevel;
  late List<String> _tags;

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
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.course.title);
    _descriptionController = TextEditingController(text: widget.course.description);
    _priceController = TextEditingController(text: widget.course.price.toString());
    _durationController = TextEditingController(text: widget.course.duration);
    _selectedCategory = widget.course.category;
    _selectedLevel = widget.course.level;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Course'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _updateCourse,
            child: const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Course Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
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
                      items: _categories.map((category) => DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      )).toList(),
                      onChanged: (value) => setState(() => _selectedCategory = value!),
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
                      items: _levels.map((level) => DropdownMenuItem(
                        value: level,
                        child: Text(level),
                      )).toList(),
                      onChanged: (value) => setState(() => _selectedLevel = value!),
                    ),
                  // ),
              //   ],
              // ),
              const SizedBox(height: 16),
              // Row(
              //   children: [
              //     Expanded(
              //       child:
                    TextFormField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Price (\$)',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value?.isEmpty == true) return 'Required';
                        if (double.tryParse(value!) == null) return 'Invalid price';
                        return null;
                      },
                    ),
                  // ),
                  const SizedBox(height: 16),
                  // Expanded(
                  //   child:
                    TextFormField(
                      controller: _durationController,
                      decoration: const InputDecoration(
                        labelText: 'Duration',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value?.isEmpty == true ? 'Required' : null,
                    ),
                  // ),
                // ],
              // ),
            ],
          ),
        ),
      ),
    );
  }

  void _updateCourse() {
    if (_formKey.currentState?.validate() ?? false) {
      final updatedCourse = TeacherCourse(
        id: widget.course.id,
        title: _titleController.text,
        description: _descriptionController.text,
        category: _selectedCategory,
        level: _selectedLevel,
        price: double.parse(_priceController.text),
        duration: _durationController.text,
        imageUrl: widget.course.imageUrl,
        teacherId: widget.course.teacherId,
        teacherName: widget.course.teacherName,
        createdAt: widget.course.createdAt,
        updatedAt: DateTime.now(),
        isPublished: widget.course.isPublished,
        enrolledStudents: widget.course.enrolledStudents,
        rating: widget.course.rating,
        totalRatings: widget.course.totalRatings,
        modules: widget.course.modules,
      );

      Provider.of<TeacherProvider>(context, listen: false).updateCourse(updatedCourse);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Course updated successfully')),
      );
    }
  }
}