import 'package:flutter/material.dart';

class HelpAndSupportScreen extends StatelessWidget {
  const HelpAndSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: const [
            Text(
              'How can we help you?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              '🔹 Browse our FAQs section for common questions.\n\n'
                  '🔹 Contact our support team if your issue isn’t listed.\n\n'
                  '🔹 You can also email us at: support@mentorcraft.com\n\n'
                  '🔹 App feedback and suggestions are welcome — help us improve MentorCraft!',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 24),
            Text(
              'Live Support Hours',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '🕘 Monday to Friday: 9 AM – 6 PM\n'
                  '📞 Phone Support: Coming Soon!',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
