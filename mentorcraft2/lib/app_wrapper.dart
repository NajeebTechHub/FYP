import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'auth/auth_provider.dart';
import 'auth/simple_auth_provider.dart';
import 'core/models/user_role.dart';
import 'models/app_user.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'student/student_main_app.dart';
import 'teacher/provider/teacher_provider.dart';
import 'teacher/screens/teacher_main_screen.dart';
import 'theme/color.dart';

class AppWrapper extends StatelessWidget {
  const AppWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: Text('Firebase Init Error: ${snapshot.error}'),
              ),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.done) {
          return MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => SimpleAuthProvider()..restoreSession()),
              ChangeNotifierProvider(create: (_) => AuthProvider()),
              ChangeNotifierProvider(create: (_) => TeacherProvider()),
            ],
            child: const MentorCraftApp(),
          );
        }

        return const MaterialApp(
          home: LoadingScreen(),
        );
      },
    );
  }
}

class MentorCraftApp extends StatelessWidget {
  const MentorCraftApp({super.key});

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
        iconTheme: const IconThemeData(
          color: AppColors.darkBlue,
          size: 24,
        ),
      ),
      home: const AuthenticationWrapper(),
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final simpleAuth = Provider.of<SimpleAuthProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final teacherProvider = Provider.of<TeacherProvider>(context);

    if (!simpleAuth.isInitialized || !authProvider.isInitialized) {
      return const LoadingScreen();
    }

    if (!authProvider.isAuthenticated) {
      return const OnboardingScreen();
    }

    final user = simpleAuth.user;
    if (user == null) return const OnboardingScreen();

    authProvider.setUser(user);
    final role = user.role;

    if (role == UserRole.teacher) {
      if (!teacherProvider.isInitialized) {
        teacherProvider.initializeDataWithUser(user);
        return const LoadingScreen();
      }

      if (teacherProvider.teacherId.isEmpty) {
        return const LoadingScreen();
      }

      return const TeacherMainScreen();
    }

    return const StudentMainScreen();
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
            const CircularProgressIndicator(color: AppColors.primary),
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
