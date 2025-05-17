import 'package:flutter/material.dart';
import 'package:mentorcraft2/screens/courses.dart';
import 'package:mentorcraft2/screens/forum_screen.dart';
import 'package:mentorcraft2/screens/home.dart';
import 'package:mentorcraft2/theme/color.dart';
import 'screens/my_courses_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/quiz_screen.dart';
import 'widgets/app_drawer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MentorCraft',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.darkBlue,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.darkBlue,
          elevation: 0,
          iconTheme: IconThemeData(
            color: Colors.white,
          ),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        drawerTheme: DrawerThemeData(
          backgroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
          ),
        ),
        // Set card theme for consistency
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.symmetric(vertical: 8),
        ),
        // Set icon theme for consistency
        iconTheme: const IconThemeData(
          color: AppColors.darkBlue,
          size: 24,
        ),
      ),
      home: const MainScreen(),
      // Define named routes for navigation
      routes: {
        // Bottom nav routes
        // '/home': (context) => const MainScreen(initialIndex: 0),
        // '/courses': (context) => const MainScreen(initialIndex: 1),
        // '/my-courses': (context) => const MainScreen(initialIndex: 2),
        // '/profile': (context) => const MainScreen(initialIndex: 3),

        // Drawer-only routes
        '/quizzes': (context) => const QuizScreen(),
        '/forums': (context) => const ForumsScreen(),

        // Placeholder routes with snackbar feedback
        '/search': (context) => _buildPlaceholderScreen(context, 'Search'),
        '/payments': (context) => _buildPlaceholderScreen(context, 'Payment History'),
        '/progress': (context) => _buildPlaceholderScreen(context, 'Progress Tracking'),
        '/certificates': (context) => _buildPlaceholderScreen(context, 'Certificates'),
        '/history': (context) => _buildPlaceholderScreen(context, 'Learning History'),
        '/settings': (context) => _buildPlaceholderScreen(context, 'Settings'),
        '/help': (context) => _buildPlaceholderScreen(context, 'Help & Support'),
        '/about': (context) => _buildPlaceholderScreen(context, 'About MentorCraft'),
      },
    );
  }

  // Helper method to quickly build placeholder screens
  Widget _buildPlaceholderScreen(BuildContext context, String title) {
    // Show a snackbar to indicate this is a placeholder
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$title screen coming soon!'),
          duration: const Duration(seconds: 2),
        ),
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              '$title',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.darkBlue,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'This feature is coming soon!',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Go Back'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  final int initialIndex;

  const MainScreen({super.key, this.initialIndex = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {
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
          // Search icon
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Navigation for search
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Search functionality coming soon!'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
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

