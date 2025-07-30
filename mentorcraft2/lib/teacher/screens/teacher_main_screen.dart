import 'package:flutter/material.dart';
import 'package:mentorcraft2/student/student_main_app.dart';
import 'package:mentorcraft2/teacher/provider/teacher_provider.dart';
import 'package:mentorcraft2/theme/color.dart';
import 'package:provider/provider.dart';
import '../../screens/settings_screen.dart';
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

class _TeacherMainScreenState extends State<TeacherMainScreen> {
  late int _selectedIndex;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  static const List<String> _screenTitles = [
    'Dashboard',
    'Course Management',
    'Quiz Management',
    'Students Progress',
    'Announcements'
  ];

  final List<Widget> _screens = [
    TeacherDashboard(),
    CourseManagementScreen(),
    QuizManagementScreen(),
    StudentProgressScreen(),
    AnnouncementsScreen(),
  ];

  final List<BottomNavigationBarItem> _navItems = [
    BottomNavigationBarItem(
      icon: Icon(Icons.dashboard),
      label: 'Dashboard',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.book),
      label: 'Courses',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.quiz),
      label: 'Quizzes',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.people),
      label: 'Students',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.campaign),
      label: 'Announcements',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TeacherProvider()),
      ],
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: AppColors.darkBlue,
          foregroundColor: AppColors.background,
          title: Text(_screenTitles[_selectedIndex]),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => SettingsScreen()),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.switch_account),
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => StudentMainScreen()),
                );
              },
            ),
          ],
        ),

        body: _screens[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: theme.colorScheme.primary,
          unselectedItemColor: theme.unselectedWidgetColor,
          backgroundColor: theme.bottomNavigationBarTheme.backgroundColor ?? theme.scaffoldBackgroundColor,
          elevation: 8,
          items: _navItems,
        ),
      ),
    );
  }
}
