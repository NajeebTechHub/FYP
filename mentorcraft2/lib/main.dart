import 'package:flutter/material.dart';
import 'package:mentorcraft2/teacher/screens/teacher_main_screen.dart';
import 'package:provider/provider.dart';
import 'package:mentorcraft2/core/provider/auth_provider.dart';
import 'core/utils/app_router.dart';
import 'package:mentorcraft2/teacher/provider/teacher_provider.dart';
import 'theme/color.dart';

void main() {
  runApp(const MentorCraftApp());
}

class MentorCraftApp extends StatelessWidget {
  const MentorCraftApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TeacherProvider()),
      ],
      child: MaterialApp(
        title: 'MentorCraft',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          // primarySwatch: AppColors.primary,
          primaryColor: AppColors.primary,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          appBarTheme: AppBarTheme(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            titleTextStyle: TextStyle(fontWeight: FontWeight.bold,fontSize: 22),
            elevation: 0,
            centerTitle: true,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.primary),
            ),
          ),
        ),
        home: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            return AppRouter.getHomeScreen(authProvider.currentUser);
          },
      ),
      ),
    );
  }
}

