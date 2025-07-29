import 'package:flutter/material.dart';
import 'package:mentorcraft2/auth/simple_auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:mentorcraft2/teacher/provider/teacher_provider.dart';
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
      final currentUserId = Provider.of<SimpleAuthProvider>(context, listen: false).user?.id ?? '';
      Provider.of<TeacherProvider>(context, listen: false).fetchStudentProgress(currentUserId);
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
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Consumer<TeacherProvider>(
        builder: (context, teacherProvider, child) {
          final isLoading = !teacherProvider.isStudentProgressLoaded;
          final progressList = teacherProvider.studentProgress;

          List<StudentProgress> filteredStudents = progressList.where((student) {
            final matchesCourse = _selectedCourse == 'all' || student.courseId == _selectedCourse;

            final derivedStatus = _deriveStatus(student);
            final matchesStatus = _selectedStatus == 'all' || derivedStatus == _selectedStatus;

            final matchesSearch = student.studentName.toLowerCase().contains(_searchQuery.trim().toLowerCase()) ||
                student.studentEmail.toLowerCase().contains(_searchQuery.trim().toLowerCase());

            return matchesCourse && matchesStatus && matchesSearch;
          }).toList();

          final total = filteredStudents.length;
          final active = filteredStudents.where((s) {
            final st = _deriveStatus(s);
            return st == 'enrolled' || st == 'in_progress';
          }).length;
          final completed = filteredStudents.where((s) => _deriveStatus(s) == 'completed').length;

          return Column(
            children: [
              // Filters
              Container(
                color: Colors.white,
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
                        fillColor: Colors.grey[100],
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
                            decoration: _dropdownDecoration(),
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
                            decoration: _dropdownDecoration(),
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

              // Summary Stats
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    _buildSummaryItem('Total Students', '$total', Colors.blue),
                    _buildSummaryItem('Active', '$active', Colors.green),
                    _buildSummaryItem('Completed', '$completed', Colors.purple),
                  ],
                ),
              ),

              // Student Cards List
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : filteredStudents.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No matching student found.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
                    : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredStudents.length,
                  itemBuilder: (context, index) {
                    final student = filteredStudents[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: StudentProgressCard(
                        student: student,
                        onTap: () {
                          // Optional: Show more student detail
                        },
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

  InputDecoration _dropdownDecoration() {
    return InputDecoration(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      filled: true,
      fillColor: Colors.grey[100],
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }
}
