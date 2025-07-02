import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mentorcraft2/core/models/user_role.dart';
import 'package:mentorcraft2/core/provider/theme_privider.dart';
import 'package:mentorcraft2/student/student_main_app.dart';
import 'package:mentorcraft2/teacher/provider/teacher_provider.dart';
import 'package:mentorcraft2/teacher/screens/teacher_main_screen.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth/simple_auth_provider.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/auth/login_screen.dart';
import 'theme/color.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Supabase.initialize(
    url: 'https://tqzoozpckrmmprwnhweg.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRxem9venBja3JtbXByd25od2VnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTA1MzExMDEsImV4cCI6MjA2NjEwNzEwMX0.rVPjTgiudqR9O-_flvgkrjtvwB1JqbaEro8ny_4JYcQ', // 🔁 replace with your Supabase anon key
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SimpleAuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => TeacherProvider())
      ],
      child: const MentorCraftApp(),
    ),
  );
}

class MentorCraftApp extends StatelessWidget {
  const MentorCraftApp({super.key});

  @override
  Widget build(BuildContext context) {

    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'MentorCraft',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      darkTheme: ThemeData(
        scaffoldBackgroundColor: Colors.black26,
        primaryColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.black26,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
              color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        drawerTheme: DrawerThemeData(
          backgroundColor: Colors.black26,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
            backgroundColor: Colors.black26,
            selectedIconTheme: IconThemeData(
                color: Colors.blue
            ),
            unselectedIconTheme: IconThemeData(
                color: Colors.white
            ),
            selectedLabelStyle: TextStyle(color: Colors.blue),
            unselectedLabelStyle: TextStyle(color: Colors.white)
        ),
        cardTheme: const CardThemeData(
          elevation: 2,
          color: Colors.black12,
          margin: EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
      ),
      theme: ThemeData(
        primaryColor: AppColors.darkBlue,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.darkBlue,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
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
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        cardTheme: const CardThemeData(
          elevation: 2,
          margin: EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),


        iconTheme: const IconThemeData(
          color: AppColors.darkBlue,
          size: 24,
        ),
      ),
      home: const TeacherMainScreen(),
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SimpleAuthProvider>(
      builder: (context, authProvider, child) {
        // Show loading screen while initializing
        if (!authProvider.isInitialized || authProvider.isLoading) {
          return const LoadingScreen();
        }

        // If user is not authenticated, handle onboarding and login
        if (!authProvider.isAuthenticated) {
          return FutureBuilder<bool>(
            future: authProvider.checkOnboardingStatus(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const LoadingScreen();
              }

              final onboardingCompleted = snapshot.data ?? false;

              if (!onboardingCompleted) {
                return const OnboardingScreen();
              } else {
                return const LoginScreen(selectedRole: UserRole.student,);
              }
            },
          );
        }

        // User is authenticated, route to appropriate dashboard
        final user = authProvider.user!;

        if (user.role == UserRole.student) {
          return const StudentMainScreen();
        } else {
          return const TeacherMainScreen();
        }
      },
    );
  }
}



class StudentAppDrawer extends StatelessWidget {
  final int currentIndex;
  final Function(int) onNavigate;

  const StudentAppDrawer({
    Key? key,
    required this.currentIndex,
    required this.onNavigate,
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
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildDrawerItem(
                    context,
                    title: 'Home',
                    icon: Icons.home_outlined,
                    index: 0,
                    onTap: () => onNavigate(0),
                  ),
                  _buildDrawerItem(
                    context,
                    title: 'Course Catalog',
                    icon: Icons.school_outlined,
                    index: 1,
                    onTap: () => onNavigate(1),
                  ),
                  _buildDrawerItem(
                    context,
                    title: 'My Courses',
                    icon: Icons.bookmark_outlined,
                    index: 2,
                    onTap: () => onNavigate(2),
                  ),
                  _buildDrawerItem(
                    context,
                    title: 'Profile',
                    icon: Icons.person_outlined,
                    index: 3,
                    onTap: () => onNavigate(3),
                  ),
                  const Divider(),
                  _buildDrawerItem(
                    context,
                    title: 'Progress Tracking',
                    icon: Icons.analytics_outlined,
                    index: 4,
                    onTap: () => _showComingSoon(context, 'Progress Tracking'),
                  ),
                  _buildDrawerItem(
                    context,
                    title: 'Learning History',
                    icon: Icons.history_outlined,
                    index: 5,
                    onTap: () => _showComingSoon(context, 'Learning History'),
                  ),
                  _buildDrawerItem(
                    context,
                    title: 'Forum',
                    icon: Icons.forum_outlined,
                    index: 6,
                    onTap: () => _showComingSoon(context, 'Forum'),
                  ),
                  _buildDrawerItem(
                    context,
                    title: 'Quiz',
                    icon: Icons.quiz_outlined,
                    index: 7,
                    onTap: () => _showComingSoon(context, 'Quiz'),
                  ),
                  const Divider(),
                  _buildDrawerItem(
                    context,
                    title: 'Payment History',
                    icon: Icons.payment_outlined,
                    index: 8,
                    onTap: () => _showComingSoon(context, 'Payment History'),
                  ),
                  _buildDrawerItem(
                    context,
                    title: 'Settings',
                    icon: Icons.settings_outlined,
                    index: 9,
                    onTap: () => _showComingSoon(context, 'Settings'),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.swap_horiz, color: AppColors.primary),
                    title: const Text(
                      'Switch to Teacher Mode',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const TeacherMainScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
            _buildLogoutSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context) {
    return Consumer<SimpleAuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.user;
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary,
                AppColors.primary.withOpacity(0.8),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.person,
                  size: 30,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                user?.displayName ?? 'Student User',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                user?.email ?? 'student@example.com',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDrawerItem(
      BuildContext context, {
        required String title,
        required IconData icon,
        required int index,
        required VoidCallback onTap,
      }) {
    final bool isSelected = currentIndex == index;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isSelected ? AppColors.primary.withOpacity(0.1) : null,
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? AppColors.primary : Colors.grey[600],
          size: 24,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? AppColors.primary : Colors.grey[800],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 16,
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }

  Widget _buildLogoutSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: ListTile(
        leading: const Icon(
          Icons.logout,
          color: Colors.red,
        ),
        title: const Text(
          'Logout',
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.w500,
          ),
        ),
        onTap: () {
          Navigator.pop(context);
          _showLogoutDialog(context);
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature coming soon!'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
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
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Provider.of<SimpleAuthProvider>(context, listen: false).signOut();
              },
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.school,
                size: 64,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'MentorCraft',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            const CircularProgressIndicator(
              color: AppColors.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Loading...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}