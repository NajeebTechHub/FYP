import 'package:flutter/material.dart';

class AboutMentorCraftScreen extends StatelessWidget {
  const AboutMentorCraftScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About MentorCraft'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'MentorCraft',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text(
              'MentorCraft is an innovative e-learning platform designed to bridge the gap '
                  'between teachers and students. Our goal is to make quality education accessible, '
                  'interactive, and efficient for all.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              'Key Features:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            BulletPoint(text: 'Role-based login system (Teacher & Student)'),
            BulletPoint(text: 'Teacher-side course management'),
            BulletPoint(text: 'Student dashboard with course progress'),
            BulletPoint(text: 'Secure Firebase Authentication'),
            BulletPoint(text: 'User-friendly interface for mobile users'),
            SizedBox(height: 20),
            Text(
              'Our Vision:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'To revolutionize e-learning in Pakistan by providing students with a smart, '
                  'accessible, and localized learning experience. We aim to empower educators and '
                  'bring academic resources right to the palm of students.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              'Meet the Developers:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '- Najeeb Anjum (Flutter Developer)\n'
                  '- [Team Member 2 Name]\n'
                  '- [Team Member 3 Name]',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class BulletPoint extends StatelessWidget {
  final String text;
  const BulletPoint({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 18)),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }
}
