import 'package:flutter/material.dart';
import 'package:mentorcraft2/student/screens/home.dart';
import 'package:mentorcraft2/student/screens/my_courses_screen.dart';
import 'package:mentorcraft2/student/screens/courses.dart';
import 'package:mentorcraft2/student/screens//profile_screen.dart';
import 'package:mentorcraft2/student/widgets/main_widgets/app_drawer.dart';
import '../theme/color.dart';

class StudentMainApp extends StatefulWidget {
  const StudentMainApp({Key? key}) : super(key: key);

  @override
  State<StudentMainApp> createState() => _StudentMainAppState();
}

class _StudentMainAppState extends State<StudentMainApp> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _drawerAnimController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoggedIn = true;

  @override
  void initState() {
    super.initState();
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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(_screenTitles[_selectedIndex]),
        backgroundColor: AppColors.darkBlue,
        foregroundColor: Colors.white,
        elevation: 0,
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
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {
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
        onTap: _onItemTapped,
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