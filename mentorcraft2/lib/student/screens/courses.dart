import 'dart:async';
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
  final TextEditingController _searchController = TextEditingController();
  final ValueNotifier<String> _searchQueryNotifier = ValueNotifier<String>('');

  final List<String> _categories = [
    'Development', 'UI/UX', 'App dev', 'Machine Learning',
    'Photography', 'Music', 'Health & Fitness', 'Data Science'
  ];

  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    _searchQueryNotifier.dispose();
    super.dispose();
  }

  DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  void _clearFilters() {
    _searchController.clear();
    _searchQueryNotifier.value = '';
    setState(() {
      _selectedCategory = null;
    });
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search courses, instructors...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQueryNotifier.value.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.clear),
            onPressed: _clearFilters,
          )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onChanged: (value) {
          if (_debounce?.isActive ?? false) _debounce!.cancel();
          _debounce = Timer(const Duration(milliseconds: 400), () {
            _searchQueryNotifier.value = value;
          });
        },
      ),
    );
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
          if (snapshot.hasError || !snapshot.hasData) {
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
              totalRating: (data['totalRating'] as num?)?.toDouble() ?? 0.0,
              enrolledStudents: (data['enrolledStudents'] ?? 0).toInt(),
              createdAt: _parseDate(data['createdAt']),
              updatedAt: _parseDate(data['updatedAt']),
              modules: [],
            );
          }).toList();

          return SingleChildScrollView(
            child: Column(
              children: [
                _buildSearchBar(),
                FilterSection(
                  selectedCategory: _selectedCategory,
                  categories: _categories,
                  onCategorySelected: (category) {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                ),
                ValueListenableBuilder<String>(
                  valueListenable: _searchQueryNotifier,
                  builder: (context, searchQuery, _) {
                    final filteredCourses = allCourses.where((course) {
                      final matchCategory = _selectedCategory == null ||
                          course.title.toLowerCase().contains(_selectedCategory!.toLowerCase());
                      final matchSearch = searchQuery.isEmpty ||
                          course.teacherName.toLowerCase().contains(searchQuery.toLowerCase()) ||
                          course.description.toLowerCase().contains(searchQuery.toLowerCase());

                      return matchCategory && matchSearch;
                    }).toList();

                    if (filteredCourses.isEmpty) return _buildEmptyState();
                    return _buildCourseGrid(filteredCourses);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCourseGrid(List<Course> filteredCourses) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: filteredCourses.length,
        itemBuilder: (context, index) => _buildCourseCard(filteredCourses[index]),
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
            onPressed: _clearFilters,
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
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('courses').doc(course.id).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const SizedBox(); // or loading indicator
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final updatedCourse = Course(
          id: course.id,
          title: data['title'] ?? '',
          description: data['description'] ?? '',
          imageUrl: data['imageUrl'] ?? '',
          teacherId: '',
          teacherName: data['teacherName'] ?? '',
          price: (data['price'] as num).toDouble(),
          duration: data['duration'] ?? '',
          level: data['level'] ?? '',
          totalRating: (data['totalRating'] as num?)?.toDouble() ?? 0.0,
          createdAt: DateTime.now(),
          modules: [],
          enrolledStudents: data['enrolledStudents'] ?? 0,
          updatedAt: DateTime.now(),
          rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
        );

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CourseDetailsScreen(course: updatedCourse),
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
                        updatedCourse.imageUrl,
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
                          '\$${updatedCourse.price.toStringAsFixed(2)}',
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
                        updatedCourse.title,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Instructor: ${updatedCourse.teacherName}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        updatedCourse.description,
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.star, size: 16, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            '${updatedCourse.rating.toStringAsFixed(1)} (${updatedCourse.totalRating.toInt()})',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.people_outline, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text('${updatedCourse.enrolledStudents}', style: TextStyle(color: Colors.grey[600])),
                          const Spacer(),
                          ElevatedButton.icon(
                            onPressed: () => _showRatingDialog(updatedCourse.id),
                            icon: const Icon(Icons.star, size: 16, color: Colors.white),
                            label: const Text("Rate", style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              textStyle: const TextStyle(fontSize: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              minimumSize: const Size(10, 30),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildInfoChip(Icons.timer, updatedCourse.duration),
                          const SizedBox(width: 8),
                          _buildInfoChip(Icons.bar_chart, updatedCourse.level),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () async {
                          final price = updatedCourse.price;
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
                                      Navigator.pop(context);
                                      final uid = FirebaseAuth.instance.currentUser!.uid;
                                      final courseDoc = FirebaseFirestore.instance.collection('courses').doc(updatedCourse.id);
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
      },
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

  Future<void> _showRatingDialog(String courseId) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final courseRef = FirebaseFirestore.instance.collection('courses').doc(courseId);
    final ratingRef = courseRef.collection('ratings').doc(uid);

    final existingRatingDoc = await ratingRef.get();
    if (existingRatingDoc.exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You have already rated this course.")),
      );
      return;
    }

    final TextEditingController ratingController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Rate this Course"),
        content: TextField(
          controller: ratingController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: "Enter rating (1.0 to 5.0)"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              final rating = double.tryParse(ratingController.text);

              if (rating != null && rating >= 1.0 && rating <= 5.0) {
                await ratingRef.set({'rating': rating});

                // Recalculate average
                final ratingsSnapshot = await courseRef.collection('ratings').get();
                final total = ratingsSnapshot.docs.fold<double>(
                  0.0,
                      (sum, doc) => sum + (doc['rating'] as num).toDouble(),
                );
                final avg = total / ratingsSnapshot.docs.length;

                await courseRef.update({'rating': avg});

                await courseRef.update({'totalRating': FieldValue.increment(1)});

                Navigator.pop(context);

                setState(() {});

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Rating submitted")),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please enter a valid rating between 1.0 and 5.0")),
                );
              }
            },
            child: const Text("Submit"),
          ),
        ],
      ),
    );
  }
}


