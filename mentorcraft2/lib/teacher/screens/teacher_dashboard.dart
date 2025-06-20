import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:mentorcraft2/teacher/provider/teacher_provider.dart';
import '../models/teacher_announcement.dart';
import '../../theme/color.dart';
import '../widgets/stat_card.dart';
import '../widgets/earnings_chart.dart';
import '../widgets/recent_activity_card.dart';

class TeacherDashboard extends StatelessWidget {
  const TeacherDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],

      body: Consumer<TeacherProvider>(
        builder: (context, teacherProvider, child) {
          final stats = teacherProvider.dashboardStats;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Section
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
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: AssetImage(teacherProvider.teacherAvatar),
                        backgroundColor: Colors.white,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome back, ${teacherProvider.teacherName}!',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'You have ${stats.pendingSubmissions} pending quiz submissions',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Stats Cards
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1,
                  children: [
                    StatCard(
                      title: 'Total Courses',
                      value: stats.totalCourses.toString(),
                      subtitle: '${stats.publishedCourses} published',
                      icon: Icons.book,
                      color: Colors.blue,
                    ),
                    StatCard(
                      title: 'Total Students',
                      value: stats.totalStudents.toString(),
                      subtitle: '${stats.activeStudents} active',
                      icon: Icons.people,
                      color: Colors.green,
                    ),
                    StatCard(
                      title: 'Monthly Revenue',
                      value: '\$${stats.monthlyRevenue.toStringAsFixed(0)}',
                      subtitle: 'This month',
                      icon: Icons.attach_money,
                      color: Colors.orange,
                    ),
                    StatCard(
                      title: 'Avg Rating',
                      value: stats.averageRating.toStringAsFixed(1),
                      subtitle: '${stats.totalReviews} reviews',
                      icon: Icons.star,
                      color: Colors.purple,
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Earnings Chart
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
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
                      const Text(
                        'Monthly Earnings',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 200,
                        child: EarningsChart(monthlyEarnings: stats.monthlyEarnings),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Top Courses
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
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
                      const Text(
                        'Top Performing Courses',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...stats.topCourses.map((course) => Padding(
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
                              child: Icon(
                                Icons.book,
                                color: AppColors.primary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    course.courseName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    '${course.enrollments} students • \$${course.revenue.toStringAsFixed(0)}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  course.rating.toStringAsFixed(1),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )).toList(),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Recent Activity
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
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
                          const Text(
                            'Recent Activity',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              // Navigate to full activity list
                            },
                            child: const Text('View All'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ...teacherProvider.announcements.take(3).map((announcement) =>
                          RecentActivityCard(announcement: announcement)
                      ).toList(),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}