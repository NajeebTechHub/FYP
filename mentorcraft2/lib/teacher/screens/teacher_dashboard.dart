import 'package:flutter/material.dart';
import 'package:mentorcraft2/student/screens/discussion_forum/forum_screen.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mentorcraft2/teacher/provider/teacher_provider.dart';
import '../../theme/color.dart';
import '../widgets/stat_card.dart';
import '../widgets/earnings_chart.dart';
import '../widgets/recent_activity_card.dart';

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({Key? key}) : super(key: key);

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  int totalQuizzes = 0;
  int totalSubmissions = 0;
  bool isQuizStatsLoaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = Provider.of<TeacherProvider>(context, listen: false);
      if (!provider.isInitialized) await provider.initializeData();
      if (!provider.isStatsLoaded) await provider.fetchCourseStats();
      await _fetchQuizStats(provider.teacherId);
      provider.fetchRealEarningsForChart();
    });
  }

  Future<void> _fetchQuizStats(String teacherId) async {
    try {
      final quizSnapshot = await FirebaseFirestore.instance
          .collection('quizzes')
          .where('teacherId', isEqualTo: teacherId)
          .get();

      final quizzes = quizSnapshot.docs;
      int submissionCount = 0;

      for (var quiz in quizzes) {
        final submissions = await FirebaseFirestore.instance
            .collection('quizzes')
            .doc(quiz.id)
            .collection('submissions')
            .get();
        submissionCount += submissions.size;
      }

      if (mounted) {
        setState(() {
          totalQuizzes = quizzes.length;
          totalSubmissions = submissionCount;
          isQuizStatsLoaded = true;
        });
      }
    } catch (_) {}
  }

  String getSupabaseImageUrl(String uid) {
    return 'https://tqzoozpckrmmprwnhweg.supabase.co/storage/v1/object/public/profile-images/public/$uid.jpg';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBackground : Colors.grey[50];

    return Scaffold(
      backgroundColor: bgColor,
      body: Consumer<TeacherProvider>(
        builder: (context, provider, child) {
          if (!provider.isStatsLoaded || !isQuizStatsLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          final stats = provider.dashboardStats;
          final teacherName = provider.teacherName.isNotEmpty ? provider.teacherName : 'Instructor';
          final uid = provider.teacherId;
          final avatarUrl = uid.isNotEmpty ? getSupabaseImageUrl(uid) : 'https://via.placeholder.com/150';

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    ClipOval(
                      child: Image.network(
                        avatarUrl,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const CircleAvatar(
                          radius: 30,
                          backgroundImage: AssetImage('assets/placeholder.jpg'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Welcome back,\nMr. $teacherName!',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1,
                children: [
                  StatCard(title: 'Total Quizzes', value: totalQuizzes.toString(), subtitle: '$totalSubmissions Submissions', icon: Icons.quiz, color: Colors.indigo),
                  StatCard(title: 'Total Courses', value: stats.totalCourses.toString(), subtitle: '${stats.publishedCourses} Published', icon: Icons.book, color: Colors.blue),
                  StatCard(title: 'Total Students', value: stats.totalStudents.toString(), subtitle: '${stats.activeStudents} Active', icon: Icons.people, color: Colors.green),
                  StatCard(title: 'Avg Rating', value: stats.averageRating.toStringAsFixed(1), subtitle: '${stats.totalReviews} Reviews', icon: Icons.star, color: Colors.purple),
                ],
              ),
              const SizedBox(height: 24),
              _buildCard(
                title: 'Monthly Earnings',
                child: SizedBox(
                  height: 200,
                  child: EarningsChart(monthlyEarnings: provider.monthlyEarningsList),
                ),
              ),
              const SizedBox(height: 24),
              _buildCard(title: 'Top Performing Courses', child: _buildTopCourses(uid)),
              const SizedBox(height: 24),
              _buildCard(
                title: 'Recent Activity',
                trailing: TextButton(onPressed: () {}, child: const Text('View All')),
                child: Column(
                  children: provider.announcements.take(3).map((a) => RecentActivityCard(announcement: a)).toList(),
                ),
              ),
              const SizedBox(height: 24),
              _buildCard(
                title: 'Latest Discussions',
                trailing: TextButton(
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => ForumsScreen())),
                  child: const Text('View All'),
                ),
                child: _buildDiscussions(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTopCourses(String uid) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('courses')
          .where('teacherId', isEqualTo: uid)
          .where('isPublished', isEqualTo: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Text('No courses found.');
        }

        final courses = snapshot.data!.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final enrolled = (data['enrolledStudents'] ?? 0) as int;
          final rating = (data['rating'] ?? 0).toDouble();
          final totalRating = (data['totalRating'] ?? 0) as int;
          final price = (data['price'] ?? 0).toDouble();
          final revenue = enrolled * price;

          return {
            'courseName': data['title'] ?? 'Untitled',
            'enrollments': enrolled,
            'revenue': revenue,
            'rating': totalRating > 0 ? rating : 0.0,
          };
        }).toList();

        courses.sort((a, b) => b['revenue'].compareTo(a['revenue']));
        final topCourses = courses.take(3).toList();

        return Column(
          children: topCourses.map((course) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.book, color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(course['courseName'], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                        Text(
                          '${course['enrollments']} students • \$${course['revenue'].toStringAsFixed(0)}',
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(course['rating'].toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildDiscussions() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('discussions')
          .orderBy('timestamp', descending: true)
          .limit(5)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Text('No discussions found.');
        }

        final posts = snapshot.data!.docs;

        return Column(
          children: posts.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final likeCount = (data['likes'] as Map?)?.length ?? 0;

            return ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(data['title'] ?? 'No title', style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(
                '${data['author'] ?? 'Unknown'} • ${data['category'] ?? ''}',
                style: TextStyle(color: Colors.grey[600]),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.thumb_up, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text('$likeCount'),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildCard({required String title, Widget? trailing, required Widget child}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.cardDark : Colors.white;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark
            ? []
            : [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
