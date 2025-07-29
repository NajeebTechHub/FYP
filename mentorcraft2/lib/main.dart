import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mentorcraft2/app_wrapper.dart';
import 'package:mentorcraft2/core/models/user_role.dart';
import 'package:mentorcraft2/core/provider/theme_provider.dart';
import 'package:mentorcraft2/student/student_main_app.dart';
import 'package:mentorcraft2/teacher/provider/teacher_provider.dart';
import 'package:mentorcraft2/teacher/screens/teacher_main_screen.dart';
import 'package:mentorcraft2/theme/apptheme.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth/simple_auth_provider.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/auth/login_screen.dart';
import 'theme/color.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Supabase.initialize(
    url: 'https://tqzoozpckrmmprwnhweg.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRxem9venBja3JtbXByd25od2VnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTA1MzExMDEsImV4cCI6MjA2NjEwNzEwMX0.rVPjTgiudqR9O-_flvgkrjtvwB1JqbaEro8ny_4JYcQ',
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
      darkTheme: AppTheme.darkTheme,
      theme: AppTheme.lightTheme,
      home: const AuthenticationWrapper(),
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({super.key});

  Future<UserRole> getSavedRole() async {
    final prefs = await SharedPreferences.getInstance();
    final roleStr = prefs.getString('selectedRole') ?? 'student';
    return UserRole.values.firstWhere(
          (r) => r.name == roleStr,
      orElse: () => UserRole.student,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SimpleAuthProvider>(
      builder: (context, authProvider, child) {
        if (!authProvider.isInitialized || authProvider.isLoading) {
          return const LoadingScreen();
        }

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
                return FutureBuilder<UserRole>(
                  future: getSavedRole(),
                  builder: (context, roleSnapshot) {
                    if (!roleSnapshot.hasData) {
                      print(roleSnapshot.data!);

                      return const LoadingScreen();
                    }
                    print(roleSnapshot.data!);

                    return LoginScreen(selectedRole: roleSnapshot.data!);
                  },
                );
              }
            },
          );
        }

        final user = authProvider.user!;
        return user.role == UserRole.student
            ? const StudentMainScreen()
            : const TeacherMainScreen();
      },
    );
  }
}
