import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mentorcraft2/theme/color.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'package:cloud_firestore/cloud_firestore.dart';

import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with TickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _avatarAnimation;
  late final Animation<double> _fadeAnimation;

  User? currentUser;
  String? _profileImageUrl;
  bool _isUploading = false;
  String userRole = '';

  final int enrolledCourses = 8;
  final int completedCourses = 3;
  final int certificatesEarned = 2;

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser;

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _avatarAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
      _loadProfileImageUrl();
      _loadUserRole();
    });
  }

  Future<void> _loadProfileImageUrl() async {
    final userId = currentUser?.uid;
    if (userId == null) return;

    try {
      final imageUrl = Supabase.instance.client.storage
          .from('profile-images')
          .getPublicUrl('public/$userId.jpg');

      setState(() {
        _profileImageUrl = imageUrl;
      });
    } catch (e) {
      debugPrint("Failed to load image URL: $e");
    }
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    setState(() => _isUploading = true);

    try {
      final userId = currentUser?.uid;
      if (userId == null) throw Exception("User not logged in");

      final fileBytes = await picked.readAsBytes();
      final fileName = 'public/$userId.jpg';

      final storage = Supabase.instance.client.storage;
      await storage.from('profile-images').uploadBinary(
        fileName,
        fileBytes,
        fileOptions: const FileOptions(upsert: true),
      );

      final publicUrl = storage.from('profile-images').getPublicUrl(fileName);
      setState(() {
        _profileImageUrl = publicUrl;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image upload failed: ${e.toString()}')),
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Future<void> _loadUserRole() async {
    final uid = currentUser?.uid;
    if (uid == null) return;

    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        setState(() {
          userRole = doc.data()?['role'] ?? '';
        });
      }
    } catch (e) {
      debugPrint("Failed to fetch user role: $e");
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final bool isTablet = screenSize.width > 600;
    final String userName = currentUser?.displayName ?? "Student";
    final String userEmail = currentUser?.email ?? "No Email";

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(context, isTablet, userName, userEmail),
            const SizedBox(height: 24),
            AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _buildStatisticsSection(context),
                      ),
                      const SizedBox(height: 24),
                      _buildSettingsList(context),
                      const SizedBox(height: 24),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, bool isTablet, String name, String email) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.darkBlue, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          child: Column(
            children: [
              Center(
                child: Stack(
                  children: [
                    Hero(
                      tag: 'profileAvatar',
                      child: AnimatedBuilder(
                        animation: _avatarAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: (_avatarAnimation.value.clamp(0.0, 1.0) * 0.5) + 0.5,
                            child: Container(
                              width: isTablet ? 140 : 120,
                              height: isTablet ? 140 : 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 3),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 10,
                                    spreadRadius: 5,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: _isUploading
                                    ? const Center(child: CircularProgressIndicator())
                                    : (_profileImageUrl != null && _profileImageUrl!.isNotEmpty)
                                    ? Image.network(
                                  _profileImageUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return _defaultIcon(isTablet);
                                  },
                                )
                                    : _defaultIcon(isTablet),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Positioned(
                      bottom: 6,
                      right: 6,
                      child: GestureDetector(
                        onTap: _pickAndUploadImage,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.lightBlue,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                name,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isTablet ? 28 : 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                email,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: isTablet ? 18 : 16,
                ),
              ),
              const SizedBox(height: 4),
              if (userRole.isNotEmpty)
                Text(
                  userRole,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _defaultIcon(bool isTablet) {
    return Container(
      color: Colors.grey[200],
      child: Icon(
        Icons.person,
        size: isTablet ? 80 : 64,
        color: AppColors.darkBlue,
      ),
    );
  }

  Widget _buildStatisticsSection(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatisticItem("Enrolled", enrolledCourses),
            _buildStatisticItem("Completed", completedCourses),
            _buildStatisticItem("Certificates", certificatesEarned),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticItem(String label, int count) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildSettingsList(BuildContext context) {
    return Column(
      children: [
        _buildSettingsItem(
          context,
          Icons.edit,
          "Edit Profile",
          "Update your name & email",
          onTap: () async {
            final updated = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const EditProfileScreen()),
            );
            if (updated == true) {
              _loadUserRole();
              _loadProfileImageUrl();
              setState(() {
                currentUser = FirebaseAuth.instance.currentUser;
              });
            }
          },
        ),
        _buildSettingsItem(
          context,
          Icons.lock,
          "Change Password",
          "Update your password",
          // onTap: () => Navigator.push(...),
        ),
        _buildSettingsItem(
          context,
          Icons.notifications,
          "Notifications",
          "Manage your alerts",
        ),
      ],
    );
  }

  Widget _buildSettingsItem(
      BuildContext context,
      IconData icon,
      String title,
      String subtitle, {
        Function()? onTap,
      }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: CircleAvatar(
        backgroundColor: AppColors.lightBlue.withOpacity(0.2),
        child: Icon(icon, color: AppColors.primary),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
