import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mentorcraft2/models/app_user.dart';
import 'package:mentorcraft2/core/models/user_role.dart';
import 'package:mentorcraft2/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  AppUser? _user;
  bool _isLoading = true;
  bool _isInitialized = false;
  String? _errorMessage;

  bool get isInitialized => _isInitialized;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  AppUser? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isTeacher => _user?.role == UserRole.teacher;
  bool get isStudent => _user?.role == UserRole.student;

  AuthProvider() {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    try {
      _setLoading(true);
      _authService.authStateChanges.listen((User? firebaseUser) async {
        if (firebaseUser != null) {
          final appUser = await _authService.getUserFromFirestore(firebaseUser.uid);
          if (appUser != null) {
            _setUser(appUser);
          } else {
            debugPrint('❌ Failed to fetch user from Firestore');
            _setUser(null);
          }
        } else {
          _setUser(null);
        }

        if (!_isInitialized) {
          _isInitialized = true;
          notifyListeners();
        }
      });
    } catch (e) {
      _setError('Failed to initialize auth: $e');
    } finally {
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

      final user = await _authService.signUpWithEmailAndPassword(
        email,
        password,
        displayName,
        role,
      );

      if (user != null) {
        _setUser(user.copyWith(
          avatar: _firebaseAuth.currentUser?.photoURL ?? '',
        ));
        return true;
      }
      return false;
    } catch (e) {
      _setError(_getErrorMessage(e));
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

      final user = await _authService.signInWithEmailAndPassword(email, password);
      if (user != null) {
        final avatar = user.avatar.isNotEmpty
            ? user.avatar
            : (_firebaseAuth.currentUser?.photoURL ?? 'assets/placeholder.jpg');

        _setUser(user.copyWith(avatar: avatar));
        return true;
      }
      return false;
    } catch (e) {
      _setError(_getErrorMessage(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    try {
      _setLoading(true);
      await _authService.signOut();
      _user = null;
      notifyListeners();
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
      await _authService.resetPassword(email);
      return true;
    } catch (e) {
      _setError(_getErrorMessage(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> completeOnboarding() async {
    await _authService.completeOnboarding();
  }

  Future<bool> checkOnboardingStatus() async {
    return await _authService.isOnboardingCompleted();
  }

  void updateProfile(AppUser updatedUser) {
    _user = updatedUser;
    notifyListeners();
  }

  void _setUser(AppUser? user) {
    _user = user;
    notifyListeners();
  }

  void setUser(AppUser newUser) {
    _user = newUser;
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

  String _getErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'No user found with this email.';
        case 'wrong-password':
          return 'Incorrect password.';
        case 'email-already-in-use':
          return 'An account already exists with this email.';
        case 'weak-password':
          return 'The password is too weak.';
        default:
          return error.message ?? 'An error occurred.';
      }
    }
    return error.toString();
  }
}
