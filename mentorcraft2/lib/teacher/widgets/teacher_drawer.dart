import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mentorcraft2/core/provider/auth_provider.dart';
import 'package:mentorcraft2/teacher/provider/teacher_provider.dart';
import '../../auth/auth_provider.dart';
import '../../theme/color.dart';

class TeacherDrawer extends StatelessWidget {
  const TeacherDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Consumer2<AuthProvider, TeacherProvider>(
        builder: (context, authProvider, teacherProvider, child) {
          final user = authProvider.user;
          final stats = teacherProvider.dashboardStats;

          return Column(
            children: [
              // Header Section
              Container(
                padding: const EdgeInsets.fromLTRB(16, 50, 16, 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 35,
                      // backgroundImage: AssetImage(user?.avatar ?? 'assets/default_avatar.png'),
                      backgroundColor: Colors.white,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      user?.displayName ?? 'Teacher',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      user?.email ?? '',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Teacher Account',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Quick Stats
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.grey[50],
                child: Row(
                  children: [
                    Expanded(
                      child: _buildQuickStat(
                        'Courses',
                        stats.totalCourses.toString(),
                        Icons.book,
                        Colors.blue,
                      ),
                    ),
                    Expanded(
                      child: _buildQuickStat(
                        'Students',
                        stats.totalStudents.toString(),
                        Icons.people,
                        Colors.green,
                      ),
                    ),
                    Expanded(
                      child: _buildQuickStat(
                        'Rating',
                        stats.averageRating.toStringAsFixed(1),
                        Icons.star,
                        Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),

              // Menu Items
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _buildDrawerItem(
                      icon: Icons.person,
                      title: 'Profile',
                      onTap: () {
                        Navigator.pop(context);
                        // Navigate to teacher profile
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.analytics,
                      title: 'Analytics',
                      onTap: () {
                        Navigator.pop(context);
                        // Navigate to detailed analytics
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.payment,
                      title: 'Earnings',
                      onTap: () {
                        Navigator.pop(context);
                        // Navigate to earnings page
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.schedule,
                      title: 'Schedule',
                      onTap: () {
                        Navigator.pop(context);
                        // Navigate to schedule
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.message,
                      title: 'Messages',
                      onTap: () {
                        Navigator.pop(context);
                        // Navigate to messages
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.help,
                      title: 'Help & Support',
                      onTap: () {
                        Navigator.pop(context);
                        // Navigate to help
                      },
                    ),
                    const Divider(),
                    _buildDrawerItem(
                      icon: Icons.settings,
                      title: 'Settings',
                      onTap: () {
                        Navigator.pop(context);
                        // Navigate to settings
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.swap_horiz,
                      title: 'Switch to Student View',
                      onTap: () {
                        Navigator.pop(context);
                        // authProvider.switchToStudent();
                        // Navigate to student interface
                        Navigator.pushReplacementNamed(context, '/student');
                      },
                    ),
                    _buildDrawerItem(
                      icon: Icons.logout,
                      title: 'Logout',
                      textColor: Colors.red,
                      onTap: () {
                        Navigator.pop(context);
                        _showLogoutDialog(context, authProvider);
                      },
                    ),
                  ],
                ),
              ),

              // Footer
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      'MentorCraft Teacher Portal',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      'Version 1.0.0',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildQuickStat(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: textColor ?? Colors.grey[700],
      ),
      title: Text(
        title,
        style: TextStyle(
          color: textColor ?? Colors.grey[800],
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      dense: true,
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                authProvider.signOut();
                Navigator.of(context).pop();
                Navigator.pushReplacementNamed(context, '/login');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}