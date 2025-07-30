import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mentorcraft2/core/models/user_role.dart';
import 'package:mentorcraft2/screens/help&support.dart';
import 'package:mentorcraft2/student/screens/certificate/certificate_screen.dart';
import 'package:mentorcraft2/student/screens/forum_screen.dart';
import 'package:mentorcraft2/student/screens/learning_history_screen.dart';
import 'package:mentorcraft2/student/screens/payment_history_screen.dart';
import 'package:mentorcraft2/student/screens/progress_tracking_screen.dart';
import 'package:mentorcraft2/student/screens/quiz_screen.dart';
import 'package:mentorcraft2/screens/settings_screen.dart';
import 'package:mentorcraft2/theme/color.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import '../../../auth/simple_auth_provider.dart';
import '../../../screens/about_mentorcraft.dart';
import '../../../screens/auth/login_screen.dart';

class AppDrawer extends StatelessWidget {
  final int currentIndex;
  final bool isLoggedIn;

  const AppDrawer({
    Key? key,
    required this.currentIndex,
    this.isLoggedIn = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBackground : Colors.white;

    return Drawer(
      backgroundColor: bgColor,
      elevation: 2,
      child: SafeArea(
        child: Column(
          children: [
            _buildDrawerHeader(context),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    _buildMainNavSection(context),
                    const Divider(height: 32),
                    _buildLearningSection(context),
                    const Divider(height: 32),
                    _buildSupportSection(context),
                    if (isLoggedIn) ...[
                      const Divider(height: 32),
                      _buildLogoutSection(context),
                    ],
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final String displayName = user?.displayName ?? 'No Name';
    final String email = user?.email ?? 'No Email';
    final String uid = user?.uid ?? '';
    final String imageUrl =
        'https://tqzoozpckrmmprwnhweg.supabase.co/storage/v1/object/public/profile-images/public/$uid.jpg';

    return UserAccountsDrawerHeader(
      accountName: Text(displayName, style: const TextStyle(fontSize: 18)),
      accountEmail: Text(email, style: const TextStyle(fontSize: 14)),
      currentAccountPicture: CircleAvatar(
        backgroundColor: Colors.white,
        child: ClipOval(
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: AppColors.lightBlue.withOpacity(0.2),
                child: const Icon(Icons.person, size: 50, color: AppColors.darkBlue),
              );
            },
          ),
        ),
      ),
      decoration: BoxDecoration(
        color: AppColors.darkBlue,
        image: DecorationImage(
          image: const AssetImage('assets/images/image_1742380932561.png'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            AppColors.darkBlue.withOpacity(0.85),
            BlendMode.srcOver,
          ),
        ),
      ),
    );
  }

  Widget _buildMainNavSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('MAIN'),
        _buildDrawerItem(context, Icons.search, 'Search Courses', '/search'),
        _buildDrawerItem(
          context,
          Icons.credit_card_outlined,
          'Payment History',
          '/payments',
          onTap: () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => PaymentHistoryScreen())),
        ),
      ],
    );
  }

  Widget _buildLearningSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('LEARNING'),
        _buildDrawerItem(
          context,
          Icons.quiz_outlined,
          'Quizzes & Assessments',
          '/quizzes',
          onTap: () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => QuizScreen())),
        ),
        _buildDrawerItem(
          context,
          Icons.forum_outlined,
          'Discussion Forums',
          '/forums',
          onTap: () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => ForumsScreen())),
        ),
        _buildDrawerItem(
          context,
          Icons.bar_chart_outlined,
          'Progress Tracking',
          '/progress',
          onTap: () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => ProgressTrackingScreen())),
        ),
        _buildDrawerItem(
          context,
          Icons.workspace_premium_outlined,
          'Certificates',
          '/certificates',
          onTap: () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => CertificatesScreen())),
        ),
        _buildDrawerItem(
          context,
          Icons.history_outlined,
          'Learning History',
          '/history',
          onTap: () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => LearningHistoryScreen())),
        ),
      ],
    );
  }

  Widget _buildSupportSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('SUPPORT'),
        _buildDrawerItem(context, Icons.settings_outlined, 'Settings', '/settings',
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => SettingsScreen()))),
        _buildDrawerItem(context, Icons.help_outline, 'Help & Support', '/help',
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => HelpAndSupportScreen()))),
        _buildDrawerItem(context, Icons.info_outline, 'About MentorCraft', '/about',
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => AboutMentorCraftScreen()))),
      ],
    );
  }

  Widget _buildLogoutSection(BuildContext context) {
    return _buildDrawerItem(
      context,
      Icons.logout,
      'Logout',
      '/logout',
      textColor: AppColors.accent,
      onTap: () => _confirmLogout(context),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              Navigator.pop(context);

              final authProvider = Provider.of<SimpleAuthProvider>(
                context,
                listen: false,
              );
              await authProvider.signOut();

              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (_) => LoginScreen(selectedRole: UserRole.teacher),
                ),
                    (route) => false,
              );

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Logged out successfully')),
              );
            },
            child: const Text('LOGOUT'),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
      BuildContext context,
      IconData icon,
      String title,
      String route, {
        bool isSelected = false,
        Color? textColor,
        int? badge,
        VoidCallback? onTap,
      }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isSelected ? AppColors.primary : AppColors.textSecondary;
    final titleColor = textColor ?? (isSelected ? AppColors.primary : (isDark ? AppColors.background : AppColors.textPrimary));

    return ListTile(
      leading: Icon(icon, color: iconColor, size: 24),
      title: Text(title, style: TextStyle(color: titleColor, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      trailing: badge != null
          ? Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(12)),
        child: Text('$badge', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
      )
          : null,
      onTap: onTap,
      selected: isSelected,
      selectedTileColor: AppColors.primary.withOpacity(0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      hoverColor: AppColors.primary.withOpacity(0.04),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
