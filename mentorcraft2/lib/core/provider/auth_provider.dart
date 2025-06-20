import 'package:flutter/material.dart';
import '../models/user_role.dart';

class AuthProvider with ChangeNotifier {
  AppUser? _currentUser;
  bool _isLoggedIn = false;

  // Default users for demo purposes
  final List<AppUser> _demoUsers = [
    AppUser(
      id: 'teacher_001',
      name: 'Dr. Sarah Johnson',
      email: 'sarah.johnson@mentorcraft.com',
      avatar: 'assets/teacher_avatar.png',
      role: UserRole.teacher,
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 365)),
      metadata: {
        'specialization': 'Mobile Development',
        'experience': '10+ years',
        'rating': 4.8,
      },
    ),
    AppUser(
      id: 'student_001',
      name: 'John Doe',
      email: 'john.doe@email.com',
      avatar: 'assets/student_avatar.png',
      role: UserRole.student,
      isActive: true,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      metadata: {
        'enrolledCourses': 3,
        'completedCourses': 1,
      },
    ),
  ];

  // Getters
  AppUser? get currentUser => _currentUser;
  bool get isLoggedIn => _isLoggedIn;
  bool get isTeacher => _currentUser?.isTeacher ?? false;
  bool get isStudent => _currentUser?.isStudent ?? false;

  // Login method
  Future<bool> login(String email, String password, {UserRole? preferredRole}) async {
    // Simulate authentication delay
    await Future.delayed(const Duration(seconds: 1));

    // For demo purposes, find user by email
    AppUser? user = _demoUsers.firstWhere(
          (u) => u.email == email,
      orElse: () => _demoUsers.first, // Default to first user if not found
    );

    // If preferred role is specified, use it
    if (preferredRole != null) {
      user = _demoUsers.firstWhere(
            (u) => u.role == preferredRole,
        orElse: () => user!,
      );
    }

    _currentUser = user;
    _isLoggedIn = true;
    notifyListeners();

    return true;
  }

  // Quick role switch for demo
  void switchToTeacher() {
    _currentUser = _demoUsers.firstWhere((u) => u.isTeacher);
    _isLoggedIn = true;
    notifyListeners();
  }

  void switchToStudent() {
    _currentUser = _demoUsers.firstWhere((u) => u.isStudent);
    _isLoggedIn = true;
    notifyListeners();
  }

  // Logout method
  void logout() {
    _currentUser = null;
    _isLoggedIn = false;
    notifyListeners();
  }

  // Update user profile
  void updateProfile(AppUser updatedUser) {
    _currentUser = updatedUser;
    notifyListeners();
  }
}