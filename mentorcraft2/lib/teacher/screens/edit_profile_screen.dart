import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _currentEmailController = TextEditingController();
  final _newEmailController = TextEditingController();
  final _passwordController = TextEditingController();

  User? currentUser;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      _nameController.text = currentUser!.displayName ?? '';
      _currentEmailController.text = currentUser!.email ?? '';
    }
  }

  void _showSnackBar(String message, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? Colors.red : Colors.green,
      ),
    );
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final currentEmail = _currentEmailController.text.trim();
    final newEmail = _newEmailController.text.trim();
    final password = _passwordController.text.trim();

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not found");

      // Re-authenticate
      final credential = EmailAuthProvider.credential(
        email: currentEmail,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);

      // Update name
      if (name.isNotEmpty && name != user.displayName) {
        await user.updateDisplayName(name);
      }

      // Email update (with verification link)
      if (newEmail.isNotEmpty && newEmail != user.email) {
        await user.verifyBeforeUpdateEmail(newEmail);
        _showSnackBar("Verification link sent to $newEmail. Please verify to complete update.");
      }

      // Update Firestore (email will update once verified)
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'name': name,
        'email': newEmail.isNotEmpty ? newEmail : currentEmail,
      });

      // Reload user to get updated info (if already verified)
      await user.reload();
      currentUser = FirebaseAuth.instance.currentUser;

      setState(() {
        _currentEmailController.text = currentUser?.email ?? '';
      });

    } on FirebaseAuthException catch (e) {
      String message = "Failed to update profile";
      if (e.code == 'wrong-password') {
        message = "Incorrect password";
      } else if (e.code == 'email-already-in-use') {
        message = "New email already in use";
      } else if (e.code == 'requires-recent-login') {
        message = "Please login again to continue";
      }
      _showSnackBar(message, error: true);
    } catch (e) {
      _showSnackBar("Error: ${e.toString()}", error: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _refreshProfile() async {
    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      await user?.reload();
      currentUser = FirebaseAuth.instance.currentUser;
      setState(() {
        _currentEmailController.text = currentUser?.email ?? '';
      });
      _showSnackBar("Profile refreshed");
    } catch (e) {
      _showSnackBar("Error refreshing profile", error: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _currentEmailController.dispose();
    _newEmailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Full Name"),
                validator: (value) =>
                value == null || value.isEmpty ? "Please enter name" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _currentEmailController,
                readOnly: true,
                decoration: const InputDecoration(labelText: "Current Email"),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _newEmailController,
                decoration: const InputDecoration(labelText: "New Email"),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: "Current Password"),
                obscureText: true,
                validator: (value) =>
                value == null || value.isEmpty ? "Enter current password" : null,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _updateProfile,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text("Update Profile"),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _isLoading ? null : _refreshProfile,
                child: const Text("Refresh Profile"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
