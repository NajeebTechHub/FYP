import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../theme/color.dart';

class AddDiscussionScreen extends StatefulWidget {
  const AddDiscussionScreen({Key? key}) : super(key: key);

  @override
  State<AddDiscussionScreen> createState() => _AddDiscussionScreenState();
}

class _AddDiscussionScreenState extends State<AddDiscussionScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();

  String _currentUserName = 'Anonymous';
  bool _isSubmitting = false;

  final List<String> _categories = [
    'General',
    'Programming',
    'UI/UX',
    'Career',
    'Mobile Dev',
    'Web Dev',
  ];

  String? _selectedCategory;


  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    setState(() {
      _currentUserName = user?.displayName ?? 'Anonymous';
    });
  }

  Future<void> _submitDiscussion() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);

      await FirebaseFirestore.instance.collection('discussions').add({
        'uid': FirebaseAuth.instance.currentUser!.uid,
        'title': _titleController.text.trim(),
        'author': _currentUserName,
        'timestamp': FieldValue.serverTimestamp(),
        'views': 0,
        'replies': 0,
        'isHot': false,
        'category': _selectedCategory,
      });

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Discussion',style: TextStyle(fontWeight: FontWeight.bold),),
        backgroundColor: AppColors.darkBlue,
        foregroundColor: AppColors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
                decoration: const InputDecoration(
                    labelText: 'Select Category',
                  border: OutlineInputBorder()
                ),
                validator: (value) =>
                value == null ? 'Please select a category' : null,
              ),
              SizedBox(height: 10,),
              TextFormField(
                controller: _titleController,
                minLines: 3,
                maxLines: 10,
                decoration: const InputDecoration(
                    labelText: 'Discussion Title',
                  border: OutlineInputBorder()
                ),
                validator: (value) =>
                value!.isEmpty ? 'Please enter a title' : null,
              ),
              const SizedBox(height: 24),
              _isSubmitting
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _submitDiscussion,
                child: const Text('Post Discussion'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
