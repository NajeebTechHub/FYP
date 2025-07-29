import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Privacy Policy',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                'We value your privacy. This policy explains how MentorCraft collects, uses, and protects your personal data when you use our platform.',
              ),
              SizedBox(height: 16),
              Text(
                '1. Information Collection',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                  'We collect personal data including name, email, phone number, and user activity such as course progress and quiz participation.'
              ),
              SizedBox(height: 16),
              Text(
                '2. Usage of Information',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                  'Your information is used to provide course access, payment processing (via PayFast), and personalized learning experiences.'
              ),
              SizedBox(height: 16),
              Text(
                '3. Data Sharing',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                  'We do not sell or rent your personal data. We only share necessary details with payment processors (e.g., PayFast) as required.'
              ),
              SizedBox(height: 16),
              Text(
                '4. Data Security',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                  'We implement secure storage, encryption, and access controls to protect your data in compliance with industry standards (e.g., PCI-DSS).'
              ),
              SizedBox(height: 16),
              Text(
                '5. User Rights',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                  'You can request to access, update, or delete your personal data by contacting our support.'
              ),
              SizedBox(height: 16),
              Text(
                '6. Updates to This Policy',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                  'We may update this Privacy Policy from time to time. You will be notified of any significant changes within the app.'
              ),
              SizedBox(height: 32),
              Text(
                'Contact Us:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('If you have any questions, please contact us at support@mentorcraft.com'),
            ],
          ),
        ),
      ),
    );
  }
}
