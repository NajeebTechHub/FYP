

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/models/user_role.dart';

class AppUser {
  final String uid;
  final String email;
  final String displayName;
  final UserRole role;

  AppUser({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.role,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'role': role.toString().split('.').last,
    };
  }

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      uid: json['uid'] ?? '',
      email: json['email'] ?? '',
      displayName: json['displayName'] ?? '',
      role: UserRole.values.firstWhere(
            (role) => role.toString().split('.').last == json['role'],
        orElse: () => UserRole.student,
      ),
    );
  }
}

class SimpleAuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  AppUser? _user;
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _errorMessage;

  AppUser? get user => _user;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  bool get isAuthenticated => _user != null;
  bool get isStudent => _user?.role == UserRole.student;
  bool get isTeacher => _user?.role == UserRole.teacher;
  String? get errorMessage => _errorMessage;

  SimpleAuthProvider() {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    _setLoading(true);
    try {
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        final prefs = await SharedPreferences.getInstance();
        final role = prefs.getString('user_role');
        if (role != null) {
          _setUser(AppUser(
            uid: currentUser.uid,
            email: currentUser.email ?? '',
            displayName: currentUser.displayName ?? '',
            role: UserRole.values.firstWhere(
                  (r) => r.toString().split('.').last == role,
              orElse: () => UserRole.student,
            ),
          ));
        }
      }
    } catch (e) {
      _setError('Failed to initialize: $e');
    } finally {
      _isInitialized = true;
      _setLoading(false);
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String displayName,
    required UserRole role,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await credential.user!.updateDisplayName(displayName);

      final appUser = AppUser(
        uid: credential.user!.uid,
        email: email,
        displayName: displayName,
        role: role,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_role', role.toString().split('.').last);

      _setUser(appUser);
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(e.message ?? 'Registration failed');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final prefs = await SharedPreferences.getInstance();
      final role = prefs.getString('user_role') ?? 'student';

      final appUser = AppUser(
        uid: credential.user!.uid,
        email: credential.user!.email ?? '',
        displayName: credential.user!.displayName ?? '',
        role: UserRole.values.firstWhere(
              (r) => r.toString().split('.').last == role,
          orElse: () => UserRole.student,
        ),
      );

      _setUser(appUser);
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(e.message ?? 'Login failed');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    try {
      _setLoading(true);
      await _auth.signOut();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_role');
      _setUser(null);
    } catch (e) {
      _setError('Logout failed: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      _setLoading(true);
      _clearError();

      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(e.message ?? 'Password reset failed');
      return false;
    } finally {
      _setLoading(false);
    }
  }


  Future<bool> checkOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('onboarding_completed') ?? false;
  }

  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
  }

  void _setUser(AppUser? user) {
    _user = user;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
