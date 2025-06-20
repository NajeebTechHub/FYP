import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/learning_activity.dart';
import 'package:mentorcraft2/theme/color.dart';

class LearningHistoryScreen extends StatefulWidget {
  const LearningHistoryScreen({Key? key}) : super(key: key);

  @override
  State<LearningHistoryScreen> createState() => _LearningHistoryScreenState();
}

class _LearningHistoryScreenState extends State<LearningHistoryScreen>
    with SingleTickerProviderStateMixin {
  late List<LearningActivity> _activities;
  late List<LearningActivity> _filteredActivities;
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedTimeRange = 'All Time';
  ActivityType? _selectedActivityType;
  String? _selectedCourse;
  late AnimationController _animationController;

  final List<String> _timeRanges = [
    'Today',
    'This Week',
    'This Month',
    'All Time',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _loadActivities();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadActivities() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Get sample data
    _activities = LearningActivity.getSampleActivities();
    _filteredActivities = List.from(_activities);

    setState(() {
      _isLoading = false;
    });

    _animationController.forward();
  }

  void _filterActivities() {
    setState(() {
      _filteredActivities = _activities.where((activity) {
        // Filter by search query
        final matchesSearch = activity.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            activity.courseName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (activity.moduleName?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);

        // Filter by activity type
        final matchesType = _selectedActivityType == null || activity.activityType == _selectedActivityType;

        // Filter by course
        final matchesCourse = _selectedCourse == null || activity.courseName == _selectedCourse;

        // Filter by time range
        bool matchesTimeRange;
        final now = DateTime.now();
        switch (_selectedTimeRange) {
          case 'Today':
            matchesTimeRange = activity.timestamp.isAfter(
              DateTime(now.year, now.month, now.day),
            );
            break;
          case 'This Week':
            matchesTimeRange = activity.timestamp.isAfter(
              now.subtract(Duration(days: now.weekday - 1)),
            );
            break;
          case 'This Month':
            matchesTimeRange = activity.timestamp.isAfter(
              DateTime(now.year, now.month, 1),
            );
            break;
          case 'All Time':
          default:
            matchesTimeRange = true;
            break;
        }

        return matchesSearch && matchesType && matchesCourse && matchesTimeRange;
      }).toList();
    });
  }

  List<String> _getUniqueCourses() {
    final courses = _activities.map((activity) => activity.courseName).toSet().toList();
    courses.sort();
    return courses;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Learning History',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.darkBlue,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Export History',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Export feature coming soon!'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading ? _buildLoadingView() : _buildContentView(),
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildContentView() {
    if (_filteredActivities.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        _buildSearchAndFilters(),
        _buildTotalLearningTime(),
        Expanded(
          child: _buildLearningTimeline(),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilters() {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar
            TextField(
              decoration: InputDecoration(
                hintText: 'Search history...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.withOpacity(0.1),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (value) {
                _searchQuery = value;
                _filterActivities();
              },
            ),
            const SizedBox(height: 16),

            // Filter section
            Row(
              children: [
                const Text(
                  'Filters:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 8),
                // Time range dropdown
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.darkBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedTimeRange,
                        icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                        isDense: true,
                        style: const TextStyle(
                          color: AppColors.darkBlue,
                          fontSize: 14,
                        ),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedTimeRange = newValue;
                            });
                            _filterActivities();
                          }
                        },
                        items: _timeRanges.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Course filter
            Row(
              children: [
                const Text(
                  'Course:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.darkBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String?>(
                        value: _selectedCourse,
                        hint: const Text('All Courses'),
                        icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                        isDense: true,
                        isExpanded: true,
                        style: const TextStyle(
                          color: AppColors.darkBlue,
                          fontSize: 14,
                        ),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedCourse = newValue;
                          });
                          _filterActivities();
                        },
                        items: [
                          const DropdownMenuItem<String?>(
                            value: null,
                            child: Text('All Courses'),
                          ),
                          ..._getUniqueCourses().map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Activity Type filter (as chips)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All', null),
                  SizedBox(width: 5,),
                  _buildFilterChip('Videos', ActivityType.watchedVideo),
                  SizedBox(width: 5,),
                  _buildFilterChip('Quizzes', ActivityType.completedQuiz),
                  SizedBox(width: 5,),
                  _buildFilterChip('Assignments', ActivityType.submittedAssignment),
                  SizedBox(width: 5,),
                  _buildFilterChip('Certificates', ActivityType.earnedCertificate),
                  SizedBox(width: 5,),
                  _buildFilterChip('Modules', ActivityType.completedModule),
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, ActivityType? type) {
    final isSelected = _selectedActivityType == type;

    return FilterChip(
      selected: isSelected,
      label: Text(label),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.textPrimary,
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      selectedColor: AppColors.primary,
      backgroundColor: Colors.grey.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      onSelected: (selected) {
        setState(() {
          _selectedActivityType = selected ? type : null;
        });
        _filterActivities();
      },
    );
  }

  Widget _buildTotalLearningTime() {
    // Calculate total learning time from filtered activities
    final totalMinutes = _filteredActivities
        .map((a) => a.durationMinutes ?? 0)
        .fold<int>(0, (prev, curr) => prev + curr);

    // Format time as hours and minutes
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    final timeText = hours > 0
        ? '$hours hr${hours > 1 ? 's' : ''} $minutes min${minutes > 1 ? 's' : ''}'
        : '$minutes min${minutes > 1 ? 's' : ''}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        children: [
          const Icon(
            Icons.timer,
            color: AppColors.primary,
            size: 20,
          ),
          const SizedBox(width: 8),
          RichText(
            text: TextSpan(
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 14,
              ),
              children: [
                const TextSpan(
                  text: 'Total Learning Time: ',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                TextSpan(
                  text: timeText,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkBlue,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLearningTimeline() {
    // Group activities by date for easier presentation
    final groupedActivities = <DateTime, List<LearningActivity>>{};
    for (final activity in _filteredActivities) {
      final date = DateTime(
        activity.timestamp.year,
        activity.timestamp.month,
        activity.timestamp.day,
      );

      if (!groupedActivities.containsKey(date)) {
        groupedActivities[date] = [];
      }

      groupedActivities[date]!.add(activity);
    }

    // Sort dates in descending order
    final sortedDates = groupedActivities.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: sortedDates.length,
      itemBuilder: (context, dateIndex) {
        final date = sortedDates[dateIndex];
        final dateActivities = groupedActivities[date]!;

        // Sort activities for this date in descending order
        dateActivities.sort((a, b) => b.timestamp.compareTo(a.timestamp));

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDateHeader(date),
            ...dateActivities.asMap().entries.map((entry) {
              final index = entry.key;
              final activity = entry.value;

              return AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  final delay = index * 0.05;
                  final start = delay;
                  final end = start + 0.4;

                  final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
                    CurvedAnimation(
                      parent: _animationController,
                      curve: Interval(start, end, curve: Curves.easeOut),
                    ),
                  );

                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.1, 0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: _buildTimelineItem(activity),
              );
            }).toList(),
          ],
        );
      },
    );
  }

  Widget _buildDateHeader(DateTime date) {
    final now = DateTime.now();
    final yesterday = DateTime(now.year, now.month, now.day - 1);

    String dateText;
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      dateText = 'Today';
    } else if (date.year == yesterday.year && date.month == yesterday.month && date.day == yesterday.day) {
      dateText = 'Yesterday';
    } else {
      final dateFormat = DateFormat('EEEE, MMMM d, y');
      dateText = dateFormat.format(date);
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.darkBlue,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              dateText,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Divider(
              color: Colors.grey.withOpacity(0.3),
              thickness: 1,
              indent: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(LearningActivity activity) {
    final timeFormat = DateFormat('h:mm a');
    final formattedTime = timeFormat.format(activity.timestamp);

    return InkWell(
      onTap: () => _showActivityDetailsDialog(activity),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left: Time column
            SizedBox(
              width: 70,
              child: Text(
                formattedTime,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            // Center: Timeline line and dot
            Container(
              width: 30,
              height: 95,
              alignment: Alignment.topCenter,
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  // Vertical line
                  Container(
                    width: 1.5,
                    height: 95,
                    color: Colors.grey.withOpacity(0.3),
                  ),
                  // Icon circle
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: activity.getActivityColor().withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: activity.getActivityColor(),
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      activity.getActivityIcon(),
                      color: activity.getActivityColor(),
                      size: 16,
                    ),
                  ),
                ],
              ),
            ),

            // Right: Activity content
            Expanded(
              child: Card(
                elevation: 0,
                color: Colors.grey.withOpacity(0.05),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity.getActivitySummary(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        activity.courseName,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 13,
                        ),
                      ),
                      if (activity.moduleName != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Module: ${activity.moduleName}',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 14,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Tap for details',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade400,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showActivityDetailsDialog(LearningActivity activity) {
    final dateFormat = DateFormat('MMMM d, y • h:mm a');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: activity.getActivityColor().withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                activity.getActivityIcon(),
                color: activity.getActivityColor(),
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                activity.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Course: ${activity.courseName}',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 15,
              ),
            ),
            if (activity.moduleName != null) ...[
              const SizedBox(height: 4),
              Text(
                'Module: ${activity.moduleName}',
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              activity.description,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            if (activity.durationMinutes != null) ...[
              Row(
                children: [
                  const Icon(Icons.timer, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Text(
                    'Duration: ${activity.durationMinutes} minutes',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            if (activity.score != null) ...[
              Row(
                children: [
                  const Icon(Icons.score, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Text(
                    'Score: ${(activity.score! * 100).toInt()}%',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Text(
                  dateFormat.format(activity.timestamp),
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              // This would navigate to the course/module in a real app
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Navigating to content'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            icon: const Icon(Icons.visibility),
            label: const Text('View Content'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history_edu,
              size: 120,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 24),
            const Text(
              'No Learning History Found',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty || _selectedActivityType != null || _selectedCourse != null
                  ? 'No activities match your current filters. Try adjusting your search criteria.'
                  : 'You haven\'t started learning yet. Dive into your first course and track your progress here!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            if (_searchQuery.isNotEmpty || _selectedActivityType != null || _selectedCourse != null)
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _searchQuery = '';
                    _selectedActivityType = null;
                    _selectedCourse = null;
                    _selectedTimeRange = 'All Time';
                  });
                  _filterActivities();
                },
                icon: const Icon(Icons.clear),
                label: const Text('Clear Filters'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              )
            else
              ElevatedButton.icon(
                onPressed: () {
                  // Navigate to courses
                  Navigator.pushNamed(context, '/courses');
                },
                icon: const Icon(Icons.school),
                label: const Text('Browse Courses'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}