import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mentorcraft2/theme/color.dart';

class EditDiscussionScreen extends StatefulWidget {
  final String docId;
  final String currentTitle;

  const EditDiscussionScreen({
    Key? key,
    required this.docId,
    required this.currentTitle,
  }) : super(key: key);

  @override
  State<EditDiscussionScreen> createState() => _EditDiscussionScreenState();
}

class _EditDiscussionScreenState extends State<EditDiscussionScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.currentTitle;
  }

  Future<void> _updateDiscussion() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('discussions')
          .doc(widget.docId)
          .update({
        'title': _titleController.text.trim(),
        'editedAt': Timestamp.now(),
      });

      Navigator.pop(context); // Close screen after update
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Discussion updated')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating discussion: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Discussion'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                value == null || value.isEmpty ? 'Title cannot be empty' : null,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkBlue,
                  ),
                  onPressed: _isLoading ? null : _updateDiscussion,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Update',style: TextStyle(color: Colors.white),),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
