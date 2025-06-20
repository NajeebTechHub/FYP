import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mentorcraft2/teacher/provider/teacher_provider.dart';
import '../models/student_progress.dart';
import '../../theme/color.dart';
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Consumer<TeacherProvider>(
        builder: (context, teacherProvider, child) {
          return Column(
            children: [
              // Filters Section
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Search Bar
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
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                    const SizedBox(height: 12),

                    // Filters Row
                    Column(
                      children: [
                        // Course Filter
                        // Expanded(
                        //   child:
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Course:',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              DropdownButtonFormField<String>(
                                value: _selectedCourse,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[100],
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                                items: [
                                  const DropdownMenuItem(
                                    value: 'all',
                                    child: Text('All Courses'),
                                  ),
                                  ...teacherProvider.courses.map((course) => DropdownMenuItem(
                                    value: course.id,
                                    child: Text(course.title),
                                  )).toList(),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _selectedCourse = value!;
                                  });
                                },
                              ),
                            ],
                          ),
                        // ),
                        const SizedBox(width: 12),

                        // Status Filter
                        // Expanded(
                        //   child:
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Status:',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              DropdownButtonFormField<String>(
                                value: _selectedStatus,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[100],
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                                items: const [
                                  DropdownMenuItem(value: 'all', child: Text('All Status')),
                                  DropdownMenuItem(value: 'enrolled', child: Text('Enrolled')),
                                  DropdownMenuItem(value: 'in_progress', child: Text('In Progress')),
                                  DropdownMenuItem(value: 'completed', child: Text('Completed')),
                                  DropdownMenuItem(value: 'dropped', child: Text('Dropped')),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _selectedStatus = value!;
                                  });
                                },
                              ),
                            ],
                          ),
                        // ),
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
                    _buildSummaryItem('Total Students', '245', Colors.blue),
                    _buildSummaryItem('Active', '189', Colors.green),
                    _buildSummaryItem('Completed', '56', Colors.purple),
                    _buildSummaryItem('At Risk', '12', Colors.red),
                  ],
                ),
              ),

              // Student List
              Expanded(
                child: _buildStudentList(teacherProvider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentList(TeacherProvider teacherProvider) {
    List<StudentProgress> filteredStudents = teacherProvider.studentProgress;

    // Filter by course
    if (_selectedCourse != 'all') {
      filteredStudents = filteredStudents.where((student) => student.courseId == _selectedCourse).toList();
    }

    // Filter by status
    if (_selectedStatus != 'all') {
      filteredStudents = filteredStudents.where((student) => student.status == _selectedStatus).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filteredStudents = filteredStudents.where((student) =>
      student.studentName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          student.studentEmail.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }

    if (filteredStudents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty ? 'No students found' : 'No students match your search',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isEmpty
                  ? 'Students will appear here once they enroll in your courses'
                  : 'Try adjusting your search terms or filters',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredStudents.length,
      itemBuilder: (context, index) {
        final student = filteredStudents[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: StudentProgressCard(
            student: student,
            onTap: () {
              _showStudentDetailsModal(context, student);
            },
          ),
        );
      },
    );
  }

  void _showStudentDetailsModal(BuildContext context, StudentProgress student) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // Handle
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundImage: AssetImage('assets/images/11.png'),
                        backgroundColor: Colors.grey[300],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              student.studentName,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              student.studentEmail,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getStatusColor(student.status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          student.status.toUpperCase(),
                          style: TextStyle(
                            color: _getStatusColor(student.status),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Progress Overview
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Course Progress',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              LinearProgressIndicator(
                                value: student.progressPercentage / 100,
                                backgroundColor: Colors.grey[300],
                                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('${student.progressPercentage.toStringAsFixed(1)}% Complete'),
                                  Text('${student.completedLessons}/${student.totalLessons} Lessons'),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Stats Grid
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 1.5,
                          children: [
                            _buildStatCard('Time Spent', '${student.timeSpent ~/ 60}h ${student.timeSpent % 60}m', Icons.access_time),
                            _buildStatCard('Overall Grade', '${student.overallGrade.toStringAsFixed(1)}%', Icons.grade),
                            _buildStatCard('Enrolled', _formatDate(student.enrolledAt), Icons.calendar_today),
                            _buildStatCard('Last Active', _formatDate(student.lastAccessedAt), Icons.schedule),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Quiz Performance
                        if (student.quizAttempts.isNotEmpty) ...[
                          const Text(
                            'Quiz Performance',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...student.quizAttempts.map((attempt) => Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  attempt.passed ? Icons.check_circle : Icons.cancel,
                                  color: attempt.passed ? Colors.green : Colors.red,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(attempt.quizTitle),
                                ),
                                Text('${attempt.percentage.toStringAsFixed(1)}%'),
                              ],
                            ),
                          )).toList(),
                        ],

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'in_progress':
        return Colors.blue;
      case 'enrolled':
        return Colors.orange;
      case 'dropped':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else {
      return 'Just now';
    }
  }
}