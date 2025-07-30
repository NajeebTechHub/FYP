import 'package:flutter/material.dart';
import 'package:mentorcraft2/auth/simple_auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:mentorcraft2/teacher/provider/teacher_provider.dart';
import '../../theme/color.dart';
import '../models/student_progress.dart';
import '../widgets/student_progress_card.dart';

class StudentProgressScreen extends StatefulWidget {
  const StudentProgressScreen({Key? key}) : super(key: key);

  @override
  State<StudentProgressScreen> createState() => _StudentProgressScreenState();
}

class _StudentProgressScreenState extends State<StudentProgressScreen> {
  String _selectedCourse = 'all';
  String _selectedStatus = 'all';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = Provider.of<SimpleAuthProvider>(context, listen: false).user?.id ?? '';
      Provider.of<TeacherProvider>(context, listen: false).fetchStudentProgress(userId);
    });
  }

  String _deriveStatus(StudentProgress student) {
    final p = student.progressPercentage;
    if (p >= 100.0) return 'completed';
    if (p > 0.0) return 'in_progress';
    return 'enrolled';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBackground : Colors.white;
    final inputFill = isDark ? AppColors.cardDark : Colors.grey[100];
    final fadedText = isDark ? AppColors.textFaded : Colors.grey[600];

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : Colors.grey[50],
      body: Consumer<TeacherProvider>(
        builder: (context, teacherProvider, _) {
          final isLoading = !teacherProvider.isStudentProgressLoaded;
          final progressList = teacherProvider.studentProgress;

          final filtered = progressList.where((student) {
            final matchesCourse = _selectedCourse == 'all' || student.courseId == _selectedCourse;
            final status = _deriveStatus(student);
            final matchesStatus = _selectedStatus == 'all' || status == _selectedStatus;
            final matchesSearch = student.studentName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                student.studentEmail.toLowerCase().contains(_searchQuery.toLowerCase());
            return matchesCourse && matchesStatus && matchesSearch;
          }).toList();

          final total = filtered.length;
          final active = filtered.where((s) => ['enrolled', 'in_progress'].contains(_deriveStatus(s))).length;
          final completed = filtered.where((s) => _deriveStatus(s) == 'completed').length;

          return Column(
            children: [
              Container(
                color: bgColor,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Search students...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: inputFill,
                      ),
                      onChanged: (value) => setState(() => _searchQuery = value),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Flexible(
                          child: DropdownButtonFormField<String>(
                            isExpanded: true,
                            value: _selectedCourse,
                            decoration: _dropdownDecoration(inputFill!),
                            items: [
                              const DropdownMenuItem(value: 'all', child: Text('All Courses')),
                              ...teacherProvider.courses.map((course) => DropdownMenuItem(
                                value: course.id,
                                child: Text(course.title, overflow: TextOverflow.ellipsis),
                              )),
                            ],
                            onChanged: (value) => setState(() => _selectedCourse = value!),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Flexible(
                          child: DropdownButtonFormField<String>(
                            isExpanded: true,
                            value: _selectedStatus,
                            decoration: _dropdownDecoration(inputFill),
                            items: const [
                              DropdownMenuItem(value: 'all', child: Text('All Status')),
                              DropdownMenuItem(value: 'enrolled', child: Text('Enrolled')),
                              DropdownMenuItem(value: 'in_progress', child: Text('In Progress')),
                              DropdownMenuItem(value: 'completed', child: Text('Completed')),
                            ],
                            onChanged: (value) => setState(() => _selectedStatus = value!),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                color: bgColor,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    _buildSummaryItem('Total Students', '$total', Colors.blue, fadedText!),
                    _buildSummaryItem('Active', '$active', Colors.green, fadedText),
                    _buildSummaryItem('Completed', '$completed', Colors.purple, fadedText),
                  ],
                ),
              ),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : filtered.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No matching student found.',
                        style: TextStyle(fontSize: 16, color: fadedText),
                      ),
                    ],
                  ),
                )
                    : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final student = filtered[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: StudentProgressCard(
                        student: student,
                        onTap: () {},
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  InputDecoration _dropdownDecoration(Color fillColor) {
    return InputDecoration(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      filled: true,
      fillColor: fillColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color, Color fadedColor) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: TextStyle(fontSize: 12, color: fadedColor)),
        ],
      ),
    );
  }
}
