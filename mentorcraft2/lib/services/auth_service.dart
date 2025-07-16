import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/models/user_role.dart';
import '../models/app_user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Sign up with email and password
  Future<AppUser?> signUpWithEmailAndPassword(
      String email,
      String password,
      String displayName,
      UserRole role,
      ) async {
    try {
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = result.user;
      if (user != null) {
        // Update display name
        await user.updateDisplayName(displayName);

        // Create user document in Firestore
        final appUser = AppUser(
          id: user.uid,
          email: email,
          displayName: displayName,
          role: role,
          createdAt: DateTime.now(),
          isEmailVerified: user.emailVerified,
        );

        await _firestore.collection('users').doc(user.uid).set(appUser.toFirestore());

        // Save role locally
        await _saveUserRoleLocally(role);

        return appUser;
      }
    } catch (e) {
      throw e;
    }
    return null;
  }

  // Sign in with email and password
  Future<AppUser?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = result.user;
      if (user != null) {
        final appUser = await getUserFromFirestore(user.uid);
        if (appUser != null) {
          // Save role locally
          await _saveUserRoleLocally(appUser.role);
        }
        return appUser;
      }
    } catch (e) {
      throw e;
    }
    return null;
  }

  // Get user data from Firestore
  Future<AppUser?> getUserFromFirestore(String uid) async {
    try {
      final DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();

      if (doc.exists) {
        return AppUser.fromFirestore(doc.data() as Map<String, dynamic>, uid);
      }
    } catch (e) {
      print('Error getting user from Firestore: $e');
    }
    return null;
  }

  // Save user role locally
  Future<void> _saveUserRoleLocally(UserRole role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_role', role.toString().split('.').last);
  }

  // Get user role from local storage
  Future<UserRole?> getUserRoleLocally() async {
    final prefs = await SharedPreferences.getInstance();
    final roleString = prefs.getString('user_role');

    if (roleString != null) {
      return UserRole.values.firstWhere(
            (role) => role.toString().split('.').last == roleString,
        orElse: () => UserRole.student,
      );
    }
    return null;
  }

  // Sign out
  Future<void> signOut() async {
    // Clear local storage
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_role');
    await prefs.remove('onboarding_completed');

    // Sign out from Firebase
    await _auth.signOut();
  }

  // Check if onboarding is completed
  Future<bool> isOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('onboarding_completed') ?? false;
  }

  // Mark onboarding as completed
  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // Get current user with role
  Future<AppUser?> getCurrentUserWithRole() async {
    final user = currentUser;
    if (user != null) {
      return await getUserFromFirestore(user.uid);
    }
    return null;
  }
}