import 'package:flutter/material.dart';
import 'package:mentorcraft2/models/app_user.dart';
import 'package:mentorcraft2/core/models/user_role.dart';
import 'package:mentorcraft2/screens/auth/login_screen.dart';
import 'package:mentorcraft2/student/student_main_app.dart';
import 'package:mentorcraft2/teacher/screens/teacher_main_screen.dart';
import 'package:provider/provider.dart';

import '../../auth/simple_auth_provider.dart';

class AppRouter {
  static Widget getHomeScreen(AppUser? user) {
    if (user == null) {
      return const RoleSelectionScreen();
    }

    switch (user.role) {
      case UserRole.teacher:
        return const TeacherMainScreen(); // ✅ correct main screen
      case UserRole.student:
        return const StudentMainScreen(); // ✅ correct main screen
      case UserRole.admin:
        return const TeacherMainScreen(); // ✅ fallback to teacher
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

  void _selectRole(BuildContext context, UserRole role) async {
    final authProvider = Provider.of<SimpleAuthProvider>(context, listen: false);
    await authProvider.saveSelectedRole(role);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => LoginScreen(selectedRole: role),
      ),
    );
  }

}
