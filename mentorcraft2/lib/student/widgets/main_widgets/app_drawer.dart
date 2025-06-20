import 'package:flutter/material.dart';
import 'package:mentorcraft2/student/screens/certificate_screen.dart';
import 'package:mentorcraft2/student/screens/forum_screen.dart';
import 'package:mentorcraft2/student/screens/learning_history_screen.dart';
import 'package:mentorcraft2/student/screens/payment_historu_screen.dart';
import 'package:mentorcraft2/student/screens/progress_tracking_screen.dart';
import 'package:mentorcraft2/student/screens/quiz_screen.dart';
import 'package:mentorcraft2/student/screens/settings_screen.dart';
import 'package:mentorcraft2/theme/color.dart';

class AppDrawer extends StatelessWidget {
  final int currentIndex;
  final bool isLoggedIn;

  const AppDrawer({
    Key? key,
    required this.currentIndex,
    this.isLoggedIn = true, // Default to true for now, can be made dynamic
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      elevation: 2,
      child: SafeArea(
        child: Column(
          children: [
            _buildDrawerHeader(context),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    _buildMainNavSection(context),
                    const Divider(height: 32),
                    _buildLearningSection(context),
                    const Divider(height: 32),
                    _buildSupportSection(context),
                    if (isLoggedIn) ...[
                      const Divider(height: 32),
                      _buildLogoutSection(context),
                    ],
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context) {
    return UserAccountsDrawerHeader(
      accountName: const Text(
        'John Doe',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      accountEmail: const Text(
        'john.doe@example.com',
        style: TextStyle(
          fontSize: 14,
        ),
      ),
      currentAccountPicture: CircleAvatar(
        backgroundColor: Colors.white,
        child: ClipOval(
          child: Container(
            color: AppColors.lightBlue.withOpacity(0.2),
            child: const Icon(
              Icons.person,
              size: 50,
              color: AppColors.darkBlue,
            ),
          ),
        ),
      ),
      decoration: BoxDecoration(
        color: AppColors.darkBlue,
        image: DecorationImage(
          image: const AssetImage('assets/images/image_1742380932561.png'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            AppColors.darkBlue.withOpacity(0.85),
            BlendMode.srcOver,
          ),
        ),
      ),
      otherAccountsPictures: [
        CircleAvatar(
          backgroundColor: Colors.white70,
          child: IconButton(
            icon: const Icon(
              Icons.edit,
              color: AppColors.darkBlue,
              size: 18,
            ),
            onPressed: () {
              Navigator.pop(context);
              // Navigate to profile edit screen
              Navigator.pushNamed(context, '/profile');
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMainNavSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 16, bottom: 8),
          child: Text(
            'MAIN',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
        // _buildDrawerItem(
        //   context,
        //   Icons.home_outlined,
        //   'Home',
        //   '/home',
        //   isSelected: currentIndex == 0,
        // ),
        // _buildDrawerItem(
        //   context,
        //   Icons.school_outlined,
        //   'Course Catalog',
        //   '/courses',
        //   isSelected: currentIndex == 1,
        // ),
        // _buildDrawerItem(
        //   context,
        //   Icons.bookmark_outline,
        //   'My Courses',
        //   '/my-courses',
        //   isSelected: currentIndex == 2,
        // ),
        // _buildDrawerItem(
        //   context,
        //   Icons.person_outline,
        //   'Profile',
        //   '/profile',
        //   isSelected: currentIndex == 3,
        // ),
        _buildDrawerItem(
          context,
          Icons.search,
          'Search Courses',
          '/search',
        ),
        _buildDrawerItem(
          context,
          Icons.credit_card_outlined,
          'Payment History',
          '/payments',
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => PaymentHistoryScreen()));
            }
        ),
      ],
    );
  }

  Widget _buildLearningSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 16, bottom: 8),
          child: Text(
            'LEARNING',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
        _buildDrawerItem(
          context,
          Icons.quiz_outlined,
          'Quizzes & Assessments',
          '/quizzes',
          onTap: (){
            Navigator.push(context, MaterialPageRoute(builder: (context) => QuizScreen()));
          }
        ),
        _buildDrawerItem(
          context,
          Icons.forum_outlined,
          'Discussion Forums',
          '/forums',
          badge: 3,
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => ForumsScreen()));
            }
        ),
        _buildDrawerItem(
          context,
          Icons.bar_chart_outlined,
          'Progress Tracking',
          '/progress',
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => ProgressTrackingScreen()));
            }
        ),
        _buildDrawerItem(
          context,
          Icons.workspace_premium_outlined,
          'Certificates',
          '/certificates',
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => CertificatesScreen()));
            }
        ),
        _buildDrawerItem(
          context,
          Icons.history_outlined,
          'Learning History',
          '/history',
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => LearningHistoryScreen()));
            }
        ),
      ],
    );
  }

  Widget _buildSupportSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 16, bottom: 8),
          child: Text(
            'SUPPORT',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
        _buildDrawerItem(
          context,
          Icons.settings_outlined,
          'Settings',
          '/settings',
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsScreen()));
            }
        ),
        _buildDrawerItem(
          context,
          Icons.help_outline,
          'Help & Support',
          '/help',
        ),
        _buildDrawerItem(
          context,
          Icons.info_outline,
          'About MentorCraft',
          '/about',
        ),
      ],
    );
  }

  Widget _buildLogoutSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDrawerItem(
          context,
          Icons.logout,
          'Logout',
          '/logout',
          textColor: AppColors.accent,
          onTap: () {
            // Show confirmation dialog
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Logout'),
                content: const Text('Are you sure you want to logout?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('CANCEL'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Close dialog
                      Navigator.pop(context); // Close drawer
                      // Handle logout
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Logged out successfully'),
                        ),
                      );
                    },
                    child: const Text('LOGOUT'),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDrawerItem(
      BuildContext context,
      IconData icon,
      String title,
      String route, {
        bool isSelected = false,
        Color? textColor,
        int? badge,
        VoidCallback? onTap,
      }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
        size: 24,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: textColor ?? (isSelected ? AppColors.primary : AppColors.textPrimary),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: badge != null
          ? Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppColors.accent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          badge.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      )
          : null,
      onTap: onTap ??
              () {
            Navigator.pop(context); // Close the drawer first

            // Handle navigation based on route
            // This would be replaced with your app's navigation system
            switch (route) {
              case '/home':
                if (currentIndex != 0) {
                  Navigator.pushNamed(context, route);
                }
                break;
              case '/courses':
                if (currentIndex != 1) {
                  Navigator.pushNamed(context, route);
                }
                break;
              case '/my-courses':
                if (currentIndex != 2) {
                  Navigator.pushNamed(context, route);
                }
                break;
              case '/profile':
                if (currentIndex != 3) {
                  Navigator.pushNamed(context, route);
                }
                break;
              default:
              // For screens not in the bottom nav
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Navigating to $title'),
                    duration: const Duration(seconds: 1),
                  ),
                );
                break;
            }
          },
      selected: isSelected,
      selectedTileColor: AppColors.primary.withOpacity(0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      // Add subtle hover effect
      hoverColor: AppColors.primary.withOpacity(0.04),
    );
  }
}