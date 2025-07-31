import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_user.dart';
import '../core/models/user_role.dart';

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
        await _restoreUserFromPreferences(currentUser);
      }
    } catch (e) {
      _setError('Failed to initialize: $e');
    } finally {
      _isInitialized = true;
      _setLoading(false);
    }
  }

  Future<void> restoreSession() async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      await _restoreUserFromPreferences(currentUser);
    }
  }

  Future<void> _restoreUserFromPreferences(User currentUser) async {
    final role = await getSavedRole();

    final appUser = AppUser(
      id: currentUser.uid,
      email: currentUser.email ?? '',
      displayName: currentUser.displayName ?? '',
      role: role,
      createdAt: DateTime.now(),
      isEmailVerified: currentUser.emailVerified,
    );

    _setUser(appUser);
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

      await saveSelectedRole(role);

      final appUser = AppUser(
        id: credential.user!.uid,
        email: email,
        displayName: displayName,
        role: role,
        createdAt: DateTime.now(),
        isEmailVerified: false,
      );

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

      final role = await getSavedRole();
      await saveSelectedRole(role);

      final appUser = AppUser(
        id: credential.user!.uid,
        email: credential.user!.email ?? '',
        displayName: credential.user!.displayName ?? '',
        role: role,
        createdAt: DateTime.now(),
        isEmailVerified: credential.user!.emailVerified,
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
      await prefs.clear();
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

  Future<void> saveSelectedRole(UserRole role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_role', role.name);
  }

  Future<UserRole> getSavedRole() async {
    final prefs = await SharedPreferences.getInstance();
    final roleStr = prefs.getString('user_role')?.toLowerCase() ?? 'student';

    for (var role in UserRole.values) {
      if (role.name.toLowerCase() == roleStr) {
        return role;
      }
    }
    return UserRole.student;
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
