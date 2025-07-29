import 'package:flutter/material.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms & Conditions'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Terms & Conditions',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                'By using the MentorCraft app, you agree to the following terms and conditions. Please read them carefully.',
              ),
              SizedBox(height: 16),
              Text(
                '1. Account Responsibility',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('You are responsible for maintaining the confidentiality of your account and password.'),
              SizedBox(height: 16),
              Text(
                '2. Course Access & Usage',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('Courses purchased are for personal use only and may not be shared or redistributed without permission.'),
              SizedBox(height: 16),
              Text(
                '3. Payment Terms',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('All payments are processed via PayFast. We are not responsible for failed or delayed transactions.'),
              SizedBox(height: 16),
              Text(
                '4. Refund Policy',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('Refunds are only applicable within 7 days of course purchase, subject to content usage.'),
              SizedBox(height: 16),
              Text(
                '5. Content Ownership',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('All course materials are the intellectual property of the respective creators and MentorCraft.'),
              SizedBox(height: 16),
              Text(
                '6. Termination of Use',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('We reserve the right to suspend or terminate your account if you violate these terms.'),
              SizedBox(height: 16),
              Text(
                '7. Changes to Terms',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('We may modify these terms at any time. Continued use of the app constitutes acceptance of the updated terms.'),
              SizedBox(height: 32),
              Text(
                'Contact Us:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('If you have any questions about these Terms, please contact us at support@mentorcraft.com'),
            ],
          ),
        ),
      ),
    );
  }
}
