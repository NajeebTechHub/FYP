//
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:mentorcraft2/teacher/screens/teacher_profile_screen.dart';
//
// import 'package:mentorcraft2/theme/color.dart';
// import 'package:provider/provider.dart';
//
// import '../../auth/simple_auth_provider.dart';
// import '../../core/models/user_role.dart';
// import '../../screens/auth/login_screen.dart';
// import '../provider/teacher_provider.dart';
//
// class SettingsScreen extends StatelessWidget {
//   const SettingsScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Settings'),
//         backgroundColor: AppColors.darkBlue,
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             const SizedBox(height: 16),
//             _buildSettingSection(
//               context,
//               'Account & Profile',
//               [
//                 _buildSettingTile(
//                   context,
//                   'Manage Profile',
//                   'Edit your personal information',
//                   Icons.person_outline,
//
//                 ),
//               ],
//             ),
//             _buildSettingSection(
//               context,
//               'Notifications',
//               [
//                 _buildSettingTile(
//                   context,
//                   'Notification Preferences',
//                   'Manage your notification settings',
//                   Icons.notifications_outlined,
//                   onTap: () {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(
//                         content: Text('Notification settings coming soon!'),
//                         duration: Duration(seconds: 2),
//                       ),
//                     );
//                   },
//                 ),
//               ],
//             ),
//             _buildSettingSection(
//               context,
//               'App Preferences',
//               [
//                 _buildThemeModeTile(context),
//                 _buildLanguageTile(context),
//               ],
//             ),
//             _buildSettingSection(
//               context,
//               'Privacy & Legal',
//               [
//                 _buildSettingTile(
//                   context,
//                   'Privacy Policy',
//                   'Read our privacy policy',
//                   Icons.privacy_tip_outlined,
//                   onTap: () => Navigator.pushNamed(context, '/privacy'),
//                 ),
//                 _buildSettingTile(
//                   context,
//                   'Terms & Conditions',
//                   'View terms of service',
//                   Icons.description_outlined,
//                   onTap: () => Navigator.pushNamed(context, '/terms'),
//                 ),
//               ],
//             ),
//             _buildSettingSection(
//               context,
//               'Help & Support',
//               [
//                 _buildSettingTile(
//                   context,
//                   'FAQs',
//                   'Frequently asked questions',
//                   Icons.help_outline,
//                   onTap: () => Navigator.pushNamed(context, '/faqs'),
//                 ),
//                 _buildSettingTile(
//                   context,
//                   'Contact Support',
//                   'Get help from our team',
//                   Icons.support_agent_outlined,
//                   onTap: () => Navigator.pushNamed(context, '/support'),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 24),
//             _buildLogoutButton(context),
//             const SizedBox(height: 32),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildSettingSection(
//       BuildContext context,
//       String title,
//       List<Widget> tiles,
//       ) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
//           child: Text(
//             title.toUpperCase(),
//             style: const TextStyle(
//               fontSize: 13,
//               fontWeight: FontWeight.bold,
//               color: AppColors.textSecondary,
//               letterSpacing: 1,
//             ),
//           ),
//         ),
//         Card(
//           margin: const EdgeInsets.symmetric(horizontal: 16),
//           elevation: 2,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Column(children: tiles),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildSettingTile(
//       BuildContext context,
//       String title,
//       String subtitle,
//       IconData icon, {
//         VoidCallback? onTap,
//       }) {
//     return ListTile(
//       leading: Container(
//         width: 40,
//         height: 40,
//         decoration: BoxDecoration(
//           color: AppColors.darkBlue.withOpacity(0.08),
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child: Icon(
//           icon,
//           color: AppColors.primary,
//           size: 22,
//         ),
//       ),
//       title: Text(
//         title,
//         style: const TextStyle(
//           fontWeight: FontWeight.w600,
//           fontSize: 16,
//         ),
//       ),
//       subtitle: Text(
//         subtitle,
//         style: TextStyle(
//           color: Colors.grey[600],
//           fontSize: 14,
//         ),
//       ),
//       trailing: const Icon(
//         Icons.arrow_forward_ios,
//         size: 16,
//         color: AppColors.textSecondary,
//       ),
//       onTap: onTap,
//     );
//   }
//
//   Widget _buildThemeModeTile(BuildContext context) {
//     return SwitchListTile(
//       secondary: Container(
//         width: 40,
//         height: 40,
//         decoration: BoxDecoration(
//           color: AppColors.darkBlue.withOpacity(0.08),
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child: const Icon(
//           Icons.dark_mode_outlined,
//           color: AppColors.primary,
//           size: 22,
//         ),
//       ),
//       title: const Text(
//         'Dark Mode',
//         style: TextStyle(
//           fontWeight: FontWeight.w600,
//           fontSize: 16,
//         ),
//       ),
//       subtitle: const Text(
//         'Switch between light and dark theme',
//         style: TextStyle(
//           color: AppColors.textSecondary,
//           fontSize: 14,
//         ),
//       ),
//       value: false,
//       onChanged: (bool value) {
//         // Theme switching logic will be implemented here
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Theme switching coming soon!'),
//             duration: Duration(seconds: 2),
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildLanguageTile(BuildContext context) {
//     return _buildSettingTile(
//       context,
//       'Language',
//       'Choose your preferred language',
//       Icons.language,
//       onTap: () {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Language selection coming soon!'),
//             duration: Duration(seconds: 2),
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildLogoutButton(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       child: ElevatedButton.icon(
//         onPressed: () {
//           showDialog(
//             context: context,
//             builder: (BuildContext context) {
//               return AlertDialog(
//                 title: const Text('Confirm Logout'),
//                 content: const Text(
//                   'Are you sure you want to logout from your account?',
//                 ),
//                 actions: [
//                   TextButton(
//                     onPressed: () => Navigator.pop(context),
//                     child: const Text('CANCEL'),
//                   ),
//                   TextButton(
//                     onPressed: () async{
//                       Navigator.pop(context);
//                       // Implement logout logic here
//                       // Perform logout
//                       final authProvider = Provider.of<SimpleAuthProvider>(context, listen: false);
//                       await authProvider.signOut();
//
//                       await FirebaseAuth.instance.signOut();
//                       Provider.of<TeacherProvider>(context, listen: false).clearData();
//
//
//                       // Navigate to LoginScreen
//                       Navigator.of(context).pushAndRemoveUntil(
//                         MaterialPageRoute(builder: (context) =>  LoginScreen(selectedRole: UserRole.teacher,)),
//                             (route) => false,
//                       );
//
//                       // Show confirmation snackbar
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(content: Text('Logged out successfully')),
//                       );
//                     },
//                     style: TextButton.styleFrom(
//                       // backgroundColor: w,
//                     ),
//                     child: const Text('LOGOUT'),
//                   ),
//                 ],
//               );
//             },
//           );
//         },
//         icon: const Icon(Icons.logout,color: Colors.white,),
//         label: const Text('Logout',style: TextStyle(color: Colors.white),),
//         style: ElevatedButton.styleFrom(
//           backgroundColor: AppColors.primary,
//           minimumSize: const Size(double.infinity, 48),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//         ),
//       ),
//     );
//   }
// }
