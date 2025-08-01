import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mentorcraft2/student/screens/courses.dart';
import 'package:mentorcraft2/student/screens/home.dart';
import 'package:mentorcraft2/student/screens/my_courses_screen.dart';
import 'package:mentorcraft2/student/screens/profile_screen.dart';
import 'package:mentorcraft2/student/widgets/main_widgets/app_drawer.dart';
import 'package:mentorcraft2/teacher/screens/teacher_main_screen.dart';
import '../theme/color.dart';

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
  bool _isLoggedIn = true;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;

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
        backgroundColor: AppColors.primary,
        title: Text(_screenTitles[_selectedIndex],style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
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
          IconButton(
            icon: Icon(Icons.switch_account),
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => TeacherMainScreen()),
              );
            },
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