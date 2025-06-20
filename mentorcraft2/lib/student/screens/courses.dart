import 'package:flutter/material.dart';
import '../models/course.dart';
import 'package:mentorcraft2/theme/color.dart';
import '../widgets/main_widgets/app_drawer.dart';
import '../widgets/main_widgets/appbar_widget.dart';
import '../widgets/explore_widgets/filter_section.dart';

class CoursesScreen extends StatefulWidget {
  static const routeName = '/courses';

  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  // Filter variables
  String? _selectedCategory;
  String? _selectedLevel;
  String? _selectedDuration;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  // Available filter options
  final List<String> _categories = [
    'Development',
    'Design',
    'Business',
    'Marketing',
    'Photography',
    'Music',
    'Health & Fitness',
    'Data Science'
  ];

  final List<String> _levels = [
    'Beginner',
    'Intermediate',
    'Advanced',
    'All Levels'
  ];

  final List<String> _durations = [
    'Less than 1 hour',
    '1-3 hours',
    '3-6 hours',
    '6-10 hours',
    'Over 10 hours'
  ];

  // Sample course data
  late List<Course> _allCourses;
  late List<Course> _filteredCourses;

  @override
  void initState() {
    super.initState();

    // Initialize sample courses data
    _allCourses = [
      Course(
        id: '1',
        name: 'Flutter Development Masterclass',
        description: 'Learn to build beautiful mobile apps with Flutter framework',
        imageUrl: 'https://picsum.photos/id/1/300/200',
        price: 49.99,
        duration: '3-6 hours',
        level: 'Intermediate',
        rating: 4.8,
        studentsCount: 3452,
        instructor: 'Sarah Johnson',
        tags: ['Development', 'Mobile', 'Flutter'],
      ),
      Course(
        id: '2',
        name: 'UI/UX Design Fundamentals',
        description: 'Master the principles of good design for digital products',
        imageUrl: 'https://picsum.photos/id/2/300/200',
        price: 39.99,
        duration: '6-10 hours',
        level: 'Beginner',
        rating: 4.6,
        studentsCount: 5821,
        instructor: 'Michael Chen',
        tags: ['Design', 'UI/UX', 'Figma'],
      ),
      Course(
        id: '3',
        name: 'Digital Marketing Strategy',
        description: 'Create effective marketing campaigns for the digital age',
        imageUrl: 'https://picsum.photos/id/3/300/200',
        price: 59.99,
        duration: 'Over 10 hours',
        level: 'Intermediate',
        rating: 4.7,
        studentsCount: 2798,
        instructor: 'Emily Zhang',
        tags: ['Marketing', 'Digital', 'Strategy'],
      ),
      Course(
        id: '4',
        name: 'Data Science with Python',
        description: 'Learn data analysis and machine learning with Python',
        imageUrl: 'https://picsum.photos/id/4/300/200',
        price: 69.99,
        duration: 'Over 10 hours',
        level: 'Advanced',
        rating: 4.9,
        studentsCount: 4126,
        instructor: 'Robert Wilson',
        tags: ['Data Science', 'Python', 'Machine Learning'],
      ),
      Course(
        id: '5',
        name: 'Photography Basics',
        description: 'Understand camera settings and composition for better photos',
        imageUrl: 'https://picsum.photos/id/5/300/200',
        price: 29.99,
        duration: '1-3 hours',
        level: 'Beginner',
        rating: 4.5,
        studentsCount: 1876,
        instructor: 'Jessica Smith',
        tags: ['Photography', 'Creative', 'Camera'],
      ),
      Course(
        id: '6',
        name: 'Business Analytics',
        description: 'Use data to make better business decisions',
        imageUrl: 'https://picsum.photos/id/6/300/200',
        price: 54.99,
        duration: '3-6 hours',
        level: 'All Levels',
        rating: 4.7,
        studentsCount: 2145,
        instructor: 'David Kim',
        tags: ['Business', 'Analytics', 'Excel'],
      ),
      Course(
        id: '7',
        name: 'Guitar for Beginners',
        description: 'Learn to play guitar from scratch',
        imageUrl: 'https://picsum.photos/id/7/300/200',
        price: 34.99,
        duration: 'Less than 1 hour',
        level: 'Beginner',
        rating: 4.6,
        studentsCount: 3241,
        instructor: 'Carlos Santana',
        tags: ['Music', 'Guitar', 'Beginner'],
      ),
      Course(
        id: '8',
        name: 'Yoga and Meditation',
        description: 'Improve your physical and mental wellbeing',
        imageUrl: 'https://picsum.photos/id/8/300/200',
        price: 24.99,
        duration: '1-3 hours',
        level: 'All Levels',
        rating: 4.9,
        studentsCount: 5432,
        instructor: 'Lisa Brown',
        tags: ['Health & Fitness', 'Yoga', 'Meditation'],
      ),
    ];

    // Initialize filtered courses with all courses
    _filteredCourses = List.from(_allCourses);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Filter courses based on selected filters
  void _filterCourses() {
    setState(() {
      _filteredCourses = _allCourses.where((course) {
        // Category filter
        bool matchesCategory = _selectedCategory == null ||
            course.tags.contains(_selectedCategory);

        // Level filter
        bool matchesLevel = _selectedLevel == null ||
            course.level == _selectedLevel;

        // Duration filter
        bool matchesDuration = _selectedDuration == null ||
            course.duration == _selectedDuration;

        // Search query filter
        bool matchesSearch = _searchQuery.isEmpty ||
            course.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            course.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            course.instructor.toLowerCase().contains(_searchQuery.toLowerCase());

        return matchesCategory && matchesLevel && matchesDuration && matchesSearch;
      }).toList();
    });
  }

  // Clear all filters
  void _clearFilters() {
    setState(() {
      _selectedCategory = null;
      _selectedLevel = null;
      _selectedDuration = null;
      _searchQuery = '';
      _searchController.clear();
      _filteredCourses = List.from(_allCourses);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // _buildHeroSection(),
            _buildSearchBar(),
            FilterSection(
              selectedCategory: _selectedCategory,
              selectedLevel: _selectedLevel,
              selectedDuration: _selectedDuration,
              searchQuery: _searchQuery,
              categories: _categories,
              levels: _levels,
              durations: _durations,
              totalCourses: _allCourses.length,
              filteredCoursesCount: _filteredCourses.length,
              onCategorySelected: (category) {
                setState(() {
                  _selectedCategory = category;
                  _filterCourses();
                });
              },
              onLevelSelected: (level) {
                setState(() {
                  _selectedLevel = level;
                  _filterCourses();
                });
              },
              onDurationSelected: (duration) {
                setState(() {
                  _selectedDuration = duration;
                  _filterCourses();
                });
              },
              onClearFilters: _clearFilters,
              onSearchQueryRemoved: (query) {
                setState(() {
                  _searchQuery = '';
                  _searchController.clear();
                  _filterCourses();
                });
              },
            ),
            _buildCourseGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      color: AppColors.darkBlue,
      width: double.infinity,
      child: Column(
        children: [
          const Text(
            'All Courses',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Explore our wide range of courses',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_filteredCourses.length} courses available',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
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
                _filterCourses();
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
            _filterCourses();
          });
        },
      ),
    );
  }

  // Filter methods and UI have been extracted to separate widget components

  Widget _buildCourseGrid() {
    if (_filteredCourses.isEmpty) {
      return _buildEmptyState();
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            // gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            //   crossAxisCount: 2,
            //   childAspectRatio: 0.50,
            //   crossAxisSpacing: 16,
            //   mainAxisSpacing: 16,
            // ),
            itemCount: _filteredCourses.length,
            itemBuilder: (context, index) => _buildCourseCard(_filteredCourses[index]),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          const Text(
            'No courses found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filter settings',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
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
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
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
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 120,
                      width: double.infinity,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
                    );
                  },
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
              if (course.tags.isNotEmpty)
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      course.tags.first,
                      style: TextStyle(
                        color: AppColors.darkBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
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
                  course.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Instructor: ${course.instructor}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  course.description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      size: 16,
                      color: Colors.amber,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      course.rating.toString(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.people_outline,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${course.studentsCount}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
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
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkBlue,
                    minimumSize: const Size(double.infinity, 36),
                  ),
                  child: const Text('Enroll Now',style: TextStyle(color: Colors.white),),
                ),
              ],
            ),
          ),
        ],
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
          Icon(
            icon,
            size: 12,
            color: Colors.grey[700],
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}
