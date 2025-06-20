import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../student/widgets/main_widgets/app_drawer.dart';
import '../../theme/color.dart';
import '../models/user_role.dart';
import 'package:mentorcraft2/core/provider/auth_provider.dart';
import '../../teacher/screens/teacher_main_screen.dart';
import 'package:mentorcraft2/student/screens/home.dart';
import 'package:mentorcraft2/student/screens/courses.dart';
import 'package:mentorcraft2/student/screens/my_courses_screen.dart';
import 'package:mentorcraft2/student/screens/profile_screen.dart';

class AppRouter {
  static Widget getHomeScreen(AppUser? user) {
    if (user == null) {
      return const RoleSelectionScreen();
    }

    switch (user.role) {
      case UserRole.teacher:
        return const TeacherMainScreen();
      case UserRole.student:
        return const StudentMainScreen();
      case UserRole.admin:
        return const TeacherMainScreen(); // Admin uses teacher interface for now
    }
  }
}

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade600,
              Colors.blue.shade800,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo and Title
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.school,
                    size: 50,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'MentorCraft',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Choose your role to continue',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 48),

                // Role Selection Cards
                _buildRoleCard(
                  context,
                  title: 'I\'m a Student',
                  subtitle: 'Learn from expert instructors',
                  icon: Icons.school,
                  color: Colors.green,
                  onTap: () => _selectRole(context, UserRole.student),
                ),
                const SizedBox(height: 16),
                _buildRoleCard(
                  context,
                  title: 'I\'m a Teacher',
                  subtitle: 'Share knowledge and teach students',
                  icon: Icons.person,
                  color: Colors.orange,
                  onTap: () => _selectRole(context, UserRole.teacher),
                ),

                const SizedBox(height: 48),
                Text(
                  'You can switch roles anytime from the menu',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard(
      BuildContext context, {
        required String title,
        required String subtitle,
        required IconData icon,
        required Color color,
        required VoidCallback onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 30,
                color: color,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey[400],
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _selectRole(BuildContext context, UserRole role) {
    final authProvider = context.read<AuthProvider>();

    if (role == UserRole.teacher) {
      authProvider.switchToTeacher();
    } else {
      authProvider.switchToStudent();
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => AppRouter.getHomeScreen(authProvider.currentUser),
      ),
    );
  }
}


class StudentMainScreen extends StatefulWidget {
  final int initialIndex;

  const StudentMainScreen({super.key, this.initialIndex = 0});

  @override
  State<StudentMainScreen> createState() => _StudentMainScreenState();
}

class _StudentMainScreenState extends State<StudentMainScreen> with SingleTickerProviderStateMixin {
  late int _selectedIndex;
  late AnimationController _drawerAnimController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoggedIn = true; // Simulation for auth state

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;

    // Animation controller for drawer icons
    _drawerAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _drawerAnimController.dispose();
    super.dispose();
  }

  // Screen titles
  static const List<String> _screenTitles = [
    'Home',
    'Course Catalog',
    'My Courses',
    'Profile',
  ];

  // Screen widgets
  final List<Widget> _screens = [
    const HomeScreen(),
    const CoursesScreen(),
    const MyCoursesScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(_screenTitles[_selectedIndex]),
        leading: AnimatedBuilder(
          animation: _drawerAnimController,
          builder: (context, child) {
            return IconButton(
              icon: AnimatedIcon(
                icon: AnimatedIcons.menu_arrow,
                progress: _drawerAnimController,
              ),
              onPressed: () {
                if (_scaffoldKey.currentState!.isDrawerOpen) {
                  _scaffoldKey.currentState!.closeDrawer();
                } else {
                  _scaffoldKey.currentState!.openDrawer();
                }
              },
            );
          },
        ),
        actions: [
          // Notifications icon with badge
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {
                  // Navigation for notifications
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Notifications coming soon!'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 12,
                    minHeight: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      drawer: AppDrawer(
        currentIndex: _selectedIndex,
        isLoggedIn: _isLoggedIn,
      ),
      // Listen to drawer open/close to animate the menu icon
      onDrawerChanged: (isOpened) {
        if (isOpened) {
          _drawerAnimController.forward();
        } else {
          _drawerAnimController.reverse();
        }
      },
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: 'My Courses',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        selectedItemColor: AppColors.darkBlue,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}
