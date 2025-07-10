import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mentorcraft2/teacher/provider/teacher_provider.dart';
import '../../services/course_service.dart';
import '../models/teacher_course.dart';
import 'package:flutter/services.dart'; // for rootBundle

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
  final _tagController = TextEditingController();
  File? _selectedImage;
  String? _uploadedImageUrl;

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

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImage(File? imageFile) async {
    try {
      final fileName = 'public/course_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final bucket = Supabase.instance.client.storage.from('mentorcraft-images');

      File fileToUpload;

      if (imageFile != null) {
        fileToUpload = imageFile;
      } else {
        // Load asset placeholder and save to temp file
        final byteData = await rootBundle.load('assets/placeholder.jpg');
        final tempDir = Directory.systemTemp;
        fileToUpload = File('${tempDir.path}/placeholder.jpg');
        await fileToUpload.writeAsBytes(byteData.buffer.asUint8List());
      }

      await bucket.upload(fileName, fileToUpload);
      final publicUrl = bucket.getPublicUrl(fileName);

      setState(() {
        _uploadedImageUrl = publicUrl;
      });

      return publicUrl;
    } catch (e) {
      print('Image upload failed: $e');
      return null;
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

  void _createCourse(bool isPublished) async {
    final teacherProvider = Provider.of<TeacherProvider>(context, listen: false);

    final uploadedUrl = await _uploadImage(_selectedImage);
    final imageUrl = uploadedUrl ?? '';

    final course = TeacherCourse(
      id: '',
      title: _titleController.text,
      description: _descriptionController.text,
      category: _selectedCategory,
      level: _selectedLevel,
      price: double.tryParse(_priceController.text) ?? 0.0,
      duration: _durationController.text,
      imageUrl: imageUrl,
      teacherId: teacherProvider.teacherId,
      teacherName: teacherProvider.teacherName,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isPublished: isPublished,
      enrolledStudents: 0,
      rating: 0.0,
      totalRatings: 0,
      modules: [],
    );

    try {
      await CourseService().addCourse(course);
      await teacherProvider.fetchCourses(teacherProvider.teacherId);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Course ${isPublished ? 'published' : 'saved as draft'} successfully'),
          backgroundColor: isPublished ? Colors.green : Colors.orange,
        ),
      );
    } catch (e) {
      print('Error creating course: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating course: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Course'),
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
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Course Title',
                  hintText: 'Enter course title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                value == null || value.isEmpty ? 'Please enter a course title' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Course Description',
                  hintText: 'Describe what students will learn',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                value == null || value.isEmpty ? 'Please enter a course description' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem(value: category, child: Text(category));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedLevel,
                decoration: const InputDecoration(
                  labelText: 'Level',
                  border: OutlineInputBorder(),
                ),
                items: _levels.map((level) {
                  return DropdownMenuItem(value: level, child: Text(level));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedLevel = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
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
                        if (value == null || value.isEmpty) return 'Please enter a price';
                        if (double.tryParse(value) == null) return 'Please enter a valid price';
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
                      validator: (value) =>
                      value == null || value.isEmpty ? 'Please enter duration' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey[200],
                  ),
                  child: _selectedImage != null
                      ? Image.file(_selectedImage!, fit: BoxFit.cover)
                      : const Center(child: Text('Tap to pick course image')),
                ),
              ),
              const SizedBox(height: 16),
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
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
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
}
