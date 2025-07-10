import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/course.dart';
import 'package:mentorcraft2/theme/color.dart';
import '../widgets/explore_widgets/filter_section.dart';
import 'course_details_screen.dart';

class CoursesScreen extends StatefulWidget {
  static const routeName = '/courses';

  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  String? _selectedCategory;
  String? _selectedLevel;
  String? _selectedDuration;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = [
    'Development', 'Design', 'Business', 'Marketing',
    'Photography', 'Music', 'Health & Fitness', 'Data Science'
  ];

  final List<String> _levels = ['Beginner', 'Intermediate', 'Advanced', 'All Levels'];

  final List<String> _durations = [
    'Less than 1 hour',
    '1-3 hours',
    '3-6 hours',
    '6-10 hours',
    'Over 10 hours'
  ];

  List<Course> _filteredCourses = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterCourses(List<Course> allCourses) {
    setState(() {
      _filteredCourses = allCourses.where((course) {
        bool matchesCategory = _selectedCategory == null || course.title.toLowerCase().contains(_selectedCategory!.toLowerCase());
        bool matchesLevel = _selectedLevel == null || course.level == _selectedLevel;
        bool matchesDuration = _selectedDuration == null || course.duration == _selectedDuration;
        bool matchesSearch = _searchQuery.isEmpty ||
            course.teacherName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            course.description.toLowerCase().contains(_searchQuery.toLowerCase());

        return matchesCategory && matchesLevel && matchesDuration && matchesSearch;
      }).toList();
    });
  }

  void _clearFilters(List<Course> allCourses) {
    setState(() {
      _selectedCategory = null;
      _selectedLevel = null;
      _selectedDuration = null;
      _searchQuery = '';
      _searchController.clear();
      _filteredCourses = List.from(allCourses);
    });
  }

  DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('courses')
            .where('isPublished', isEqualTo: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Error loading courses."));
          }

          final allCourses = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Course(
              id: doc.id,
              title: data['title'] ?? '',
              description: data['description'] ?? '',
              price: (data['price'] ?? 0).toDouble(),
              duration: data['duration'] ?? '',
              level: data['level'] ?? '',
              rating: (data['rating'] ?? 0).toDouble(),
              imageUrl: data['imageUrl'] ?? '',
              teacherId: data['teacherId'] ?? '',
              teacherName: data['teacherName'] ?? '',
              totalRating: (data['totalRating'] ?? 0).toDouble(),
              enrolledStudents: (data['enrolledStudents'] ?? 0).toInt(),
              createdAt: _parseDate(data['createdAt']),
              updatedAt: _parseDate(data['updatedAt']),
            );
          }).toList();

          if (_filteredCourses.isEmpty) {
            _filteredCourses = List.from(allCourses);
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                _buildSearchBar(allCourses),
                FilterSection(
                  selectedCategory: _selectedCategory,
                  selectedLevel: _selectedLevel,
                  selectedDuration: _selectedDuration,
                  searchQuery: _searchQuery,
                  categories: _categories,
                  levels: _levels,
                  durations: _durations,
                  totalCourses: allCourses.length,
                  filteredCoursesCount: _filteredCourses.length,
                  onCategorySelected: (category) {
                    setState(() {
                      _selectedCategory = category;
                      _filterCourses(allCourses);
                    });
                  },
                  onLevelSelected: (level) {
                    setState(() {
                      _selectedLevel = level;
                      _filterCourses(allCourses);
                    });
                  },
                  onDurationSelected: (duration) {
                    setState(() {
                      _selectedDuration = duration;
                      _filterCourses(allCourses);
                    });
                  },
                  onClearFilters: () => _clearFilters(allCourses),
                  onSearchQueryRemoved: (_) {
                    setState(() {
                      _searchQuery = '';
                      _searchController.clear();
                      _filterCourses(allCourses);
                    });
                  },
                ),
                _buildCourseGrid(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchBar(List<Course> allCourses) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search courses, instructors...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              setState(() {
                _searchController.clear();
                _searchQuery = '';
                _filterCourses(allCourses);
              });
            },
          )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
            _filterCourses(allCourses);
          });
        },
      ),
    );
  }

  Widget _buildCourseGrid() {
    if (_filteredCourses.isEmpty) return _buildEmptyState();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _filteredCourses.length,
        itemBuilder: (context, index) => _buildCourseCard(_filteredCourses[index]),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'No courses found',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filter settings',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              _clearFilters(_filteredCourses);
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Clear Filters'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseCard(Course course) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CourseDetailsScreen(course: course),
          ),
        );
      },
      child: Card(
        elevation: 3,
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Image.network(
                    course.imageUrl,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 120,
                      width: double.infinity,
                      color: Colors.grey[300],
                      alignment: Alignment.center,
                      child: const Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
                    ),
                  ),

                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.darkBlue.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '\$${course.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Instructor: ${course.teacherName}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    course.description,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.star, size: 16, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text('${course.rating}', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      Icon(Icons.people_outline, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text('${course.enrolledStudents}', style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildInfoChip(Icons.timer, course.duration),
                      const SizedBox(width: 8),
                      _buildInfoChip(Icons.bar_chart, course.level),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () async {
                      final price = course.price;
                      final TextEditingController controller = TextEditingController();

                      await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Dummy Payment"),
                          content: TextField(
                            controller: controller,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: "Enter payment amount"),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () async {
                                final enteredAmount = double.tryParse(controller.text);
                                if (enteredAmount == price) {
                                  Navigator.pop(context); // close dialog
                                  final uid = FirebaseAuth.instance.currentUser!.uid;

                                  final courseDoc = FirebaseFirestore.instance.collection('courses').doc(course.id);

                                  final enrolledUserRef = courseDoc.collection('enrolledUsers').doc(uid);
                                  final alreadyEnrolled = await enrolledUserRef.get();

                                  if (!alreadyEnrolled.exists) {
                                    await enrolledUserRef.set({'enrolledAt': FieldValue.serverTimestamp()});
                                    await courseDoc.update({'enrolledStudents': FieldValue.increment(1)});
                                  }

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Enrollment successful")),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Incorrect amount!")),
                                  );
                                }
                              },
                              child: const Text("Pay"),
                            ),
                          ],
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkBlue,
                      minimumSize: const Size(double.infinity, 36),
                    ),
                    child: const Text('Enroll Now', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.grey[700]),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[700])),
        ],
      ),
    );
  }
}


