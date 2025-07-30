import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/services.dart';
import 'package:mentorcraft2/teacher/provider/teacher_provider.dart';
import '../../services/course_service.dart';
import '../models/teacher_course.dart';
import '../../theme/color.dart';

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
  File? _selectedImage;
  String? _uploadedImageUrl;
  bool _isLoading = false;

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
        final byteData = await rootBundle.load('assets/placeholder.jpg');
        final tempDir = Directory.systemTemp;
        fileToUpload = File('${tempDir.path}/placeholder.jpg');
        await fileToUpload.writeAsBytes(byteData.buffer.asUint8List());
      }

      await bucket.upload(fileName, fileToUpload);
      final publicUrl = bucket.getPublicUrl(fileName);
      return publicUrl;
    } catch (e) {
      debugPrint('Image upload failed: $e');
      return null;
    }
  }

  void _saveDraft() => _submitCourse(isPublished: false);
  void _publishCourse() => _submitCourse(isPublished: true);

  Future<void> _submitCourse({required bool isPublished}) async {
    final teacherProvider = Provider.of<TeacherProvider>(context, listen: false);

    final teacherId = teacherProvider.teacherId.trim();
    final teacherName = teacherProvider.teacherName.trim();

    if (teacherId.isEmpty || teacherName.isEmpty) {
      await teacherProvider.initializeData();

      if (teacherProvider.teacherId.isEmpty || teacherProvider.teacherName.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Teacher profile still not loaded')),
        );
        return;
      }
    }

    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);

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
        totalRating: 0,
        modules: [],
      );

      try {
        await CourseService().addCourse(course);
        await teacherProvider.fetchCourses();
        teacherProvider.reSubscribeCourses();

        if (!mounted) return;
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Course ${isPublished ? 'published' : 'saved as draft'} successfully'),
            backgroundColor: isPublished ? Colors.green : Colors.orange,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating course: $e'), backgroundColor: Colors.red),
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? AppColors.darkBackground : AppColors.white;
    final labelColor = isDark ? AppColors.textLight : AppColors.textPrimary;

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Create New Course'),
        foregroundColor: labelColor,
        backgroundColor: backgroundColor,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildTextField(_titleController, 'Course Title', 'Enter course title'),
              const SizedBox(height: 16),
              _buildTextField(_descriptionController, 'Course Description', 'Describe what students will learn', maxLines: 4),
              const SizedBox(height: 16),
              _buildDropdown(_selectedCategory, _categories, 'Category', (val) => setState(() => _selectedCategory = val)),
              const SizedBox(height: 16),
              _buildDropdown(_selectedLevel, _levels, 'Level', (val) => setState(() => _selectedLevel = val)),
              const SizedBox(height: 16),
              _buildPriceDurationRow(),
              const SizedBox(height: 16),
              _buildImagePicker(),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _saveDraft,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.secondary),
                        foregroundColor: AppColors.secondary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Save as Draft',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _publishCourse,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 3,
                      ),
                      child: const Text(
                        'Publish Course',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
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

  Widget _buildTextField(TextEditingController controller, String label, String hint, {int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(labelText: label, hintText: hint, border: const OutlineInputBorder()),
      validator: (val) => val == null || val.isEmpty ? 'Please enter $label' : null,
    );
  }

  Widget _buildDropdown(String value, List<String> options, String label, Function(String) onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      items: options.map((val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
      onChanged: (val) => onChanged(val!),
    );
  }

  Widget _buildPriceDurationRow() {
    return Row(
      children: [
        Expanded(child: _buildTextField(_priceController, 'Price (\$)', '99.99')),
        const SizedBox(width: 16),
        Expanded(child: _buildTextField(_durationController, 'Duration', '10 hours')),
      ],
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.darkBlue.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: _selectedImage != null
            ? ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            _selectedImage!,
            fit: BoxFit.cover,
            width: double.infinity,
          ),
        )
            : Center(
          child: Icon(
            Icons.image,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white38
                : Colors.black38,
            size: 40,
          ),
        ),
      )

    );
  }
}
