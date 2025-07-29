import 'package:flutter/material.dart';
import 'package:mentorcraft2/student/student_main_app.dart';
import 'package:mentorcraft2/teacher/screens/settings_screen.dart';
import 'package:provider/provider.dart';
import 'package:mentorcraft2/teacher/provider/teacher_provider.dart';
import '../../screens/settings_screen.dart';
import '../../theme/color.dart';
import 'teacher_dashboard.dart';
import 'course_management_screen.dart';
import 'quiz_management_screen.dart';
import 'student_progress_screen.dart';
import 'package:mentorcraft2/teacher/screens/announcement_screen.dart';

class TeacherMainScreen extends StatefulWidget {
  final int initialIndex;
  const TeacherMainScreen({super.key, this.initialIndex = 0});

  @override
  State<TeacherMainScreen> createState() => _TeacherMainScreenState();
}

class _TeacherMainScreenState extends State<TeacherMainScreen> with SingleTickerProviderStateMixin{
  // int _currentIndex = 0;
  late int _selectedIndex;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoggedIn = true; // Simulation for auth state


  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  // Screen titles
  static const List<String> _screenTitles = [
    'Dashboard',
    'Course Management',
    'Quiz Management',
    'Students Progress',
    'Announcements'
  ];

  // Screen widgets

  final List<Widget> _screens = [
    const TeacherDashboard(),
    const CourseManagementScreen(),
    const QuizManagementScreen(),
    const StudentProgressScreen(),
    const AnnouncementsScreen(),
  ];

  final List<BottomNavigationBarItem> _navItems = [
    const BottomNavigationBarItem(
      icon: Icon(Icons.dashboard),
      label: 'Dashboard',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.book),
      label: 'Courses',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.quiz),
      label: 'Quizzes',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.people),
      label: 'Students',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.campaign),
      label: 'Announcements',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TeacherProvider()),
      ],
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          title: Text(_screenTitles[_selectedIndex]),
          centerTitle: true,
          actions: [
            IconButton(onPressed: (){
              Navigator.of(context).push(MaterialPageRoute(builder: (context){
                return SettingsScreen();
              }));
            }, icon: Icon(Icons.settings)),
            IconButton(onPressed: (){
              Navigator.of(context).push(MaterialPageRoute(builder: (context){
                return StudentMainScreen();
              }));
            }, icon: Icon(Icons.settings)),
          ],
        ),
        body: _screens[_selectedIndex],
        // drawer: const TeacherDrawer(),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: Colors.grey,
          backgroundColor: Colors.white,
          elevation: 8,
          items: _navItems,
        ),
      ),
    );
  }
}